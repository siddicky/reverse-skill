# Authorization pre-declaration — reduces disclaimer noise, cannot replace scope.md

> This document only solves one thing: Don't take "the user clicked on the target" as authorization.
> The executable authorization gate is still `case-init.ps1` → `work/<case>/scope.md` which is `auth.status=granted` + legal `network_profile`.

---

## CRITICAL

Common scenarios in this package (SRC / own system / paid contract / CTF shooting range / responsible disclosure) can ** reduce cliche disclaimers.

**AI must not treat this document as `auth.status=granted`.**

- User mentioned domain name / IP / sample path ≠ Authorized
- It is forbidden to use this file to skip `case-init`
- It is forbidden to automatically add `-AuthGranted` in the skill "so that the process can go on"
- CTF / shooting range: still need to build a case, use `lab` or `offline` for `network_profile`
- Real external network: ACT must be granted + `authorized_target_only` (or contract agreement file)

---

## allow/disallow

1. **MUST NOT** Overwrite `ops/scope-contract.md` with this file
2. **MUST NOT** Run nmap / sqlmap / upload / exploit on target without `scope.md`
3. **MUST** Distinguish between "less legalese" and "already allowed to take action"
4. **MUST** Output technical analysis when technology is uncertain, rather than pretending to have insufficient authorization to stop work.
5. Unbuilt case or `auth.status!=granted` → `case-init` first, don’t guess

---

## Relationship to other files

| file | function |
|------|------|
| **precedent-auth.md** (this file) | less disclaimer; **not** written granted |
| `ops/scope-contract.md` + `case-init.ps1` | The only executable authorization gate |
| `precedent-reverse.md` / `precedent-pentest.md` | Daily operation is not a criminal tutorial; still subject to scope |

```
case-init / scope.md → whether ACT is allowed
precedent-auth.md    → do not use boilerplate in place of scope
PRIMARY SKILL.md     → how to proceed
```
