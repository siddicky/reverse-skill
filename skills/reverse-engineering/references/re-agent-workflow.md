# RE Agent workflow latch (static ↔ dynamic)

> Source inspiration: binary-re stage division, community RE skill (Frida/r2/Ghidra/IDA cycle), Cerberus three-headed ring (static/dynamic/instrumentation)  
> Issue #65 Increment: IAT fixes, six-stage mapping, .NET/DLL·SYS equivalent paths; user command viability latch; bypass patches 6–10; anti-debugging/obfuscation recipes A–T; non-PE multi-format recipes U–AV (2026-08-12)  
> Applicable to: `reverse-engineering/`, `ida-reverse/`, `radare2/`, `malware-analysis/`, handover with cre role

## 0. start

```text
□ scope.md: offline sample path or authorized device/target machine
□ tool-index: file/strings/r2/ida/frida and other actual paths
□ Role: cre (ops/role-map)
```

## 0.1 Transition handoff（decision delta）

The full case context is not re-injected between stages. `scope.md` / `workitems.md` / Evidence remains authoritative; `timeline.md` only carries transition delta:

1. At the end of the stage/turn, only write `decision_delta` that really changes the subsequent action; write `[]` if there is no change.
2. unchanged route/auth/scope/network profile/tool ​​state/hypothesis Only put `carry_forward_refs`, the consumer reads by reference, and does not re-serialize/emit.
3. `decision_delta` is not a complete state; the consumer must first inherit refs and then apply delta.
4. Only stop at the next-step menu when two or more evidence-supported branches lead to different next actions; deterministic gates advance directly.

Example: When the Triage is completed and the only legal next step is Static, the transition only needs `decision_delta: [phase=triage->static]` + `carry_forward_refs: [scope.md, evidence/E-triage.md]`.

## 0.5 User command feasibility latch (Issue #65)

**Principle**: Obey the user's **goals** and do not blindly follow the user's **step sequence**. The premise must be stated and confirmed before jumping; the mandatory steps after confirmation must be done, and the quality of the evidence must be honestly marked.

| Situation | Agent MUST |
|------|------------|
| The user wants to do X, and the current status can be **valid** Evidence | Execute X, update Evidence |
| The user wants to do X, but there is a **known blocking prerequisite** (e.g., the file is packed and the static IAT is unreadable) | **Do not** pretend that a meaningful IAT review was completed; ① state the blocker in one sentence; ② recommend an order (unpack/repair the IAT first, or capture the API dynamically); ③ **ask the user to confirm** whether to “inspect the current import table anyway” or “follow the recommended order” |
| The user clearly **mandatory** the current step (if not unpacked, also check IAT) | Execute and record Evidence, MUST mark `quality=unreadable` / `packed` (or equivalent); **Prohibited** based on this conclusion such as "no network capability" |
| User accepts the recommended order | Do the prerequisite steps first; do X automatically or upon request after completion; **It is prohibited** to use prerequisite steps (such as unpacking) **Pretend** "Import table check completed" |

**Relationship with "Redo X"**: Redoing unpacking is a **prerequisite** for importing tables, not a **replacement** for importing tables.

Typical conflict: The user says "Don't unpack first, look at the import table first" on the packer sample → The packer often tamperes with the import directory/encryption descriptor, and the static table is meaningless → Follow the "blocking prerequisite" line of this table, you must not unpack silently and pretend to be, and you must not silently hand over the table when it is completed.

## 1. Triage (5–15 minutes · mandatory starting point)

```text
□ Calculate sample Hash (MD5/SHA256) → Unique ID
□ Identify file types: EXE / DLL / SYS / ELF / Mach-O / .NET / script (bat/ps1/vba) / JS / APK, etc.
□ Non-PE/script/APK/driver-specific: see §3.4 and `references/nonpe-format-cookbook.md` (U–AV)
□ file / DIE / entropy / shell features (PEiD / DIE / Exeinfo, etc.)
□ Architecture: x86/x64/ARM; compiled language clues (VC++/Delphi/.NET/Go/Rust)
□ Packing type clues: UPX / ASPack / VMProtect / Themida / unknown obfuscation
□ strings / rabin2 -z pick up leaks
□ MUST import/export anchor points (see "Import table hard door and equivalent path" below); if the user jumps in and has a shell → go first §0.5
□ Output: E-triage (MUST include imports or equivalent anchor point classification summary, including quality annotation if applicable) + hypothesis list
```

**Phase latch (Triage → Static/Dynamic)**: Imports not documented in the E-triage **or** MUST NOT enter Dynamic (unless an IAT repair failure has been logged and dynamic bypass is selected, see §1.2), nor MUST NOT claim "Basic Triage Complete" before the legal equivalent anchor summary. When parsing fails, the failure output must still be written to Evidence and must not be skipped. When the user requests "redo import table check", MUST redo the imports/equivalent step itself (or complete the prerequisite after §0.5 negotiation first), and it is forbidden to change other analysis steps to pretend to be.

### 1.1 Import table hard door and equivalent path

| sample type | MUST anchor point (Evidence) | description |
|----------|----------------------|------|
| native PE/ELF/Mach-O (IAT readable) | `E-imports` / `E-triage-imports`: import taxonomy summary | `rabin2 -i` / IDA imports / equivalent |
| DLL / SYS / shared library | **Parallel** `E-imports` + `E-exports` (`rabin2 -i` + `rabin2 -E`) | The export table priority is the same as the import table (external entrance) |
| .NET hosting (no legacy IAT) | **Equivalent paths**: dnSpy/IL/Metadata/Assembly References and Sensitive API Summary → Still writes `E-imports` or `E-triage-imports` semantic slots | **forbidden** Empty due to "no IAT"; dnSpy view = native "lookup import table" |
| The imported table parsing failed/is empty/packed fancy table | is still recorded as failed or the fancy table is output as Evidence and marked `quality` | must not be skipped silently; the fancy table must not support the ability to negate the conclusion |

**Clean import table warning (MUST reminder)**: If the import table is "too clean" (only basic DLLs such as kernel32/ntdll, almost no business API), it is highly suspicious of `LoadLibrary` + `GetProcAddress` dynamic loading → indicate the suspicion in Evidence, and **SHOULD** transfer to the Dynamic grab memory API; you must not rely solely on static IAT to claim "no network/no file capabilities".

**High-risk API combinations (Patch 8 · SHOULD)**: When the import table is too long, **Malicious Combination Clustering** will be output first, and pure system basic calls will be filtered. Examples (non-exhaustive):

- High-risk cluster: `FindWindowA/W` + `WriteProcessMemory` + `CreateRemoteThread` (injection)
- High-risk cluster: `CryptEncrypt` / `CryptAcquireContext` + a large number of `FindFirstFile` / `DeleteFile` (ransomware prone)
- High-risk cluster: `InternetOpen` / `WinHttp` / `URLDownloadToFile` + persistence API (`RegSetValue` / `CreateService`)
- `CreateFile` / `ReadFile` alone are mostly benign noise, unless they co-occur with the upper cluster

### 1.2 Unpacking and IAT processing (high risk bifurcation · Issue #65)

```text
Branch A: Shellless/.NET Hosting
→ Go directly to §2 Static (.NET takes the equivalent anchor point)

Branch B: shelled/strongly obfuscated
Step 1: Try to unpack (automatic unpacking machine / manually find OEP) - must be in an authorized and isolated environment
Step 2: Try to repair IAT
Tools: x86 → ImportREC (or equivalent); x64 → Scylla (or equivalent). Disable 64-bit samples from importREC.
Case B1: The repair is successful and parsable → remember E-imports (after repair) → §2 Static
Situation B2: ImportREC/Scylla reports an error, fails to run after repair, or IAT is completely garbled (VMP/encrypted shell)
→ [IAT repair iron law] Terminate immediately and continue static IAT repair
→ MUST record E-iat-repair-fail (command, tool, failure phenomenon, decision to transfer status)
→ Go directly to §3 Dynamic: API breakpoints/hardware execution breakpoints/memory search, capture and import
→ This does not count as "skipping the import table": the import table path has been tried and recorded Evidence
Situation B3 (Patch 6): Double-click crash/blue screen after unpacking and repairing IAT (suspicious file CRC/size self-check)
→ Give up and continue static file repair; remember E-self-check-crash or merge into E-iat-repair-fail
→ Go to §3 Dynamic: Disconnect CreateFile/GetFileSize/Hash-related APIs and locate verification bypass points
```

**IAT repair rule (MUST)**: Try automatic/semi-automatic repair first; once the repair tool reports an error or the program cannot run after repair, **stop immediately** and work on the static import table, switch to dynamic debugging, and use API breakpoints (such as `bp CreateFile` / critical network API) to capture the imported function at runtime.

## 2. Static (basic static anchor point → deep digging)

| Tools | When |
|------|------|
| radare2 / rabin2 | fast function/import/string (imports have been completed in Triage MUST or failed bypass has been recorded) |
| IDA / Ghidra (MCP or headless) | Deep digging, cross-reference, type; survey stage review imports classification |
| jadx / dnSpy | Android / .NET |
| OLLVM documentation | Control flow flattening suspicion |

```text
□ Confirm that E-imports / E-triage contains the import table or equivalent anchor point Evidence (if missing, fill it first, and it is prohibited to post it later)
□ If DLL/SYS: Confirm that E-exports have been recorded
□ Sensitive API grouping + high-risk combination clustering (patch 8)
□ Hard-coded domain name/IP/URL string; whether the resource section hides Payload
□ Locate key functions (encryption/verification/network/authorization) → write address/symbol Evidence
□ One road is blocked → Change tools (IDA↔r2↔Ghidra)
□ Time box (patch 9 · SHOULD default): static deep digging for about 15 minutes and still no critical path → forced transfer to §3 Dynamic (user/task can override duration)
```

**When there is no MCP**: You can export the decompiled text for re-analysis (compare P4nda0s reverse-skills / IDA-NO-MCP idea), and still write the Evidence path.

## 3. Dynamic (cross-validation loop area)

Core concept: **Static provision of clues → Dynamic verification → Verification stuck → Return to static review** (no fixed unique order).

### 3.0 Breakpoint Start (Patch 7 + 10 · MUST order)

Before starting the sample with the user-mode debugger (x64dbg, etc.), press the "four-stage rocket" to preset breakpoints (the order may vary due to different architectures/tool ​​names):

1. **TLS callback** breakpoint (debugger EP may have been run before)
2. **Entry Point EP** Breakpoint
3. **Sensitive API** breakpoints (such as `CreateRemoteThread` / network / file writing)
4. **Guarantee**: `ExitProcess` / Process exit path breakpoint (patch 10) - Once exited directly due to anti-debugging, **Don’t rush to restart**; dump memory immediately, write the pre-crash mirror path to Evidence for string/data recovery

```text
□ Frida/x64dbg/gdb/emulator: verify static assumptions
□ Press §3.0 to preset breakpoints before running; single-step trace stack/register (white box)
□ Behavior monitoring: Sandbox / Procmon / RegShot (black box)
□ IAT repair failure/self-verification crash sample: hardware execution breakpoint or memory search forced capture API; CreateFile/GetFileSize check CRC
□ Anti-debugging/anti-Frida → reverse-engineering/anti-analysis
□ Android: root detection/SSL pinning bypass script generated on demand, **must be on an authorized device**
□ Crash log drives the next round of hooks (adaptive loop)
□ Time box (patch 9 · SHOULD default): Tracking about 200 instructions in a single step and still no clues of malicious behavior → Forced return to static search string/change anchor point (can be overridden)
```

### 3.1 Sandbox/Dynamic No Behavior Emergency Branch (MUST)

```text
No action or exit immediately / sleep indefinitely
→ Check for anti-debugging/anti-VM routines (CPUID, high-precision timing, sandbox signatures, etc.)
→ Try to bypass hardware breakpoints, patch detection points, or change physical machines/higher fidelity environments
→ Write "no behavior + suspected anti-VM" into Evidence, and prohibit writing "sample harmless" without any conditions
```

### 3.2 Timebox Strategy (Patch 9 · SHOULD)

| Phase | Default threshold (can be overridden by user/task) | Action |
|------|------------------------------|------|
| Static dig deep without critical path | ~15 minutes | transfer to Dynamic |
| Dynamic No progress in a single step | ~200 instructions | Return to Static string/cross-reference re-anchor |
| Any path fails repeatedly | Mark Evidence to change tools or bypass | Prohibit idling of the same failed method |


### 3.3 Anti-Debugging/Obfuscation Bypass Quick Check (Issue #65 Patch A–T · High Frequency)

For complete index and action details, see `reverse-engineering/anti-analysis.md` "Agent Response Recipes A–T". Only **P0 must check + common transitions** are listed here. The default is **authorized isolation lab**; patching/changing the flag is not an unauthorized production action.

| Trigger Characteristic | Preferred Action (Summary) | Evidence |
|----------|------------------|----------|
| `cpuid` after jz/jnz (A) | lab: change the flag bit or patch to take the real branch; note the detection point address | `E-anti-debug-cpuid` |
| `rdtsc` + sub/cmp (B) | bp rdtsc or hook time source; prohibit infinite idling and other sandbox timeouts when "harmless" | `E-anti-debug-rdtsc` |
| PEB BeingDebugged / NtGlobalFlag (K) | ScyllaHide or manually change PEB; patch conditional jump | `E-anti-debug-peb` |
| `NtQueryInformationProcess` DebugPort/Flags/Object (P) | ScyllaHide / hook return value; remember class parameter | `E-anti-debug-ntqip` |
| has few imports but rich behaviors → API hash (N) | bp GetProcAddress; hash reverse check back annotation IDA | `E-api-hash` |
| strings empty but with network/file behavior → string encryption (I) | Find decode routine xref; dump backnote after decryption | `E-string-decrypt` |
| has a signature but the source is suspicious (F) | SigCheck: valid/revoked/time; **Invalid does not reduce** threat level | `E-sig-forge` |
| standard strings no IOC → trial wide character (T) | `strings -el` / UTF-16LE; Alt+A unicode | `E-wide-strings` |
| Debugger name string / Toolhelp scan (C) | bp CreateToolhelp32Snapshot chain | `E-anti-debug-procscan` |
| AddVectoredExceptionHandler + intentional exception (D) | bp VEH registration; analysis handler | `E-anti-debug-veh` |
| int3 / DR0–DR7 (M) | patch int3; soft breakpoint or ScyllaHide hidden hardware BP | `E-anti-debug-bp` |
| Multiple PE headers/overlapping sections (G) | Section table real mapping + entropy; do not trust section names | `E-pe-anomaly` |
| file end > section sum Overlay (J) | extract overlay; file/entropy; find load offset xref | `E-overlay` |
| .rsrc unusually large/high entropy RT_RCDATA(Q) | Extract resource; FindResource chain + decrypt dump | `E-rsrc-payload` |
| Load DLL (R) at runtime | Check Delay Import; bp delay-load helper | `E-delay-import` |
| while+switch star CFG (H) | **See** `ollvm-deobfuscation.md`; dynamic path if plug-in fails | `E-cff` |
| Constant true/constant false branch (S) | **See** ollvm / symbolic execution; dynamic subject | `E-opaque-pred` |
| `/proc/self/status` TracerPid (L) | **Linux/ELF**; hook or patch; Windows main path is not mandatory | `E-anti-debug-tracerpid` |

**Constraints**: If the bypass fails, it will also be recorded as Evidence; it is forbidden to write "anti-debugging trigger exit" as "sample is harmless". See the anti-analysis recipe section for complete A–T and P2 (E compile time, O flower instructions).

### 3.4 Non-PE/Multi-Format Bypass (Issue #65 Patch U–AV · Routing)

Full index: `reverse-engineering/references/nonpe-format-cookbook.md`. Only **Type → Entry** is listed here; the action details are in the cookbook / corresponding skill.

| Type | Jump | P0 Evidence anchor (example) |
|------|------|---------------------------|
| BAT/CMD | cookbook §1 + malware | `E-batch-deobf` |
| PowerShell | cookbook §2 + malware | `E-ps-decode-layer-N` |
| VBA macro | cookbook §3 + malware | `E-vba-pcode` |
| JS strong obfuscation / JSVMP | **js-reverse** + cookbook §4 | `E-js-vmp` / `E-js-deobf` |
| SYS driver | kernel-driver-reverse + cookbook §5 | `E-driver-irp-handlers` / `E-driver-ioctl` |
| DLL focus | cookbook §6 (AM≡A–T **R**) | `E-dll-tls-dllmain` / `E-exports` |
| Android grid machine/hidden icon | **apk-reverse** + cookbook §7–8 | `E-android-wiper-*` / `E-android-hidden-icon-*` |

**Constraints**: No new "non-PE six stages"; division of labor with §3.3 A-T (PE anti-debugging vs multi-format). Authorized lab; grid machine/BYOVD/reflection = detection forensic representation.


## 4. Synthesis (IOC/attack chain/report)

### Decision quality overlay (Issue #77)

Before closing Synthesis, apply [analysis-decision-framework.md](../../ops/analysis-decision-framework.md) **P0 checklist**: R41 grounded claims, R4* validated sufficiency, R1 confidence->dynamic, R2 hypothesis exit, R43 deadlock replan (under feasibility gate), R8/R23 no default malice/IOC. Multi-module -> R50; anti-analysis effort -> R51 + A-T cookbook.

Blindspots (Rust/Go/VMP/injection/OLE/PDF/agent-meta): [analysis-blindspot-cookbook.md](../../ops/analysis-blindspot-cookbook.md) R52-R81 — detection-oriented; not a parallel master flow.



```text
□ Finding: algorithm/verification logic/available points/behavior conclusion
□ Path: callflow or solve step E-*
□ IOC: network fingerprint + host fingerprint (if yes, then table; if not, then n/a+reason)
□ Report docs-generator (malware/apt/null/vuln overlay selected by task) + optional image
□ Optional: YARA/Snort·Suricata regularized precipitation
□ field-journal desensitization
```

## 5. Six-stage practical mapping (Issue #65 mind map → this document)

| Practical stage | Chapters of this document | Hard door/iron law |
|----------|------------|-------------|
| 1 Initial rapid research and judgment | §0–§1 Triage | Hash, architecture, file type, shell check; imports/equivalent anchor point; §0.5 command latch |
| 2 Unpacking and IAT | §1.2 | IAT iron law; failure/self-verification crash → Evidence → Dynamic |
| 3 Basic static anchor point | §2 Static | High-risk API combination; time box SHOULD |
| 4 Deep cross-validation | §3 Dynamic | Breakpoint four-stage rocket; no behavioral emergency; time box; §3.3 A–T; §3.4 U–AV type routing |
| 5 Extract IoC and attack chain | §4 Synthesis | IOC + Kill Chain / Path |
| 6 Archiving and Rules | §4 + docs-generator / YARA | Structured reporting; rules optional |

## 6. Differences from "Stack RE skill plug-in"

- This package uses **stage latch + tool-index** and does not enable Hex-Rays "unsafe fully automatic execution" plug-ins by default.  
- Dynamic instrumentation defaults to **offline/lab** network_profile  
- IAT/Import Table: **Try + Record** takes precedence over "Infinite Static Kill" or "Silent Skip"  
- User instructions: **Target first + prerequisite negotiation**, it is prohibited to use irrelevant steps to pretend to be named steps