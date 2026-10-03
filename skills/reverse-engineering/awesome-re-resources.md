# Summary of reverse engineering reference resources

> Curated from multiple awesome lists, sorted by usefulness. AI can refer to these resources for methodological and tool guidance during reverse analysis.

---

## Comprehensive resource library

| Project | Stars | Coverage | Link |
|------|-------|------|------|
| **awesome-reversing** (tylerha97) | 3k+ | Reverse tools/books/courses/exercises |https://github.com/tylerha97/awesome-reversing|
| **awesome-reverse-engineering** (alphaSeclab) | 4k+ | 3500+ tools + 2300 articles, all platforms |https://github.com/alphaSeclab/awesome-reverse-engineering|
| **Reverse-Engineering** (mytechnotalent) | 10k+ | Free Tutorial: x86/x64/ARM/AVR/RISC-V |https://github.com/mytechnotalent/Reverse-Engineering|
| **awesome-malware-analysis** (rshipp) | 12k+ | Malware analysis tools/resources |https://github.com/rshipp/awesome-malware-analysis|
| **reversingBits** | — | Reverse/binary analysis cheat sheet collection |https://github.com/mohitmishra786/reversingBits|
| **awesome-arm-exploitation** | — | ARM exploit resources (video/article/book) |https://github.com/HenryHoggard/awesome-arm-exploitation|
| **Binary-Analysis-Automation** | — | Automated binary analysis (ML/script/static/dynamic) |https://github.com/user1342/Awesome-Binary-Analysis-Automation|

---

## ELF/Linux reverse engineering project

| Resource | Description | Link |
|------|------|------|
| **libelfmaster** | Secure ELF parsing library (forensics/malware reconstruction) |https://github.com/elfmaster/libelfmaster|
| **ELF specification** | official ELF format document |https://refspecs.linuxfoundation.org/elf/elf.pdf|
| **Linux Internals** | /proc file system, memory layout, syscall |https://0xax.gitbooks.io/linux-insides/|
| **Compiler Explorer** | Online look at what assembly C/C++/Rust/Go compiles into |https://godbolt.org/|

---

## ARM/AArch64 specialization

| Resource | Description | Link |
|------|------|------|
| **ARM Official Architecture Manual** | Complete Instruction Set Reference |https://developer.arm.com/documentation|
| **Azeria Labs** | ARM assembly/utilization tutorial (best entry) |https://azeria-labs.com/writing-arm-assembly-part-1/|
| **ARM64 syscall table** | Linux AArch64 system call number |https://arm64.syscall.sh/|
| **QEMU user mode simulation** | does not require real device analysis ARM binary |`qemu-aarch64 -strace ./binary`|

---

## Malware analysis

| Resource | Description | Link |
|------|------|------|
| **YARA** | Malware signature matching rules |https://github.com/VirusTotal/yara|
| **Volatility 3** | Memory Forensics Framework |https://github.com/volatilityfoundation/volatility3|
| **FLOSS** | Automatically extract obfuscated strings |https://github.com/mandiant/flare-floss|
| **Detect It Easy (DiE)** | File type/shell/compiler identification |https://github.com/horsicq/Detect-It-Easy|
| **PE-bear** | PE file analyzer |https://github.com/hasherezade/pe-bear|
| **Capa** | Automatic recognition of binary capabilities (network/file/encryption, etc.) |https://github.com/mandiant/capa|
| **Unpacker** | Universal unpacking framework |https://github.com/malwaretech/UnpackerFramework|

---

## Dynamic Analysis/Sandbox

| Resource | Description | Link |
|------|------|------|
| **Frida** | cross-platform dynamic instrumentation |https://frida.re/|
| **strace** | Linux system call tracing | comes with the system |
| **ltrace** | library function call tracing | comes with the system |
| **QEMU** | User mode/system mode simulation |https://www.qemu.org/|
| **Unicorn** | CPU simulation framework (programmable) |https://www.unicorn-engine.org/|
| **Qiling** | Advanced binary simulation framework |https://qiling.io/|
| **angr** | symbolic execution + binary analysis |https://angr.io/|
| **Triton** | Dynamic binary analysis framework |https://triton-library.github.io/|

---

## Anti-obfuscation/unpacking

| Resource | Description | Link |
|------|------|------|
| **UPX** | The most common shell,`upx -d`shelled |https://upx.github.io/|
| **unipacker** | Universal PE packer |https://github.com/unipacker/unipacker|
| **de4dot** | .NET Anti-obfuscation |https://github.com/de4dot/de4dot|
| **JADX** | Android DEX Anti-obfuscation |https://github.com/skylot/jadx|
| **JEB** | Commercial Android/ARM decompiler |https://www.pnfsoftware.com/|
| **Miasm** | Reverse Engineering Framework (IR/Symbolic Execution/Deobfuscation) |https://github.com/cea-sec/miasm|
| **OLLVM deobfuscation** | Control flow flattening/fake control flow countermeasures | Perform recovery with angr/Triton symbols |

---

## Online analysis platform

| Platform | Description | Link |
|------|------|------|
| **VirusTotal** | Multi-engine scan + behavioral analysis |https://www.virustotal.com/|
| **Joe Sandbox** | Automated malware analysis |https://www.joesandbox.com/|
| **ANY.RUN** | Interactive online sandbox |https://any.run/|
| **Hybrid Analysis** | Free malware analysis |https://www.hybrid-analysis.com/|
| **Compiler Explorer** | View compiler output |https://godbolt.org/|
| **Dogbolt** | Multiple decompiler comparison (IDA/Ghidra/Binary Ninja) |https://dogbolt.org/|

---

## learning path

### Getting started (0-3 months)

1. [Reverse Engineering for Beginners](https://beginners.re/)— Free e-book
2. [Azeria Labs ARM Tutorial](https://azeria-labs.com/)— ARM Assembly Basics
3. [Nightmare](https://guyinatuxedo.github.io/)— CTF Reverse/Pwn Tutorial
4. [crackmes.one](https://crackmes.one/)— Reverse exercises

### Advanced (3-12 months)

1. [Practical Binary Analysis](https://practicalbinaryanalysis.com/)— Practical Binary Analysis
2. [The IDA Pro Book](https://nostarch.com/idapro2.htm)— In-depth use of IDA
3. [Malware Unicorn RE101](https://malwareunicorn.org/workshops/re101.html)— Malware Reverse Engineering
4. [pwnable.kr](http://pwnable.kr/)/ [pwnable.tw](https://pwnable.tw/)— Pwn Exercise

### advanced

1. [Modern Binary Exploitation](https://github.com/RPISEC/MBE)— RPI Course
2. [How to Hack Like a Ghost](https://nostarch.com/how-hack-ghost)— Advanced Penetration
3. [Windows Internals](https://docs.microsoft.com/en-us/sysinternals/)— Windows Kernel
4. Practical combat: analyzing real malware samples (MalwareBazaar)

---

## cheat sheet

| Cheat Sheet | Link |
|--------|------|
| x86/x64 command quick check |https://www.felixcloutier.com/x86/|
| ARM64 instruction quick check |https://developer.arm.com/documentation/ddi0602/latest|
| Linux syscall table (x64) |https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/|
| Linux syscall table (ARM64) |https://arm64.syscall.sh/|
| GDB Quick Search |https://darkdust.net/files/GDB%20Cheat%20Sheet.pdf|
| radare2 quick check | this package`radare2/references/cheatsheet.md`|
| IDA shortcut key |https://hex-rays.com/products/ida/support/freefiles/IDA_Pro_Shortcuts.pdf|
| Ghidra shortcuts | Ghidra built-in Help → Keyboard Shortcuts |
