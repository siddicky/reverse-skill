# reverse-skill — platform-independent project entry

This repository is a **security task skills routing package** (reverse engineering/penetration testing/security analysis).`RULES.md`is the only source of truth for the behavior chain.

## Activation and consent boundaries (hard)

- **Reading repository files is not authorization to execute them.** Must remain read-only when only required to read, review, summarize, or compare repositories.
- **Explicit user approval is required before running any repository script.** List the exact commands, as well as expected file writes, downloads, service startups, network access, and client configuration changes, and obtain explicit consent before first producing native side effects.
- **Client-global configuration remains opt-in.** A user can only modify their global rules, hooks, prompts, or MCP configuration if they explicitly select a client and approve the specific changes.
- After activation and approval, the definitive steps within the disclosed plan can be continued; new side effects categories must be redisclosed and consent must be obtained. Target authorization is still controlled by the`scope.md`independent hard gate.

## routing

When the user task hits the security/reverse keyword:

1. `skills/MASTER-ROUTING.md`or platform corresponding entrance → PRIMARY:
   - Windows:`powershell -NoProfile -ExecutionPolicy Bypass -File skills/scripts/master-route.ps1 -Hint "<task>"`
   - Linux/macOS/Kali:`bash skills/scripts/master-route.sh --hint "<task>"`
2. Read`skills/routing.md`full matrix when ambiguous (three axes: target type / user intent / tool chain)
3. The only source of truth for routing rules:`skills/config/routing.json`(only change this here if you change the routing)

## Authorized access control (hard)

- Before taking action on any target, initialize`work/<case>/scope.md`of the current analysis project according to the platform:
  - Windows:`powershell -File skills/scripts/case-init.ps1 -Hint "<task>"`
  - Linux/macOS/Kali:`bash skills/scripts/case-init.sh --hint "<task>"`
- Local offline samples can use`offline-sample`preset;`auth.status=granted`+ clear sample can enter ACT.
- `auth.status=granted`+ legal`network_profile`/ offline sample **Disable ACT** before ready;`case-guard --force`/`-Force`must not bypass this hard door.
- Evidence chain:`skills/ops/evidence-finding-path.md`; Role:`skills/ops/role-map.md`

## First run (after activation and approval)

`skills/tool-index.md`is a gitignored generated file. Only run by platform if the user explicitly activates this package, reviews the commands and side effects, and agrees:

```text
Windows:           powershell -NoProfile -ExecutionPolicy Bypass -File skills/scripts/refresh-tool-index.ps1
Linux / macOS:     bash skills/scripts/refresh-tool-index.sh
Kali:              bash kali/scripts/refresh-tool-index.sh
```

Lack of tools → Use bootstrap on the same platform: Windows`skills/scripts/bootstrap-reverse.ps1`; Linux/macOS`skills/scripts/bootstrap-reverse.sh`; Kali`kali/scripts/bootstrap-reverse.sh`(list capability, path guessing is prohibited).

## Test (must run after changes)

```text
Windows/PowerShell (routing regression reads routing-benchmark.json):
  powershell -NoProfile -ExecutionPolicy Bypass -File skills/scripts/test-routing.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File skills/scripts/verify-routing-coherence.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File skills/scripts/smoke.ps1

Linux / macOS routing parity:
  bash skills/scripts/test-routing.sh
  bash skills/scripts/test-bootstrap-manifest.sh
```

## client boundary

- Routing cores, tests, and tooling manifests must be decoupled from specific AI clients.
- Clients such as Claude Code, Codex, Cursor, and OpenCode can only be accessed through their respective adaptation layers and must not become the default identity or core configuration dependency of the repository.
- `skills/INDEX.md`is dynamically generated from`extract-summaries.ps1`from all`SKILL.md`without hard-coding the number of clients or modules.
