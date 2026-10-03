---
name: ctf-sandbox
description: Thin PRIMARY for CTF / AWD / Range multi-type orchestration. Hands off to the sidecar CTF-Sandbox-Orchestrator. Use when the user says CTF, AWD, Range, or Competition and no more specific pwn/APK/IDA route already won.
---

# CTF sandbox entry (sidecar, not a second router)

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: ACT on the real external network is prohibited before running`../scripts/case-init.ps1`;`auth.status=granted`.`-NetworkProfile lab`or`offline`for competition/range use.
2. `NOW`: Open`../../CTF-Sandbox-Orchestrator/ctf-sandbox-orchestrator/SKILL.md`under the package root and press its sandbox to continue.
3. `MUST NOT`writes 40+`competition-*`sub-skills into`routing.json`. This entrance is a PRIMARY latch only.
4. `ACT`: The orchestrator selects a downstream`competition-*`. When the specific question type has been clarified (pwn/ROP, APK, IDA), it should have been won by the more advanced rules of`routing.json`, so don’t grab it again.

## Why is it a separate layer?

`CTF-Sandbox-Orchestrator/`is a **GPL bypass package**, and the authorization is inside the sandbox by default. The core routing package is still the MIT +`scope.md`gate. This skill only provides keyword entry and does not incorporate the competition tree into the core.

## Task completion self-check (MUST passes before claiming completion)

- [ ] Do I go case-init/scope first instead of treating "user said CTF" as an authorized external network?
- [ ] Did I turn on the sidecar orchestrator instead of using the 40 subskills as PRIMARY?
- [ ] If the task is actually pwn/APK/IDA, do I let a more specific PRIMARY take over?
