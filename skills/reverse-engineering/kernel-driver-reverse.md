# Kernel driver reverse reference

> Covers Windows/Linux kernel driver reverse engineering, Rootkit analysis, and C/C++ binary pattern recognition.

---

## Windows driver reverse engineering

### Drive type

| Type | Characteristics | Analysis focus |
|------|------|---------|
| WDM (Windows Driver Model) | Old-school driver, manual IRP management | DriverEntry → Device creation → Dispatch routine |
| KMDF (Kernel Mode Driver Framework) | Modern framework, event-driven | EvtDriverDeviceAdd → Queue → I/O callback |
| WDF (Windows Driver Foundation) | KMDF + UMDF collectively | See WdfDriverCreate call |
| Minifilter | File system filter driver | FltRegisterFilter → Pre/Post callback |

### WDM driven analysis process

```text
1. Find DriverEntry (entry point)
   - IDA automatically recognizes it, or search for IoCreateDevice / IoCreateSymbolicLink

2. Find device names and symbolic links
- IoCreateDevice → DeviceName (such as \Device\MyDriver)
- IoCreateSymbolicLink → SymLink (such as \DosDevices\MyDriver)

3. Find the Dispatch routine
   - DriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = DispatchIoctl
   - This is the entry point called by the user state through DeviceIoControl

4. Analyze IOCTL handling
   - switch(IoControlCode) distributes different functions
   - IOCTL encoding: CTL_CODE(DeviceType, Function, Method, Access)
   - Method: METHOD_BUFFERED / METHOD_IN_DIRECT / METHOD_OUT_DIRECT / METHOD_NEITHER

5. Find loopholes
   - User-controllable buffer unverified length → overflow
   - METHOD_NEITHER directly uses the user pointer → arbitrary reading and writing
   - IOCTL permissions not checked → callable by unprivileged users
```

### IOCTL encoding analysis

```python
# Parse IOCTL code
def decode_ioctl(code):
    device_type = (code >> 16) & 0xFFFF
    access = (code >> 14) & 0x3
    function = (code >> 2) & 0xFFF
    method = code & 0x3
    
    methods = {0: "BUFFERED", 1: "IN_DIRECT", 2: "OUT_DIRECT", 3: "NEITHER"}
    access_types = {0: "ANY", 1: "READ", 2: "WRITE", 3: "READ|WRITE"}
    
    return f"DevType=0x{device_type:X} Func=0x{function:X} Method={methods[method]} Access={access_types[access]}"

# Example
decode_ioctl(0x80002034)
# DevType=0x8000 Func=0x80D Method=BUFFERED Access=ANY
```

### IDA plugin

| Plug-in | Purpose | Link |
|------|------|------|
| **Driver Buddy Reloaded** | Automatically identify IOCTL, Dispatch, device name | https://github.com/VoidSec/DriverBuddyReloaded |
| **WinDbg + IDA** | Kernel debugging + static analysis cooperation | Built-in |
| **FLIRT/Lumina** | Identify WDK library functions | IDA built-in |

### Reference article

- [Windows Drivers RE Methodology (VoidSec)](https://voidsec.com/windows-drivers-reverse-engineering-methodology/) — The most complete WDM driver reverse engineering methodology
- [Driver Reversing 101](https://eversinc33.com/posts/driver-reversing.html) — WDM vs KMDF comparison
- [Methodology of Reversing Vulnerable Killer Drivers](https://whiteknightlabs.com/2025/10/28/methodology-of-reversing-vulnerable-killer-drivers/) — Vulnerability driver analysis

---

## Linux kernel module reverse engineering

### LKM (Loadable Kernel Module) structure

```text
Key functions:
- init_module / module_init → executed when the module is loaded
- cleanup_module / module_exit → executed when the module is uninstalled

Key structures:
- struct file_operations → open/read/write/ioctl of character device
- struct net_device_ops → network device operations
- struct block_device_operations → block device operations
```

### Analysis process

```text
1. Confirm it is a kernel module
   file module.ko → "ELF 64-bit ... relocatable" (note that it is relocatable, not executable)

2. Find the init/exit function
   readelf -s module.ko | grep -E "init_module|cleanup_module"
   Or find module information in .modinfo section

3. Find the file_operations structure
   Search register_chrdev/cdev_add/misc_register
   → Find the fops structure → Locate the ioctl/read/write handler function

4. Analyze ioctl processing
   unlocked_ioctl / compat_ioctl function
   → switch(cmd) distribution

5. Looking for Rootkit Behavior
   - Modify sys_call_table → syscall hook
   - Modify /proc file system → hide processes/files
   - Register netfilter hook → Hide network connection
   - Modify VFS layer → Hidden files
```

### Rootkit Common Technologies

| Technology | Characteristics | Detection Methods |
|------|------|---------|
| syscall table hook | Modify `sys_call_table` entries | Compare in-memory table to on-disk vmlinux |
| VFS hook | Modify the `file_operations` function pointer | Check whether the fops pointer points outside the kernel code segment |
| Netfilter hook | `nf_register_net_hook` | Traverse the netfilter hook linked list |
| kprobe/ftrace hook | Register kprobe or ftrace callback | Check ftrace registration list |
| eBPF rootkit | Load malicious BPF program | `bpftool prog list` |
| DKOM | Directly modify the kernel object (process linked list) | Traverse the task_struct linked list and compare /proc |

### tool

| Tools | Purpose |
|------|------|
| `crash` | Kernel dump analysis |
| `volatility3` | Memory forensics (Linux profile) |
| `dmesg` / `journalctl` | Kernel log |
| `lsmod` / `/proc/modules` | List of loaded modules |
| `modinfo` | Module meta-information |
| `strace` | System call tracing (user mode perspective) |

---

## C/C++ reverse pattern recognition

### Common patterns in C language

| Source code mode | Disassembly features |
|---------|-----------|
| `if-else` | `cmp` + `jcc` (conditional jump) |
| `switch-case` | Jump table (`jmp [rax*8 + table]`) or continuous `cmp` |
| `for` loop | `cmp` + `jl/jle` + loop body + `inc/add` + `jmp` jump back |
| `while` loop | Conditional judgment at the top of the loop |
| `do-while` | Conditional judgment at the bottom of the loop |
| Function pointer call | `call rax` or `call [reg+offset]` |
| `struct` access | `[reg+fixed offset]` (such as `[rdi+0x10]`) |
| `malloc` + use | `call malloc` → the return value is stored in the register → subsequent access using the register + offset |
| String comparison | `call strcmp` or `repe cmpsb` |

### C++ specific modes

| Source code mode | Disassembly features |
|---------|-----------|
| **Virtual function call** | `mov rax, [rcx]` (get vtable) → `call [rax+offset]` (call virtual function) |
| **Constructor** | Allocate memory → Write vtable pointer → Initialize members |
| **Destructor** | Clean up members → may call `operator delete` |
| **this pointer** | The first parameter (rcx/rdi) is the object pointer |
| **Inheritance** | The vtable contains parent class virtual functions + subclass overrides |
| **Multiple inheritance** | There are multiple vtable pointers in the object (different offsets) |
| **RTTI** | The vtable is preceded by the `type_info` pointer |
| **Exception handling** | `__cxa_throw` / `_CxxThrowException` |
| **STL container** | `std::vector`: `{begin, end, capacity}` three-pointer structure |
| **std::string** | Small string optimization (SSO): short string inlining, long string heap allocation |

### vtable reverse method

```text
1. Find vtable
   - Search a contiguous array of function pointers (in the .rodata or .rdata section)
- `mov [rcx], offset vtable` is written into the vtable pointer in the constructor

2. Determine class hierarchy
   - The first -8 offset of the vtable is usually the RTTI pointer (if not stripped)
   - Multiple vtables share first few entries → inheritance relationship

3. Mark virtual functions
   - vtable[0] is usually a destructor (or deleting destructor)
- is subsequently marked by offset: vtable[1] = func1, vtable[2] = func2...

4. Working in IDA
   - Create struct at vtable address (each field is a function pointer)
- Add a comment to `call [rax+offset]` to indicate the virtual function called
```

### Structure recovery

```text
Method 1: Inferring from access patterns
  mov eax, [rdi+0x00]  → field_0: int/ptr (4/8 bytes)
  mov ecx, [rdi+0x08]  → field_8: int/ptr
  movss xmm0, [rdi+0x10] → field_10: float

Method 2: Infer from sizeof
  call malloc(0x30) → structure size 0x30 (48 bytes)
  
Method 3: Infer from constructor
  The constructor will initialize all fields → field types and offsets are clear at a glance

Method 4: Use IDA's "Create struct" function
Select access mode → Edit → Struct → Create struct from selection
```

---

## Common compiler characteristics

| Compiler | Identifying Features |
|--------|---------|
| MSVC | `_security_cookie` check, `__fastcall` calling convention, Rich Header |
| GCC | `__stack_chk_fail`、`-fstack-protector`、`.note.GNU-stack` |
| Clang/LLVM | Similar to GCC but different optimization mode, `__asan_*` (if sanitizer is turned on) |
| MinGW | GCC features + Windows API calls |
| AOSP Clang | Android-specific `__android_log_print`, PGO flags |

### Optimization level identification

| Optimization level | Features |
|---------|------|
| -O0 | Lots of redundant movs, every variable on the stack, functions not inlined |
| -O1 | Basic optimization, some variables in registers |
| -O2 | Loop unrolling, function inlining, tail call optimization |
| -O3 / -Os | Radical inlining, vectorization (SIMD), difficult to read code |
| PGO | Hot path optimization, cold code separation into `.text.cold` |
| LTO | Cross-module inlining, global dead code elimination |

---

## Kernel debugging environment

### Windows

```text
Debugger: WinDbg Preview
Connection method: network debugging (recommended) or serial port

Debugged machine settings:
bcdedit /debug on
bcdedit /dbgsettings net hostip:192.168.x.x port:50000

Debugging machine connection:
WinDbg → File → Attach to Kernel → Net → Port:50000 Key:xxx

Commonly used commands:
!analyze -v          # Automatically analyze crashes
lm                   # List loaded modules
!drvobj \Driver\xxx  # View driver objects
dt nt!_DRIVER_OBJECT # show structure
bp module!function   # Lower breakpoint
```

### Linux

```text
Debugger: GDB + QEMU or kgdb

QEMU kernel debugging:
qemu-system-x86_64 -kernel bzImage -s -S ...
gdb vmlinux -ex "target remote :1234"

Commonly used commands:
info threads         # kernel thread
lx-symbols           # Load kernel symbols (requires scripts/gdb/)
p init_task          # Check the init process
lx-dmesg             # kernel log
```

---

## Agent Action Anchor (Issue #65 U–AV)

Aligned with `references/nonpe-format-cookbook.md` §5 (short list, does not replace the above process):

| ID | Action | Evidence |
|----|------|----------|
| AG | `DriverEntry` short → scan `MajorFunction` non-empty slot, priority DEVICE_CONTROL/CREATE | `E-driver-irp-handlers` |
| AH | Create IOCTL control code → handler table and METHOD_* | `E-driver-ioctl` |
| AI | Suspected BYOVD: Compare the public vulnerable driver list; name/hash/signature and calling intention; **Do not write exploit steps** | `E-driver-byovd` |

## Reference resources

| Resources | Description | Links |
|------|------|------|
| VoidSec driver reverse methodology | Windows WDM driver complete analysis process | https://voidsec.com/windows-drivers-reverse-engineering-methodology/ |
| Elastic Rootkit Series | Linux Rootkit Classification + Detection | https://security-labs.elastic.co/security-labs/linux-rootkits-1-hooked-on-linux |
| Driver Buddy Reloaded | IDA driver analysis plug-in | https://github.com/VoidSec/DriverBuddyReloaded |
| LOLDrivers | List of known vulnerable drivers | https://www.loldrivers.io/ |
| Windows Driver Samples | Microsoft official driver samples | https://github.com/microsoft/Windows-driver-samples |
| Linux Kernel Module Programming | Kernel module development tutorial | https://sysprog21.github.io/lkmpg/ |
| Trail of Bits - Devirtualizing C++ | vtable reverse method | https://blog.trailofbits.com/2017/02/13/devirtualizing-c-with-binary-ninja/ |
