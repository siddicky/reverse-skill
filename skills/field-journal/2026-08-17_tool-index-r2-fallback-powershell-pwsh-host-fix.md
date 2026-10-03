# 2026-08-17 reverse-skill

## scene classification
 tool chain and environment (boot phase defect repair)

## Goal Overview
 fixes three types of defects in the native boot process that are covered up by layers: tool-index falsely reports radare2 main analyzer `r2` as no; multiple test scripts hard-coded `powershell` subprocess calls fail on machines with only PowerShell 7+; and a pin gate StrictMode attribute access bug that is masked by this failure.

## Scope Summary (redaction)
- auth_basis: own_system (this repository itself)
- network_profile: offline / no external target ACT
- asset_types: [Local Scripts and Tools Index]

## role
- lead_role: lead
- specialists: [bootstrap, test-infra]

## complete execution link

1. executes the boot according to `README_AI.md` section 0: `refresh-tool-index.ps1` generates tool-index.md (37 tools).
2. read `tool-index.md` and found an exception: `r2` (radare2 main analyzer) = no, but in the same directory `rabin2/rasm2/radiff2/rahash2/rax2/r2pm` all = yes.
3. Column `C:\Users\{username}\Tools\radare2\bin` Acknowledgment: There is `r2.bat` (21 bytes, content `@"%~dp0\radare2" %*`) with `radare2.exe`,**without `r2.exe`**.
4. reads `lib/ToolDiscovery.ps1:131-141`, and the fallbacks of `r2` only find `r2.exe`, missing `r2.bat`/`radare2.exe`. Compare `jadx`/`apktool`/`analyzeHeadless`, all of which are equipped with fallback for the `.bat` tool.
5. repair: Supplement `r2.bat` and `radare2.exe` paths for `r2` Fallbacks (covering three sets of locations: `%USERPROFILE%\Tools\radare2\bin`, root directory, and `C:\Tools\`), keeping the original `r2.exe` fallback compatible with other machines.
6. reruns `refresh-tool-index.ps1`, `r2` to yes, path `r2.bat`, version `radare2 6.2.0`, source `FallbackPath`.
7. running `smoke.ps1` still FAILs: `verify-routing-coherence exit 1`. Run verify directly to see the error and locate `verify-routing-coherence.ps1:257` hard-coded `& powershell`. This machine does not have `powershell` (only `pwsh` 7.6.4).
8. grep fully positions `.ps1` and `powershell\s(-NoProfile|-ExecutionPolicy|-File|-Command)`, and found 5 scripts with a total of 20+ hard-coded `& powershell` subprocess calls (verify 7 places / test-p0-friction 18 places / test-routing 1 place / case-init 1 place; the rest are commented examples).
9. found that `smoke.ps1:31-46` has correctly used `$SmokeHostExe` (the current process path takes precedence → pwsh → Windows PowerShell path). Extract the verified logic into the shared function `Resolve-ReverseHostExe`, create a new `lib/HostRuntime.ps1`, and parse the sequence: current process → `pwsh` → `powershell` → `%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe`.
10. 4 subscript dot-source `HostRuntime.ps1` and define `$HostExe`, `replaceAll`. Change `& powershell -NoProfile -ExecutionPolicy Bypass -File` → `& $HostExe -NoProfile -ExecutionPolicy Bypass -File`; `test-p0-friction.ps1:244`’s `cmd /c "powershell ..."` individually. `cmd /c "`"$HostExe`" ..."` (the path may contain spaces and needs to be wrapped in quotes).
11. re-runs smoke and verify passes 257, but it exposes `verify-routing-coherence.ps1:414` pin gate. When accessing `$cap.pinnedVersion` and other non-existent attributes under `Set-StrictMode -Version Latest`, an error is reported - this is a pre-existing bug that has been covered up by the powershell bug.
12. fixes 414: Convert `$cap` to hashtable (`$capMap`), use index to access non-existent key and return `$null` without error, pin gate semantics unchanged.
13. rerun smoke → ALL PASS (VERIFY_EXIT=0 / PARSE 11/11 / ROUTE 9/9).
14. runs `test-routing.ps1` → 166/166 ALL PASS.
15. runs `test-p0-friction.ps1` → Most of them pass, but `:343` and `:364` encounter `Start-Process -FilePath 'powershell.exe'` (the previous grep mode `powershell\s+(-NoProfile...)` missed the `powershell.exe` literal).
16. grep `powershell\.exe`, confirming that only test-p0-friction 343/364 are hard-coded Start-Process (the rest are compatible search or fallback paths), `replaceAll` is changed to `Start-Process -FilePath $HostExe`.
17. reruns `test-p0-friction.ps1` → ALL PASS (FAIL_COUNT=0). All three kits are green.

## Evidence chain summary (redaction)
> This time it is a self-guided repair for this repository. There is no external target ACT and no evidence file in the case directory is generated. The following is a reproducible verification command (equivalent to Evidence).

| E-id | severity | status | source_type | Reusable command mode | Association Finding |
|------|----------|--------|-------------|----------------|--------------|
| E-r2 | info | validated | command | `pwsh -File skills/scripts/refresh-tool-index.ps1` `r2` line in tool-index.md = yes | F-r2 |
| E-smoke | info | validated | command | `pwsh -File skills/scripts/smoke.ps1` → `OVERALL: ALL PASS` | F-host |
| E-route | info | validated | command | `pwsh -File skills/scripts/test-routing.ps1` → `166/166 ALL PASS` | F-host |
| E-p0 | info | validated | command | `pwsh -File skills/scripts/test-p0-friction.ps1` → `OVERALL: ALL PASS` | F-host |

## Finding / Path summary
- top_finding: Three types of defects are covered up layer by layer - `r2` fallback misses `.bat` entry → `verify` hard-codes `powershell` failed interrupt → masks pin gate StrictMode attribute access bug; grep compatible scan misses `powershell.exe` literal.
- path_type: solve
- path_one_liner: Use shared `Resolve-ReverseHostExe` (current process first) to unify sub-process entry, supplement `r2` with `.bat`/`radare2.exe` fallback, and use hashtable to securely access PSCustomObject optional attributes.

## pit record

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| tool-index marks `r2` as no, but other r2* tools in the same directory are yes | `ToolDiscovery.ps1`'s `r2` Fallbacks only find `r2.exe`, while radare2 Windows distribution uses `r2.bat` to package `radare2.exe`, none `r2.exe` | complements `r2.bat` and `radare2.exe` path fallback | short |
| smoke still FAIL: verify exit 1 | verify internally hard-coded `& powershell`, this machine is only installed with pwsh 7+, no `powershell` | Create `lib/HostRuntime.ps1`'s `Resolve-ReverseHostExe`, 4 scripts are replaced by `& $HostExe` | Medium |
| verify failed at 414 after repairing powershell. | was a pre-existing bug covered up by the powershell bug of 257: an error was reported when accessing non-existent attributes such as `$cap.pinnedVersion` under StrictMode. | `$cap` was converted to hashtable `$capMap`, and no error was reported when accessing the index. | short |
| test-p0-friction failed again in 343/364 | `Start-Process -FilePath 'powershell.exe'` is hard-coded; the previous grep mode `powershell\s+(-NoProfile...)` missed `powershell.exe` literal | grep `powershell\.exe` to complete, use `$HostExe` instead | short |
| test-p0-friction outputs a large number of `Exception: case-init.ps1:54` | test 14b deliberately uses illegal CaseName to trigger case-init and throws an exception, which is expected | does not need to be processed, and finally FAIL_COUNT=0, that is, | — |

## toolchain found
- **radare2 Windows distribution structure**: The main program is `radare2.exe`, `r2.bat` (`@"%~dp0\radare2" %*`) is its batch wrapper,**does not have `r2.exe`**. Any tool scan probed by `r2.exe` will give false positives. `rabin2.exe`/`rasm2.exe` in the same directory are independent `.exe` and can be detected normally.
- **PowerShell 7+ standalone environment**: native `pwsh` 7.6.4 (path `C:\Program Files\WindowsApps\Microsoft.PowerShell_7.6.4.0_x64__8wekyb3d8bbwe\pwsh.exe`),**without `powershell` / `powershell.exe`**. All `& powershell ...` subprocess calls fail directly in this environment.
- **StrictMode attribute access**: Accessing non-existing attributes of `PSCustomObject` under `Set-StrictMode -Version Latest` will throw an error; using hashtable index to access non-existent keys returns `$null`, which is a safe way to write scenarios such as pin gate with "many optional attributes".
- **grep is compatible with the scanning blind area**: using `powershell\s+(-NoProfile...)` can only capture the `& powershell -File` form, missing `Start-Process -FilePath 'powershell.exe'` and `cmd /c "powershell ..."`. Compatibility scans should cover both `powershell\s` and `powershell\.exe` categories.

## key code/command

```powershell
# lib/HostRuntime.ps1 - Unified sub-process PowerShell entry (current process takes priority)
function Resolve-ReverseHostExe {
    [CmdletBinding()] [OutputType([string])] param()
    $hostExe = $null
    try { $p = (Get-Process -Id $PID -ErrorAction Stop).Path; if ($p -and (Test-Path -LiteralPath $p)) { $hostExe = $p } } catch { }
    if (-not $hostExe) { $c = Get-Command pwsh -ErrorAction SilentlyContinue; if ($c -and $c.Source) { $hostExe = $c.Source } }
    if (-not $hostExe) { $c = Get-Command powershell -ErrorAction SilentlyContinue; if ($c -and $c.Source) { $hostExe = $c.Source } }
    if (-not $hostExe -and $env:SystemRoot) { $f = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'; if (Test-Path -LiteralPath $f) { $hostExe = $f } }
    if (-not $hostExe) { throw 'No usable PowerShell host executable found.' }
    return $hostExe
}

# ToolDiscovery.ps1 r2 Fallbacks - added .bat/.exe entry
Fallbacks = @(
    @{ Type = 'command'; Value = 'r2' },
    @{ Type = 'command'; Value = 'radare2' },
    @{ Type = 'path'; Value = (Join-Path $userProfile 'Tools\radare2\bin\r2.bat') },
    @{ Type = 'path'; Value = (Join-Path $userProfile 'Tools\radare2\bin\radare2.exe') },
    @{ Type = 'path'; Value = (Join-Path $userProfile 'Tools\radare2\bin\r2.exe') }
    # ... root directory and C:\Tools mirror
)

# verify-routing-coherence.ps1:412 —— pin gate security attribute access
foreach ($cap in $mc.capabilities) {
    $capMap = @{}
    foreach ($prop in $cap.PSObject.Properties) { $capMap[$prop.Name] = $prop.Value }
    if (-not $capMap['canAutoInstall']) { continue }
    $hasPin = ($capMap['pinnedVersion'] -or $capMap['pinnedCommit'] -or $capMap['pinPolicy'])
    # ... switch ($capMap['bootstrapKind']) ...
}
```

## 's suggestions for improving this package
- **Compatibility Scan Scripted**: In `verify-routing-coherence.ps1` or standalone lint, scan all subprocess calls of `.ps1`, disable bare `powershell` / `powershell.exe`, unified requirements through `Resolve-ReverseHostExe`. This time I relied on manual grep, which is easy to miss (the blind spot of `powershell.exe` has been stepped on).
- **tool catalog's `.bat` convention**: On Windows, `jadx`/`apktool`/`r2`/`analyzeHeadless` are all `.bat` packages `.exe`, and the catalog should also be equipped with `.bat` for each such tool. Corresponding to `.exe` fallback, avoid stepping on pitfalls one by one.
- **CI should contain the "pwsh-only" matrix**: This bug is exposed on `windows-latest` in GitHub Actions without Windows PowerShell 5.1 preinstalled. Currently `smoke.ps1` has been done correctly with `$SmokeHostExe`, but the subscripts are not reused.
- Traverse PSCustomObject**under -**StrictMode: pin gate This type of "object schema loose" check uses hashtable conversion access uniformly, or provides `Get-SafeProp` auxiliary function.

## Reusable pattern/script snippet
- `Resolve-ReverseHostExe`: When any script needs to start a child PowerShell process, dot-source `lib/HostRuntime.ps1` followed by `& $HostExe -NoProfile -ExecutionPolicy Bypass -File <script> ...`, compatible with pwsh-only / powershell-only / mixed environment.
- `$capMap` conversion: Traverse the `PSCustomObject` properties to hashtable and then index access to avoid the StrictMode property exception.
- `r2.bat` → `radare2.exe` Transparent transmission: version detection `r2.bat -v` can correctly return `radare2 6.2.0`, proving that the `.bat` wrapper transparent transmission parameters are valid and can be used as catalog entry with confidence.

## evolution action
- [x] updated tool-index (r2 changed to yes, path r2.bat)
- [x] New `skills/scripts/lib/HostRuntime.ps1`
- [x] Fix `ToolDiscovery.ps1` r2 Fallbacks
- [x] Fix `verify-routing-coherence.ps1` powershell hardcoding + pin gate StrictMode
- [x] Fix `case-init.ps1` / `test-routing.ps1` / `test-p0-friction.ps1` powershell hardcoding
- [ ] updated routing matrix (none)
- [ ] updated bootstrap-manifest(none)
- [ ] Added pitfalls record (this article is)

## Environmental information
- OS: Windows（win32）
- Shell/Host: pwsh 7.6.4 (`C:\Program Files\WindowsApps\Microsoft.PowerShell_7.6.4.0_x64__8wekyb3d8bbwe\pwsh.exe`); this machine does not have `powershell` / `powershell.exe`
- radare2: 6.2.0 +1 abi:132 @ windows-x86_64 (installed on `C:\Users\{username}\Tools\radare2\bin\`)
- repository root: `D:\Sources\reverse-skill`

## redaction requirements
 This time is the script repair of this repository itself. There is no real target domain name/IP/credential and no redaction is required.

## Index synchronization (last step before submission)

After  finishes writing this log, it will be updated simultaneously with `_index.md`:
1. Add a new line to the "Toolchain and Environment" section ✓
2. "High-frequency success mode" appends this file name (PowerShell sub-process entry is unified) ✓
3. "Entity Reverse" appends this file name (reverse-skill boot script) ✓
4. updates the total number of "Statistics" and the latest update date ✓

---
<!-- [Evolutionary Statistics] Total completed projects in this package: 19 | New modes added this time: 1 (Resolve-ReverseHostExe sub-process entry unified) | Fixed tool chain issues this time: 3 (r2 fallback / powershell hard coding / pin gate StrictMode) -->
<!-- [Community Contribution] This fix is ​​to fix the boot defect of the repository itself and conforms to the repair PR of CONTRIBUTING.md; after completion, the user will be asked whether to submit. -->
