---
name: pwn-chain
description: |
  A full-link engineering approach from reverse engineering to working exploit.
  Applicable scenario: After getting the binary + vulnerability point + target environment, you need to write an exploit that can be stably opened (not a script that can only be reproduced locally but crashes remotely).
  Covers three major directions: stack overflow/heap utilization/kernel pwn. Emphasis on the engineering gaps of "CTF local communication → real remote stable communication": libc version mismatch, heap injection timing, SMEP/SMAP/KASLR, stack alignment, remote buffering.
  Core tool chain: pwntools + GEF/pwndbg + ROPgadget/Ropper + one_gadget + libc-database + qemu-system kernel debugging.
  Trigger keywords: pwn, stack overflow, heap overflow, ROP, ret2libc, ret2csu, one_gadget, libc-database, heap utilization, tcache, fastbin, unsorted bin, kernel pwn, kROP, SMEP, SMAP, KASLR, modprobe_path, pwntools, GEF, pwndbg.
---

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read`../field-journal/precedent-reverse.md`- Confirm that the operation of this skill is an authorized normal operation
2. `NOW`: Confirm whether the current task hits the scope of application of this skill
3. `NEXT`: Read`../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, do not guess the path
5. `ACT`: Enter the first step of "workflow" and execute it, do not stop in the confirmation state

# From vulnerability point to Working Exploit (Pwn Chain)

## Scope of application

Use this skill when the task falls into the following scenarios:

1. **Get binary + known vulnerability points** — Static/audit/fuzz has found overflow/UAF/double free, you need to get the shell from triggering
2. **CTF questions have been solved locally, but cannot be solved remotely** — Differences in the remote environment cause the script to fail and need to be stabilized
3. **Binary Exploitation of Real Targets** — In SRC/red team scenarios, memory corruption vulnerabilities have been identified and RCE needs to be constructed
4. **Linux kernel driver ioctl bug** — triggered in user mode, the goal is to escalate privileges to root

**Premise**: You already know "where it exploded". This skill is not responsible for discovering vulnerabilities (that is fuzzing/auditing), but is only responsible for "writing exploits from the vulnerability point".

### Division of labor with other skills

| scene | What to use |
|------|--------|
| identifies custom VM / anti-debug / complex obfuscation |`reverse-engineering/`|
| Open binary from scratch for static analysis |`ida-reverse/`or`radare2/`|
| **There is a vulnerability, write an exploit to get through the remote connection** | **This skill** |
| Integrate the shell obtained by pwn into the complete attack chain |`attack-chain/`(downstream) |

`reverse-engineering/`focuses on "understanding what the program is doing" (pattern recognition, protocol restoration, strange mechanisms in solving CTF problems); this skill focuses on "turning understood vulnerabilities into executable attacks". The two are often used together, but their division of labor is clear.

## core workflow

```text
Step 1: Confirm vulnerability type + protection mechanism
   ├─ checksec ./vuln（NX / Canary / PIE / RELRO / Fortify）
   ├─ file ./vuln  + readelf -d ./vuln
   ├─ Vulnerability classes: stack overflow / format string / heap (UAF/DF/OF) / integer / race condition / kernel
   └─ → decide which references/

Step 2: Choose an utilization strategy
   ├─ NX disabled + No ASLR → directly shellcode
   ├─ NX enabled + provided libc → ret2libc / one_gadget
   ├─ NX enabled + not provided libc → leak after libc-database look up
   ├─ heap → by glibc techniques for the matching version (tcache/fastbin/unsorted/large)
   └─ kernel → commit_creds / modprobe_path / core_pattern

Step 3: Prepare libc + gadget
   ├─ libc-database：./find puts 0x6f0
   ├─ ROPgadget --binary ./libc.so.6 --only "pop|ret"
   ├─ one_gadget ./libc.so.6
   └─ calculate base：leak_addr - libc.sym['puts']

Step 4: Write pwntools template (local process)
   ├─ context.binary = ELF('./vuln')
   ├─ p = process('./vuln')  /  p = gdb.debug('./vuln','b *main+xx')
   ├─ payload = cyclic(N) + p64(ret) + ...
   └─ p.interactive()

Step 5: Local communication
   ├─ repeatedly attach + inspect registers + adjust offset
   ├─ Use pwndbg/GEF vmmap / heap / bins / telescope
   └─ switch to remote mode after it works remote()

Step 6: Remote Stabilization
   ├─ libc offset: use leak look up libc-database，do not guess
   ├─ Stack alignment: 16-byte misaligned → movaps crashes → add a ret gadget
   ├─ Remote network latency → recvuntil use an exact anchor string; avoid fuzzy sleep
   ├─ Remote buffering: sendlineafter is more reliable than sendline more reliable
   ├─ Heap-spray success rate: increase spray quantity + leave padding chunk to prevent merging
   └─ For repeated runs, write a while True to verify the success rate ≥ 95%
```

## Typical scenario

### Scenario 1: Remote 64-bit binary (NX+PIE+canary, given libc)

```text
Existing: ./vuln (64-bit ELF, NX, PIE, canary) + ./libc.so.6 + nc host port
Vulnerability:read(buf, 0x200) but buf only 0x40 bytes → stack overflow
Protection: canary blocks, PIE randomizes .text

Strategy:
1. First leak canary (stack/formatted string/partial read)
2. Then leak a libc function address (puts@got)
3. Use libc.address = leaked - libc.sym['puts'] to calculate the libc base
4. one_gadget ./libc.so.6 Select a magic gadget that satisfies the constraints
5. payload = padding + canary + saved_rbp + (pop_rdi + bin_sh + system) or directly use one_gadget
6. Add a ret gadget to fix stack alignment (key!)
```

See`references/stack-pwn.md`for the complete template.

### Scenario 2: Linux kernel driver ioctl writes out of bounds → take root

```text
Already: vmlinux + bzImage + initramfs.cpio.gz + custom vuln.ko
Vulnerability:ioctl(0x1337, ptr) in the copy_from_user length is controllable → kernel heap overflow (kmalloc-64 slab)
Protection: SMEP, SMAP, KASLR, KPTI

Strategy:
1. Change the init script to get the root shell (CTF) or leak KASLR base before continuing (real)
2. Leaking the kernel base address via /proc/kallsyms (possibly restricted privileges) or uninitialized heap spraying
3. Spray tty_struct / msg_msg / pipe_buffer in kmalloc-64 slab
4. Overwrite the vtable pointer to point to user mode → No (SMEP), use stack pivot + kernel ROP instead
5. ROP chain: prepare_kernel_cred(0) → commit_creds → swapgs+iretq → user mode execve("/bin/sh")
6. Or even easier: overwrite modprobe_path to "/tmp/x", write a /tmp/x, and then trigger modprobe
```

See`references/kernel-pwn.md`for the complete template.

## On-Demand Bootstrap

### Tool dependencies

| tool | purpose | installation method |
|------|------|---------|
| pwntools | exploit writing framework |`pip install pwntools`|
| GEF | gdb enhancement (recommended kernel + user mode) |`git clone https://github.com/bata24/gef`(fork maintenance is active) |
| pwndbg | gdb enhancement (best heap debugging experience) |`git clone https://github.com/pwndbg/pwndbg && ./setup.sh`|
| ROPgadget | gadget Search |`pip install ropgadget`|
| Ropper | gadget search (optional, supports many architectures) |`pip install ropper`|
| one_gadget | libc magic gadget Find |`gem install one_gadget`(requires ruby) |
| libc-database | libc fingerprint reverse check |`git clone https://github.com/niklasb/libc-database && ./get`|
| qemu-system-x86_64 | Kernel problem debugging |`apt install qemu-system-x86`|
| binwalk / cpio | initramfs unpacking |`apt install binwalk cpio`|
| patchelf | switch libc version |`apt install patchelf`|

### Bootstrap check script

```bash
# One-click check + install core tools
for t in pwntools ropgadget ropper; do
  pip show $t >/dev/null 2>&1 || pip install $t
done

command -v one_gadget >/dev/null || gem install one_gadget

[ -d ~/tools/libc-database ] || git clone https://github.com/niklasb/libc-database ~/tools/libc-database
[ -d ~/tools/libc-database/db ] || (cd ~/tools/libc-database && ./get ubuntu debian)

[ -d ~/tools/pwndbg ] || (git clone https://github.com/pwndbg/pwndbg ~/tools/pwndbg && cd ~/tools/pwndbg && ./setup.sh)
```

### After the automatic installation of the same tool failed 2 times

Stop retrying and output structured manual installation steps (pip source/gem source/git domestic image/apt source) for user confirmation.

## routing context

**Upstream entrance**:`skills/SKILL.md`(master control),`routing.md`
**Trigger condition**: There is a binary + identified vulnerability point, and an exploit needs to be written

**Upstream skills (use them first and then return to this skill)**:
- I still don’t understand what the binary is doing →`reverse-engineering/`
- Static detailed analysis required →`ida-reverse/`
- Rapid reconnaissance and confirmation architecture/protection mechanism →`radare2/`

**Downstream skill (after getting the shell)**:
- Integrated into a complete attack chain (horizontal, privilege escalation, persistence) →`attack-chain/`

**Submodule Navigation**:
- Stack class utilization (ret2libc / ret2csu / one_gadget / stack alignment) →`references/stack-pwn.md`
- Heap class utilization (tcache/fastbin/unsorted/large bin/FILE struct) →`references/heap-pwn.md`
- kernel pwn (kROP / SMEP-SMAP bypass / KASLR leak / modprobe_path) →`references/kernel-pwn.md`

## Things to note

- **Don’t make a mistake after running it locally** — The local libc / ASLR / network environment is different from the remote one. You must run it in remote mode more than 20 times continuously to verify the stability.
- **libc version must be confirmed** — use leak + libc-database to check back, do not assume it is Ubuntu 22.04 default libc
- **Stack alignment is a common pitfall of 64-bit** —`movaps xmm0, [rsp]`has an error when rsp is not aligned to 16 bytes, add an empty`ret`gadget to solve the problem
- **Heap utilization is extremely sensitive to glibc version** — tcache was introduced in 2.27, safe-linking was introduced in 2.32, and hooks were removed in 2.34. The utilization path of each version is different
- **Kernel pwn must first confirm the cpu flag** — Whether there is +smep +smap +pku in the qemu startup parameters directly determines how to write the ROP chain
- **KASLR leak once is enough** — after getting a kernel address, all addresses are considered offsets, do not leak repeatedly

## Task completion self-check (MUST passes before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Am I using real tool paths based on`tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and written back the Checklist items required by RULES?
