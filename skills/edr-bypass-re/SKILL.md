---
name: edr-bypass-re
description: |
  Reverse defender implementation → red team targeted bypass. Reverse the EDR/Defender/AV hook table, ETW provider, and AMSI implementation first.
  Then write targeted unhook / indirect syscall / ETW patch / call stack spoof. Compare MITER ATT&CK T1562 Defense Evasion.
  Trigger keywords: EDR bypass, AV bypass, anti-virus, unhook, direct syscall, indirect syscall, Hell's Gate, Halo's Gate,
  Tartarus Gate、ETW patch、AMSI patch、call stack spoofing、hardware breakpoint Blindside、MITRE T1562、
  ntdll unhook, kernel callback, CrowdStrike bypass, Defender bypass, Sentinel One bypass, Elastic Defend,
  Sysmon circumvention, PPID spoof, Sleep mask, Process Hollowing, Reflective DLL.
---

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md` — Confirm that the operation of this skill is an authorized normal operation
2. `NOW`: Confirm whether the current task hits the scope of application of this skill
3. `NEXT`: Read `../tool-index.md` to verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, do not guess the path
5. `ACT`: Enter the first step of the "workflow" and execute it, do not stop in the confirmation state

# EDR bypass: reverse engineering from defender to red team bypass

> Only for authorized red team/confrontation exercises/own product testing, prohibited for use on unauthorized targets.

## Scope of application

Red Team/Adversarial Simulation uses this skill when delivering implants to authorized target hosts and evading modern EDR.

1. **Red Team/Purple Team/Confrontation Exercise** — Customer wants to evaluate the real detection capabilities of SOC and EDR
2. **Self-developed implant / C2 framework development** — Develop payloads for own product testing, which needs to bypass own or target EDR
3. **EDR Product Evaluation** — Objectively evaluate the detection coverage of a certain EDR under the premise that the compliance boundary has been confirmed
4. **CTF/Windows side breakthrough of offensive and defensive drills** — Stable execution on a hardened host is required during the competition

**Not applicable scenarios**:

- Antivirus manufacturers conduct a complete RE of their own products and issue business evaluation reports to customers (finding manufacturers to formally cooperate)
- Kill-free confrontation against unauthorized targets (illegal)
- Avoid killing common viruses and Trojans (this skill focuses on red team OPSEC and does not teach how to write malicious code)

### Division of labor with other skills

| Scene | What to use |
|------|--------|
| Full-link attack and defense (from external network to domain control) | `attack-chain/` |
| Internal network lateral / AD attack | `pentest-tools/network-attack-defense.md` |
| Require implant delivery via EDR on a specific host | **This skill** |
| Simple static anti-virus (obfuscation/packing) | `malware-analysis/` (reverse perspective) |

`attack-chain` focuses on the complete kill chain. This skill only focuses on the internal mechanism and targeted circumvention of **EDR, the opponent**.

## Core Principles

```text
Four Main Monitoring Faces of EDR Red Team Countermeasures
─────────────────────              ─────────────────────
User mode ntdll hook ◄──► unhook (Peruns Fart / fresh ntdll)
Indirect syscall / Hell's Gate
                                  hardware breakpoint Blindside

kernel callback         ◄──►   call stack spoof
(Ps/Cm/Ob series) Follow the legal trigger chain (not directly bypassing, cooperate with upstream stealth)

ETW telemetry           ◄──►   EtwEventWrite patch
(Microsoft-Windows-Threat-NtTraceControl off provider
Intelligence, etc.) AmsiContext synchronization processing

AMSI scan ◄──► AmsiScanBuffer patch (mov eax,0x80070057; ret)
(amsi.dll) hardware breakpoint bypass
reflective loads a copy of amsi.dll
```

Key insights:

- **EDR is not a black box** — key hooks/callbacks/providers can be reversed using IDA + windbg
- **Bypass techniques should be used in combination** — unhook alone cannot solve the ETW alarm, and AMSI patch alone cannot solve the syscall hook
- **The order is important** — first ETW patch → then AMSI patch → then unhook; if the order is wrong, EDR will receive the unhook alarm first
- **Modern EDR has regarded ETW + kernel callback as the main battlefield**, simple user mode unhook is no longer enough

## Workflow

### Step 1: Identify the EDR of the target host

```powershell
# List of common EDR/AV drivers
Get-Service | Where-Object {$_.Name -match 'CSAgent|SentinelAgent|elasticendpoint|esets|ekrn|MsMpEng|wdsvc|cyserver|sysmon|aswbidsagent'}

# List loaded minifilters
fltmc filters

# List registered kernel callbacks (requires windbg + kernel debugging / or PChunter / DRVHV)
# !object \Callback
# !pnpcallback / Process / Thread / Image
```

See the top of `references/hook-survey.md` for the EDR fingerprint table.

### Step 2: Extract hook table from EDR DLL

1. Attach to a process (any implemented process) that is injected with the EDR user-mode component
2. Dump the `.text` section of the current `ntdll.dll` in windbg
3. Do a diff with a clean `C:\Windows\System32\ntdll.dll` on the disk
4. The inconsistency is the hook point

Or use `pe-sieve` directly:

```powershell
pe-sieve64.exe /pid 1234 /shellc 3 /modules 3 /dir hooks_dump
```

See `references/hook-survey.md` for detailed methods.

### Step 3: Choose a bypass technology combination

| Defense Points | Recommended Detours |
|--------|---------|
| ntdll inline hook | indirect syscall + dynamic SSN (Halo's Gate) |
| ETW-TI provider | EtwEventWrite head patch |
| AMSI (PowerShell/.NET) | AmsiScanBuffer patch or HWBP |
| kernel callback | call stack spoof + go legit gadget |
| Sysmon ProcessCreate | PPID spoof + unbacked memory |

### Step 4: Implement in implant

The code skeleton can be found in `references/unhook-techniques.md` and `references/telemetry-blinding.md`.

### Step 5: Local sandbox verification

```powershell
# Deploy the target EDR trial version in an isolated environment (Defender can start by default)
# Enable Sysmon + olaf-config
sysmon64.exe -i sysmonconfig.xml

# Run implant to see if the following alarm sources are triggered:
#   - Defender AMSI
#   - ETW-TI
#   - Sysmon Event ID 1/7/8/10
#   - EDR console
```

### Step 6: Delivery

- Use legal software directory for file landing path
- PPID spoof to explorer.exe
- Cooperate with the initial access section in `attack-chain`

## Typical scenario

### Scenario 1: Deliver cobalt-strike-alike beacon through Defender + Sysmon

```text
Target: Windows 11 Enterprise + Defender (cloud scanning and killing on) + Sysmon (olaf configuration)
Requirement: beacon can callback after landing and does not trigger any alarm

Combination boxing:
  1. Shellcode encrypted storage, decrypted at runtime
  2. AMSI patch (if delivered via PowerShell)
  3. EtwEventWrite patch (disable ETW-TI)
  4. Indirect syscall + Halo's Gate (disable ntdll hook alarm)
  5. PPID spoof to explorer.exe
  6. Use Ekko/Foliage to encrypt its own memory during the sleep phase
```

### Scenario 2: Perform EDR sleep mask on an already implemented low-privilege shell

```text
Preface: medium IL shell has been obtained through phishing, EDR is monitoring
Risk: Beacon characteristics can be easily discovered by memory scanning if they stay for a long time.

solution:
  1. No more requests for new RWX memory
  2. Use Ekko during sleep:
       - WaitForSingleObjectEx + CreateTimerQueueTimer
       - Encrypt itself in the timer .text + flush the stack to all 0s
  3. Use ROP to restore during wake
  4. Use call stack spoof to prevent RtlCaptureStackBackTrace from seeing the beacon address.
```

##On-Demand Bootstrap

### Tool dependencies

| Tools | Purpose | Automatic installation |
|------|------|-----------|
| pe-sieve | Detect hooks/injections in the process | ✓ |
| API Monitor v2 | Dynamic observation of API calls and hooks | Semi-automatic (manual download) |
| SysWhispers3 | Generate direct/indirect syscall stub | ✓ (git clone + python) |
| Hell's Gate POC | Dynamic SSN parsing reference implementation | ✓ (git clone) |
| windbg + IDA | Static inverse EDR DLL / kernel callback | ✗(self-installed) |
| Sysmon + olaf config | Local verification environment | ✓ |

### Bootstrap command

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "&lt;SKILL_ROOT&gt;\skills\scripts\bootstrap-reverse.ps1" -Capability @('pe-sieve','syswhispers3','sysmon') -StartServices
```

## Routing context

**Upstream Entry**:

- `reverse-engineering/` — Need to understand the implementation of EDR DLL/driver first
- `attack-chain/` — Determines at which stage of the kill chain this skill is introduced

**Similar association**:

- `pentest-tools/network-attack-defense.md` — How to link with this skill when the intranet is horizontal
- `malware-analysis/` — Reverse perspective, see how the detector writes the rules
- `field-journal/` — write back experience after each actual practice

**Downstream Delivery**:

- Reference MITER ATT&CK **T1562 (Impair Defenses)**, T1562.001 (Disable or Modify Tools), T1562.006 (Indicator Blocking), T1055 (Process Injection), T1027 (Obfuscated Files or Information) when generating reports

## Legal Boundary Statement

- Only legally authorized red teams/confrontation exercises/own product testing
- Written authorization must be obtained before operation (SoW / Test Contract / SRC Scope Statement)
- May not be used for unauthorized purposes and shall not exceed the scope of authorization
- Report high-risk issues to customers immediately and follow responsible disclosure
- The real target information in all reports must be redacted (IP / host name / domain name / certificate placeholder)

## References

- Detailed hook survey: `references/hook-survey.md`
- unhook/syscall techniques: `references/unhook-techniques.md`
- ETW/AMSI/Anti-forensics: `references/telemetry-blinding.md`
- MITRE ATT&CK T1562：<https://attack.mitre.org/techniques/T1562/>


## Task completion self-test (MUST pass before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Am I using real tool paths based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and written back the Checklist items required by RULES?
