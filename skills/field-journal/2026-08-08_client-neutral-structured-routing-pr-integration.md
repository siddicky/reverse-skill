# 2026-08-08 Platform-independent structured routing PR integrated

## scene classification

 code audit / tool chain maintenance / multi-platform routing

## Goal Overview

 conducts incremental value reviews on multiple groups of high-conflict PRs, and reconstructs the valuable parts into platform-independent cores before integrating them.

## Scope Summary (redaction)

- auth_basis: repository_owner_authorized
- network_profile: authorized_upstream_only
- asset_types: [source_repository, pull_request_refs, local_tests]

## role

- lead_role: lead
- specialists: [cae, doc]

## complete execution link

1. grabs PR refs from the remote end and compares each PR with the current mainline in the isolated worktree.
2. first judges based on incremental value, then uses merge parent to retain the source relationship and resolve conflicts based on semantics.
3. decouples structured routing from client access, using JSON as the PowerShell/Bash common source of truth.
4. only takes authorized access control and Bash parity for large PRs, excluding client-specific and generated assets.
5. runs full routing, structural access control, language unit testing, grammar and manifest verification.

## Evidence chain summary (redaction)

| E-id | source_type | Reusable command mode | Association Finding |
|------|-------------|----------------|--------------|
| E-001 | git diff | `git diff <main>...<pr-ref>` | F-001 |
| E-002 | regression | `test-routing.ps1` + coherence + smoke | F-001 |
| E-003 | unit tests | Python unittest + Node test + Bash parity | F-002 |

## Finding / Path summary

- top_finding: Client integration is not the core value of structured routing, single source of truth and automated access control are.
- path_type: callflow
- path_one_liner: any host → optional adapter → routing.json → cross-platform router → unified return access control

## pit record

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| Large PR mixes client manifests, GIFs, scripts, and documentation simultaneously | Concerns are not split | Only the smallest cross-platform subset is merged | Medium |
| Bash router and PowerShell are each hard-coded |. The two sources of truth must drift | Bash reads the same JSON | through Python |
| New pin gate fails for the first time | Kali manifest Keep floating source | pin manifest and let the actual installation command use pin | |
| Gradle wrapper download TLS interruption | External network handshake exception | Log and retry on final verification | Low |
| Bash CaseName can write the work root | Missing the existing path constraints of PowerShell during selective merging | Complementing cross-platform equivalence check and negative CI | |
| Authorization URL marked offline | Bash default not aligned with PowerShell | Network target default authorized_target_only; offline local sample only | Low |
| INDEX passed on the development machine, clean clone failed | The generator scanned the ignored local private modules | only enumerated Git and tracked SKILL.md | |

## toolchain found

Git merge parent can retain the PR source relationship while allowing semantic deletions within the merge commit. The supply chain gate only works if the manifest metadata is co-fixed with the actual installation command.

## key code/command

```text
git merge --no-ff --no-commit <pr-ref>
powershell -File skills/scripts/test-routing.ps1
powershell -File skills/scripts/verify-routing-coherence.ps1
bash skills/scripts/master-route.sh --hint "case review evidence graph"
```

## 's suggestions for improving this package

 All client adapters are placed on independent boundaries; writing client configuration into core routing PR is prohibited. Large PRs must be split by core, adapters, demo assets, and documentation.

## Reusable pattern/script snippet

 structured routing parity test covers at least ordinary routing, conflict priority routing and the latest new routing to prevent the entry of a certain platform from lagging.

 does old/new A/B on the same 163 benchmarks: old hard-coded implementation 137/163 (84.05%), structured implementation 163/163 (100%). Only this quantitative comparison with the input can prove that reconstruction is a substantial improvement rather than an increase in the number of files.

## evolution action

- [x] updated the routing matrix
- [ ] updated tool-index
- [x] updated bootstrap-manifest
- [x] Updated sub-skill documentation
- [x] added pitfalls record
- [ ] No need to update

## Environmental information

- OS: Windows (master verification) + Linux CI defines
- tool version: Git / PowerShell / Python 3 / Node.js / Bash
- Target platform/version: client-neutral repository core

## redaction requirements

This entry does not contain real targets, credentials, internal addresses, or personally identifiable information.

---
<!-- [Community Contribution] Prepared to push the mainline as instructed by the repository owner. -->
