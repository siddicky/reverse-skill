# ELF Binary Deep Analysis Reference

> Structural parsing, anti-analysis adversarial identification and analysis techniques when reverse engineering Linux/Android ELF files.

---

## ELF structure quick review

### File header (ELF Header)

```text
Offset Size Field Description
0x00  4    e_ident[EI_MAG]   Magic: 7f 45 4c 46 ("\x7fELF")
0x04  1    e_ident[EI_CLASS] 1=32bit, 2=64bit
0x05  1    e_ident[EI_DATA]  1=LE, 2=BE
0x10  2    e_type            2=EXEC, 3=DYN(PIE/SO), 4=CORE
0x12  2    e_machine         0x03=x86, 0x3E=x86_64, 0xB7=AArch64, 0x28=ARM
0x18 8 e_entry entry point virtual address
0x20 8 e_phoff program header table offset
0x28 8 e_shoff section header table offset (may be 0 after strip)
0x38 2 e_phnum Number of program headers
0x3C 2 e_shnum Number of section headers
```

### Program Header

```text
Type Value Name Description
0x01 PT_LOAD loadable segment (code/data)
0x02 PT_DYNAMIC dynamic link information
0x03 PT_INTERP interpreter path (/lib/ld-linux.so)
0x04 PT_NOTE auxiliary information
0x06 PT_PHDR program header table itself
0x6474e550 PT_GNU_EH_FRAME exception handling
0x6474e551 PT_GNU_STACK stack executable flag
0x6474e552 PT_GNU_RELRO read-only relocation
```

### Common Sections

| Section name | Description |
|------|------|
|`.text`| code snippet |
|`.rodata`| Read-only data (string constant) |
|`.data`| Global variable | has been initialized
|`.bss`| Global variable | is not initialized
|`.plt`/`.got`| Dynamic link jump table |
|`.init_array`| Constructor pointer array |
|`.fini_array`| destructor pointer array |
|`.dynamic`| Dynamic link information |
|`.symtab`/`.dynsym`| Symbol table |
|`.strtab`/`.dynstr`| String table |

---

## Anti-analysis techniques identification

### Common ELF anti-analysis techniques

| Technique | Characteristics | Countermeasures |
|------|------|---------|
| corrupted program header | PHDR filled with garbage data (such as 0x0a) | Manually repair or ignore the corrupted PHDR |
| has no section header |`e_shoff = 0`,`e_shnum = 0`| only relies on program header analysis and does not rely on section |
| strips | without`.symtab`, all function names are lost | GoReSym(Go) / signature matching / FLIRT |
| static link | without`.dynamic`, huge size | Use FLIRT/Lumina to identify library function |
| disguises the file type | suffix .sh/.txt/.jpg | Use`file`command / magic bytes to determine |
| UPX packed | contains`UPX!`tag |`upx -d`unpacked |
| custom shell | entry point jumps to the decompression code | dumps | after dynamically running to OEP
| anti-debugging | ptrace(TRACEME) | LD_PRELOAD hook / patch |
| Anti-virtual machine | Check /proc/cpuinfo | Modify cpuinfo or hook to read |
| code encryption | runtime decryption .text | breakpoint dump | after decryption

### Identify self-extracting/self-modifying code

```text
feature:
1. Near the entry point, there is mmap(PROT_READ|PROT_WRITE|PROT_EXEC) call
2. Followed by memcpy or loop copy
3. Then use mprotect to change permissions
4. Finally br/jmp to the newly mapped address

Analysis strategy:
1. find mmap call → record returned address
2. Set a breakpoint after the mprotect(PROT_EXEC) call
3. dump the decompressed memory area
4. as new binary analysis
```

---

## ARM64 (AArch64) Reverse Quick Look

### register

| Register | Purpose |
|--------|------|
| x0-x7 | Parameter/return value |
| x8 | indirect result (syscall number) |
| x9-x15 | temporary register |
| x16-x17 | IP0/IP1 (PLT jump) |
| x18 | platform register (Android: shadow call stack) |
| x19-x28 | Callee saves |
| x29 (FP) | Frame pointer |
| x30 (LR) | Link Register (Return Address) |
| SP | stack pointer |
| PC | Program Counter |

### Common command patterns

```text
Function prologue:
  stp x29, x30, [sp, #-N]!    # save FP and LR
  mov x29, sp                  # set the frame pointer

End of function:
  ldp x29, x30, [sp], #N      # restore FP and LR
  ret                          # return (br x30）

System call:
  mov x8, #NR                  # syscall number
  svc #0                       # trigger syscall

Conditional branch:
  cmp x0, #0
  b.eq label                   # branch if equal
  b.ne label                   # branch if not equal
  cbz x0, label                # x0 == 0 redirect
  cbnz x0, label               # x0 != 0 redirect

Address loading:
  adrp x0, page                # load the upper bits of the page address
  add x0, x0, #offset          # add the low 12 bit offset
  ldr x0, [x1, #offset]        # load from memory
```

### Linux ARM64 system call number

| Number | Name | Description |
|------|------|------|
| 56 | openat | Open file |
| 63 | read | read |
| 64 | write | write |
| 57 | close | close |
| 222 | mmap | memory map |
| 226 | mprotect | Modify memory permissions |
| 117 | ptrace | process tracing |
| 220 | clone | Create process/thread |
| 221 | execve | executor |
| 93 | exit | exit |
| 94 | exit_group | Exit process group |

---

## Common compression/packaging algorithm identification

| algorithm | identification feature | decompression method |
|------|---------|---------|
| **LZSS** | bitstream + literal/match flag | Custom decompressor (such as this report) |
| **ZLIB/Deflate** | Magic: `78 01`/`78 9C`/`78 DA` | `zlib.decompress()` |
| **GZIP** | Magic: `1F 8B` | `gzip -d` / `gunzip` |
| **LZ4** | Magic: `04 22 4D 18` | `lz4 -d` |
| **LZMA/XZ** | Magic: `FD 37 7A 58 5A 00` (XZ) | `xz -d` / `lzma -d` |
| **Brotli** | No fixed magic, see context |`brotli -d`|
| **Zstandard** | Magic: `28 B5 2F FD` | `zstd -d` |
| **UPX** | string`UPX!`|`upx -d`|
| **Customized** | The entry point has a decompression loop | Reverse algorithm and post-write decompressor |

### Identifying clues to custom compression

```text
1. There are loops + bit operations (shift, AND, OR) near the entry point
2. A "sliding window" back-reference copy (reading backward from the output buffer) indicates an LZ family format.
3. With frequency table/Huffman tree construction → Deflate/Huffman
4. Has fixed size block processing → block compression (LZ4/Snappy)
5. Has arithmetic coding features (interval reduction) → LZMA/ANS
```

---

## Linux process injection technology

### mmap + code injection

```text
process:
1. mmap(NULL, size, PROT_READ|PROT_WRITE, MAP_ANON|MAP_PRIVATE, -1, 0)
2. Write shellcode/payload into mapped area
3. mprotect(addr, size, PROT_READ|PROT_EXEC)  # make executable
4. Jump to the mapped address for execution

feature:
- mmap return value is saved
- followed by memcpy or loop writing
- Then use mprotect to change permissions
- Finally br/blr to this address
```

### ptrace injection

```text
process:
1. ptrace(PTRACE_ATTACH, target_pid)
2. waitpid(target_pid)
3. ptrace(PTRACE_GETREGS, target_pid, &regs)
4. Modify regs.pc to point to the injected code
5. ptrace(PTRACE_SETREGS, target_pid, &regs)
6. ptrace(PTRACE_CONT, target_pid)

feature:
- Open /proc/<pid>/mem or use ptrace
- Read/modify target process registers
- Write shellcode to the target process space
```

### /proc/self/mem self-modification

```text
process:
1. open("/proc/self/mem", O_RDWR)
2. lseek(fd, target_addr, SEEK_SET)
3. write(fd, new_code, size)

use:
- Bypass W^X protection (mmap pages cannot be W+X at the same time)
- Modify its own code segment (.text is usually read-only)
- runtime patch command
```

---

## Analyzing strategies for large ELFs

For large binaries 5MB+:

```text
1. Quick Scout (5 minutes)
   - file/rabin2 -I → architecture, type, protection
   - strings | grep -i "error\|fail\|http\|/proc\|/dev" → key string
   - rabin2 -i → import function (if any)
   - rabin2 -E → export function

2. Structural Analysis (10 minutes)
   - readelf -l → program header (LOAD section layout)
   - Code near the entry point → Whether there is decompression/decryption
   - Find .init_array → constructor (possibly with anti-debugging)

3. Position key logic
   - Start with string cross-references
   - Start with system calls (mmap/ptrace/open)
   - Start with network functions (connect/send/recv)

4. divide and conquer
   - If it is self-extracting → decompress first and analyze the payload
   - If it is a multi-module → analyze by functional blocks
   - Use binary-diff to compare different versions
```

---

## Tool command quick review

```bash
# Basic information
file binary
readelf -h binary          # ELF header
readelf -l binary          # program header
readelf -S binary          # section header (if present)
rabin2 -I binary           # summary information

# string
strings -a binary | less
rabin2 -z binary           # data-section strings
rabin2 -zz binary          # strings from the entire file

# Disassembly
r2 -A binary               # radare2 analysis
objdump -d binary          # GNU disassembly
aarch64-linux-gnu-objdump -d binary  # ARM64 cross-disassembly

# dynamic analysis
strace -f ./binary         # system-call tracing
ltrace -f ./binary         # library-call tracing
qemu-aarch64 -strace ./binary  # ARM64 emulated execution

# memory dump
gdb -p <pid> -ex "dump memory out.bin 0xADDR 0xADDR+SIZE" -ex quit

# Repair broken ELF
# Manually modify e_phnum or patch the damaged PHDR
python -c "
import struct
with open('binary', 'r+b') as f:
    f.seek(0x38)  # e_phnum offset (64-bit)
    f.write(struct.pack('<H', 2))  # change to the correct PHDR quantity
"
```
