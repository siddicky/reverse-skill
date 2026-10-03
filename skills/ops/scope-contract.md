# General Scope contract (task start hard threshold)

> **MUST**: Any security/reverse/penetration tasks implemented in**ACT before**are implemented in `work/<case>/` of the current user analysis project `scope.md`.
> has no scope → only allows reading documents/routes,**prohibits**from actively scanning, hooking, and exploiting targets.
> The template can be copied; field names remain in English to facilitate script verification.

## How initializes

Windows：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File skills\scripts\case-init.ps1 -Hint "<task sentence>" -CaseName "my-case"
# default output: work/<case>/scope.md of the current analysis project, etc.
# Explicitly specify when calling the skill from another directory: -ProjectRoot "C:\path\to\analysis-project"

# Legal local offline sample: auth granted + offline + explicit sample → ready_for_act=true
powershell -NoProfile -ExecutionPolicy Bypass -File skills\scripts\case-init.ps1 `
  -Hint "offline apk" -CaseName "my-sample" -Preset offline-sample -Sample ".\app.apk"
```

Linux / macOS / Kali：

```bash
bash skills/scripts/case-init.sh --hint "<task sentence>" --case-name "my-case"
# default output: caller work/<case>/scope.md of the current analysis project, etc.
# Explicitly specified when calling from other directories: --project-root "/path/to/analysis-project"

# Legal local offline sample
bash skills/scripts/case-init.sh \
  --hint "offline apk" --case-name "my-sample" \
  --preset offline-sample --sample ./app.apk
```

`-PackageRoot` / `--package-root` are reserved as compatible parameters; new processes should use `ProjectRoot` / `--project-root` to represent the project to which the case artifact belongs.

## scope.md Complete template

```markdown
# Case Scope

## meta
- case_id: {YYYYMMDD-short}
- created: {ISO-8601}
- operator: {name or local}
- project_root: {caller analysis project}
- primary_skill: {from master-route}
- lead_role: lead   # see ops/role-map.md
- specialist_roles: []  # e.g. cie, cpe, cre

## auth
- status: granted | pending | denied
- basis: written_contract | bug_bounty_scope | ctf_public | own_system | lab_only
- evidence_of_auth: {ticket/path or "CTF public" or "owner-operated"}
- MUST NOT proceed if status != granted

## in_scope
- assets: []          # hosts, domains, APK paths, binaries, URLs
- surfaces: []        # web, mobile, binary, network, api
- activities: []      # recon, reverse, exploit_validate, report

## out_of_scope
- assets: []
- activities: []      # e.g. DoS, phishing real users, data exfil

## network_profile
- mode: offline | lab_only | authorized_target_only | unrestricted_lab
- notes: |
    offline = no outbound packets (static analysis/local sample only)
    lab_only = lab/VM IPs only
    authorized_target_only = in-scope assets only
- MUST NOT use unrestricted against production without written auth

## deliverables
- report: true
- field_journal: true
- diagrams: true
- timeline: true

## constraints
- timebox: {}
- stealth: low | medium | high
- data_handling: anonymize | no_user_pii

## signoff
- ready_for_act: false
- checklist:
  - [ ] auth.status = granted
  - [ ] in_scope.assets non-empty OR offline sample path set
  - [ ] network_profile.mode chosen
  - [ ] out_of_scope reviewed
```

## routing hook (required for AI)

```text
RULES / MASTER-ROUTING / SKILL:
  1) master-route → PRIMARY
  2) platform-native case-init or manually written scope.md
  3) auth not granted → STOP，only authorization materials may be added
  4) ready_for_act = true → open PRIMARY SKILL.md → ACT
```

`case-guard -Force` / `case-guard --force` are compatible parameters,**shall not**bypass `auth.status`, legal scope, network profile or `ready_for_act` hard door.

## network_profile Quick check

| mode | allow | disable |
|------|------|------|
| `offline` | Static analysis, local files, simulation | Any external connection, public network RPC |
| `lab_only` | lab/CTF target drone network segment | production/unauthorized IP |
| `authorized_target_only` | in_scope list | assets outside the list |
| `unrestricted_lab` | Isolation Experiment Network (written) | Internet Production |

## Features

- pure Markdown,**no database**  
- and `tool-index` / bootstrap are orthogonal: scope controls "whether it can be beaten", tool-index controls "what to use"
