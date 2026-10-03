# EDR Hook Survey Quick Facts

> Only for authorized red team/confrontational exercises/own product testing, prohibited for use on unauthorized targets.

This document summarizes the monitoring points of mainstream EDR/AV in user mode and kernel mode, so that the red team can quickly locate "what to deal with" during the reconnaissance phase.

## 1. Quick check of mainstream EDR fingerprints and hook patterns

| Manufacturer/Product | User mode component | Kernel driver | Main monitoring surface |
|------------|-----------|---------|-----------|
| CrowdStrike Falcon | `CSFalconService.exe`, `CSAgent.sys` Inject into target process | `CSAgent.sys`, `CSBoot.sys` | Heavy kernel callback + ETW-TI; fewer user-mode hooks (cloud check) |
| Microsoft Defender for Endpoint (MDE) | `MsMpEng.exe`, `MpClient.dll` | `WdFilter.sys`, `WdBoot.sys`, `WdNisDrv.sys` | AMSI + ETW-TI + ntdll inline hook + kernel callback comprehensive |
| SentinelOne | `SentinelAgent.exe`, `SentinelHelperService.exe` | `SentinelMonitor.sys`, `SentinelDeviceControl.sys` | ntdll user mode hook heavy + kernel callback + own ETW provider |
| Elastic Defend (formerly Endpoint Security) | `elastic-endpoint.exe` | `elastic-endpoint-driver.sys` | Main ETW + a small amount of ntdll hook, cooperate with Elastic Agent to upload |
| ESET | `ekrn.exe`, `eamsi.dll` | `eamonm.sys`, `epfwwfp.sys` | There are many user-mode hooks (NtCreateFile / NtOpenProcess, etc.) |
| Sophos Intercept X | `SophosFileScanner.exe`, `SophosNtpService.exe` | `SophosED.sys`, `hmpalert.sys` | ntdll hook + HMPA memory protection + kernel callback |
| Kaspersky | `avp.exe`, `klif.sys` | `klif.sys`, `klhk.sys` | Heavy user mode hook + KLIF own micro filter + network filter driver |
| Trend Micro Apex One | `TmListen.exe`, `TmCCSF.dll` | `tmcomm.sys`, `tmactmon.sys` | User mode hook + behavior monitoring driver |
| Carbon Black | `RepMgr.exe`, `RepWAV.exe` | `ParityDriver.sys` | partial core callback + ETW |

### Quick fingerprint script

```powershell
$edrSigs = @{
    'CSAgent'           = 'CrowdStrike Falcon'
    'SentinelAgent'     = 'SentinelOne'
    'elastic-endpoint'  = 'Elastic Defend'
    'ekrn'              = 'ESET'
    'MsMpEng'           = 'Microsoft Defender'
    'SophosFileScanner' = 'Sophos Intercept X'
    'avp'               = 'Kaspersky'
    'TmListen'          = 'Trend Micro Apex One'
    'cb'                = 'Carbon Black'
}

Get-Process | ForEach-Object {
    foreach ($k in $edrSigs.Keys) {
        if ($_.ProcessName -match $k) {
            "[+] $($edrSigs[$k]) detected: $($_.ProcessName) (PID $($_.Id))"
        }
    }
}

Get-ChildItem 'C:\Windows\System32\drivers\*.sys' |
    Where-Object { $_.Name -match 'CSAgent|Sentinel|elastic|eam|WdFilter|Sophos|klif|tmcomm|Parity' } |
    Select-Object Name, VersionInfo
```

## 2. User mode ntdll hook key functions

EDR almost certainly exports `ntdll.dll` hook (grouped by ATT&CK behavior):

| Function | Monitored behavior | ATT&CK |
|------|-----------|--------|
| `NtCreateThreadEx` | Remote thread injection, QueueUserAPC injection | T1055.002 / T1055.004 |
| `NtAllocateVirtualMemory` | shellcode application RWX memory | T1055 |
| `NtAllocateVirtualMemoryEx` | Cross-process memory application (Win10+ new API) | T1055 |
| `NtProtectVirtualMemory` | Change page permissions RW→RX | T1055 |
| `NtWriteVirtualMemory` | Cross-process writing shellcode | T1055.012 |
| `NtMapViewOfSection` | section-based injection (Process Doppelganging / Ghosting) | T1055.013 |
| `NtCreateSection` | with MapViewOfSection | T1055.013 |
| `NtOpenProcess` | Open the target process and get handle | T1057 |
| `NtQueueApcThread` / `NtQueueApcThreadEx` | APC injection | T1055.004 |
| `NtCreateProcess` / `NtCreateProcessEx` / `NtCreateUserProcess` | Create child process (including PPID spoof) | T1106 |
| `NtSetContextThread` | Change thread context (thread hijack injection) | T1055.003 |
| `NtResumeThread` | Restore the thread after injection | T1055 |
| `NtQuerySystemInformation` | enumeration process / driver / handle | T1057 / T1082 |
| `NtAdjustPrivilegesToken` | Elevate privileges to obtain SeDebugPrivilege, etc. | T1134 |
| `NtLoadDriver` | Load kernel driver (BYOVD) | T1543.003 |

### Verify that the hook exists

```powershell
# Simple: disassemble the disk ntdll and the ntdll of the current process and diff
# 1. Get disk ntdll
copy C:\Windows\System32\ntdll.dll C:\temp\ntdll_clean.dll

# 2. Attach any process in windbg and export the .text section of the current ntdll
# .writemem c:\temp\ntdll_live.bin ntdll!.text L?<size>

# 3. Use IDA / radare2 to disassemble NtAllocateVirtualMemory. Normally it should be:
#    mov r10, rcx
#    mov eax, <SSN>
#    test byte ptr [...]
#    jne ...
#    syscall
#    ret
# If the first item becomes jmp <a certain address>, that is a hook
```

## 3. Kernel callback monitoring point

Common kernel callbacks registered by EDR (can always be unregistered by the BYOVD route in `attack-chain`, but at a high cost):

| API | Registered callback timing | Defender use |
|-----|--------------|-----------|
| `PsSetCreateProcessNotifyRoutineEx` | process creation/exit | intercept suspicious child process |
| `PsSetCreateThreadNotifyRoutine` | Thread creation/exit | Detect remote thread injection |
| `PsSetLoadImageNotifyRoutine` | DLL/EXE loaded into arbitrary process | Module integrity/unsigned interception |
| `CmRegisterCallback` / `CmRegisterCallbackEx` | Registry operation | Persistence detection |
| `ObRegisterCallbacks` | `OpenProcess` / `OpenThread` handle request | Prevent LSASS handle acquisition (T1003.001) |
| `MmRegisterPhysicalMemoryCallback` | Physical memory mapping | Anti-DMA / Memory Forensics |
| `IoRegisterFsRegistrationChange` | file system registration | minifilter collaboration |
| `KeRegisterNmiCallback` | NMI (rarely used for EDR) | Abnormal monitoring |
| `EtwRegister` (kernel side) | kernel ETW report | and ETW-TI symbiosis |

### Enumerate registered callbacks using windbg

```text
0: kd> dx -r1 nt!PspCreateProcessNotifyRoutine
0: kd> dx -r1 nt!PspCreateThreadNotifyRoutine
0: kd> dx -r1 nt!PspLoadImageNotifyRoutine

0: kd> !object \Callback
0: kd> !object \Callback\ProcessObject
```

Or use tools such as PChunter / DRVHV to visually view the callback list for ordinary users.

## 4. Static dump hook table (IDA + windbg process)

### Process A: Single process comparison

```text
1. Find a process that has been injected into a user-mode component by EDR (any surviving process)
2. windbg attach (-pn target.exe)
3. lm m ntdll → get the module base address
4. .writemem c:\temp\ntdll_live.bin ntdll+0x0 L?<image size>
5. Copy C:\Windows\System32\ntdll.dll to c:\temp\ntdll_disk.dll
6. Load two files in IDA and jump to NtAllocateVirtualMemory:
- disk: standard prologue
- live: the first jmp <0x7FFE000000xx>
7. Follow the jmp target address → that is the trampoline of EDR, dump it out
8. Enter trampoline to see which DLL it ends up in, and confirm the EDR module name
```

### Process B: Batch hook table generation

Use `HookHunter` or write your own script:

```powershell
# pseudo workflow, see the script mentioned in references for details
$disk = Get-Content C:\Windows\System32\ntdll.dll -Encoding Byte
$live = # Get it via OpenProcess + ReadProcessMemory
# Compare the first 16 bytes of each export in the .text section
```

## 5. pe-sieve automatic detection

`pe-sieve` is the first choice for reconnaissance EDR hook and implant self-test:

```powershell
# basic scan
pe-sieve64.exe /pid 1234

# Recommended combination (including shellcode and hook detection)
pe-sieve64.exe /pid 1234 /shellc 3 /modules 3 /imp 3 /data 3 /dir hooks_dump

# Key parameters:
#   /shellc N shellcode scan level (0-3)
#   /modules N module integrity check (0-3)
#   /imp N IAT hook check
#   /data N data segment scan
#   /dir <path> dump output directory
```

The output will generate the `*.tag` file under `hooks_dump/<pid>.<name>/`, listing the hook addresses:

```text
modified_modules.tag example:
71f10000;ntdll.dll
71f1a3b0;hook;jmp_far
71f1c020;hook;jmp_near
```

It can be directly fed to IDA and jumped to the corresponding RVA for subsequent analysis.

### Embed pe-sieve (self-test) in the implant

In actual combat, `pe-sieve` is often compiled into lib (`libpe-sieve`), so that the implant can self-check when it starts: if ntdll has a hook, the unhook process will be triggered; if you find that you have been hooked, you should be careful, maybe in the sandbox.

## 6. API Monitor v2 dynamic observation

API Monitor v2 (Rohitab) is suitable for viewing when and where EDR inserts hooks in the lab:

```text
1. Start API Monitor v2 (administrator)
2. API Filter check:
     - NT Native API → Memory Management
     - NT Native API → Process and Thread
- Windows Defender/AMSI (if visible)
3. Monitor New Process → Select implant test sample
4. Observe:
- NtAllocateVirtualMemory calling sequence
- Whether it is relayed by EDR DLL
5. Check which EDR DLLs are injected by LoadLibrary in the Modules tab
```

## 7. Common EDR DLL (user mode) quick check

| DLL | Manufacturer | Remarks |
|-----|------|------|
| `umppc*.dll` | Microsoft Defender | MpClient userland |
| `mpoav.dll` | Microsoft Defender | AMSI provider |
| `aswAMSI.dll` | Avast | AMSI provider |
| `eamsi.dll` | ESET | AMSI provider |
| `IDPMServiceClient.dll` | Sophos | HMPA Injection |
| `klsihk64.dll` | Kaspersky | Inject into the target process |
| `CrowdStrike.Sensor.dll` | CrowdStrike | Old version, the new version mainly relies on the kernel |
| `SentinelInjection64.dll` | SentinelOne | User mode injection |
| `TmUmEvt64.dll` | Trend Micro | Behavior Monitoring |

After confirming the target EDR, decide which DLL to reverse to get the hook table.

## Reference link

- pe-sieve：<https://github.com/hasherezade/pe-sieve>
- HollowsHunter：<https://github.com/hasherezade/hollows_hunter>
- API Monitor v2：<http://www.rohitab.com/apimonitor>
- MITRE ATT&CK T1562：<https://attack.mitre.org/techniques/T1562/>
- MITRE ATT&CK T1055：<https://attack.mitre.org/techniques/T1055/>
- ired.team EDR notes：<https://www.ired.team/offensive-security/defense-evasion>

## Route callback

After completing the hook investigation, return to Step 3 of `SKILL.md` to select the bypass technology combination, and then execute `references/unhook-techniques.md` and `references/telemetry-blinding.md`.
