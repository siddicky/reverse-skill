# 2026-08-14 Windows PowerShell native command exit code PR review

## Scene classification

Others (toolchain, supply chain bootstrapping scripts, open PR review)

## Goal overview

Evaluate a fixed-source and submitted bootstrap script PR and verify that it remains fail-closed under Windows PowerShell 5.1 and does not incorrectly reject legitimate checkouts.

## Scope Summary (redaction)

- auth_basis: The repository maintainer is authorized to review public PRs and submit them for review
- network_profile: public code hosting platform; read-only during the evidence collection phase, submitted for review after the conclusion is confirmed
- asset_types: [open source, CI results, Windows PowerShell bootstrap script]

## Role

- lead_role: lead
- specialists: [supply-chain-reviewer, windows-compatibility-reviewer]

## Complete execution link

1. Fixed PR head commit, reading changes, discussions, CI and target scripts to avoid reviewing moving targets.
2. The security goals are divided into six items: source fixation, commit fixation, atomic replacement, dirty directory rejection, lock file installation and platform compatibility.
3. Confirm that manifest single-source, staged checkout, dirty-tree fail-closed, and frozen lockfile design directions are valid.
4. Locate the checkout validation function to execute the native command and the pipeline version with`Select-Object`in Windows PowerShell 5.1.
5. Observe that both executions return the same commit text, but the pipeline version reads`$LASTEXITCODE`of`-1`, causing a legitimate checkout to be mistakenly rejected.
6. Run the supply chain test script to confirm that the failure occurs before entering the expected dirty-tree assertion, ruling out a problem with the test fixture itself.
7. Submit changes-requested review on PR, require saving native command exit code before processing output, and add Windows PowerShell 5.1 verification.
8. redact the reproduction method and review criteria and write them back for reuse in subsequent PowerShell boot script reviews.

## Evidence chain summary (redaction)

| E-id | severity | status | source_type | Reusable command mode | Association Finding |
|------|----------|--------|-------------|----------------|--------------|
| E-001 | info | observed | command | `powershell.exe -NoProfile -Command "& git -C {install_dir} rev-parse HEAD; $LASTEXITCODE"` | F-001 |
| E-002 | medium | validated | command | `powershell.exe -NoProfile -Command "& git -C {install_dir} rev-parse HEAD \| Select-Object -First 1; $LASTEXITCODE"` | F-001 |
| E-003 | medium | validated | command | `powershell.exe -NoProfile -File skills/scripts/tests/test-bootstrap-supply-chain.ps1` | F-001 |

## Finding/Path Summary

- top_finding: In Windows PowerShell 5.1, after the native command output is connected to the object pipeline and then read`$LASTEXITCODE`,`-1`may be obtained. Even if the output commit is exactly the same as the fixed value, an incorrect checkout verification failure will be triggered.
- path_type: callflow
- path_one_liner:`git rev-parse`succeeded → output went into`Select-Object`→`$LASTEXITCODE`was rewritten → legal checkout was mistakenly rejected by the fail-closed branch

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| All existing CIs pass but Windows still has regressions | CI covers new versions of PowerShell and Bash, but does not cover the native command pipeline semantics of Windows PowerShell 5.1 | Run minimal reproduction and full supply chain test with`powershell.exe`| About 20 minutes |
| commit text is the same but is judged to be inconsistent | Verification logic relies on both output and delayed reading`$LASTEXITCODE`| Save the exit code immediately after returning from the native command, and then separately normalize the output | About 10 minutes |
| PR shows clean and can easily be mistaken for direct merging. | mergeable only shows the Git merge status and does not prove that the target runtime is compatible. | treats base freshness, platform matrix and local reproduction as independent gates. | About 5 minutes |

## Toolchain discovery

- The GitHub API is suitable for pinning PR heads, reading CI and commit status; review records should be bound to verified commits.
- `powershell.exe`and`pwsh`are not interchangeable test entries. Scripts targeting Windows PowerShell 5.1 must be tested by the corresponding host.
- `$LASTEXITCODE`is session state that changes; any subsequent pipes or commands may cause the deferred read to lose its native command semantics.

## Key code/command

```powershell
# First capture the output of the native command and save the exit code immediately.
$output = & git -C $CheckoutPath rev-parse HEAD 2>$null
$gitExitCode = $LASTEXITCODE
$resolvedCommit = [string]($output | Select-Object -First 1)

if ($gitExitCode -ne 0 -or $resolvedCommit.Trim() -ne $PinnedCommit) {
    throw "Checkout verification failed"
}
```

## Suggestions for improvements to this package

- Add`powershell.exe`5.1 test task to the PR that modifies the PowerShell boot script to avoid being only covered by`pwsh`.
- Add "whether the native command exit code is saved before the next command" in the supply chain review list.
- Before merging, check the PR head, latest main diff, and target platform tests at the same time, and do not use GitHub's clean status as a replacement for runtime verification.

## Reusable patterns/script snippets

Three-stage processing for all native PowerShell commands: execute and capture the output, save`$LASTEXITCODE`immediately, and finally parse the output using a PowerShell pipeline. Only saved exit codes can be used for error determination.

## evolution action

- [ ] Updated routing matrix
- [ ] updated tool-index
- [ ] updated bootstrap-manifest
- [ ] Updated sub-skill documentation
- [x] Added pitfalls record
- [ ] No update required

## environmental information

- OS: Windows
- Tool version: Windows PowerShell 5.1, Git 2.x
- Target platforms/versions: PowerShell compatible bootstrap script, public PR head commit

## redaction test

- [x] No real domain name, IP, certificate, Token, Cookie or PII
- [x] The local installation path has been replaced by`{install_dir}`
- [x] No user project files or private repository content attached

---
<!-- [Progress stats] Projects completed by this package to date: 18 | New patterns added this time: 1 | Toolchain issues fixed this time: 0 -->
<!-- [Community contribution] The user authorized sharing this sanitized experience through a separate PR PR. -->
