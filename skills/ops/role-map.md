# Expert Role → Skill Mapping (No Multi-Agent Server)

> The role code is inspired by the Z3r0 expert team; the **implementation method** is the reverse-skill routing and handover protocol, not process orchestration.

## character sheet

| Code | Name (localizable) | Responsibilities | PRIMARY / Tools skill |
|------|------------------|------|----------------------|
| **lead** | Lead/General Commander | Split tasks, set scope, stage gate control, summary report | `attack-chain/` or current PRIMARY hub; end → `docs-generator/` |
| **cie** | Intelligence collection | Asset discovery, exposure, relationship | `pentest-tools/` (recon); browser → `browser-automation/`; cloud → `cloud-k8s/` |
| **cpe** | Penetration verification | Scan, exploit verification, impact confirmation | `pentest-tools/`; API → `api-security/`; AD → `windows-ad/`; Wireless → `wifi-wireless/`; Library → `database-security/`; SSO → `identity-federation/`;OT → `ot-ics/` |
| **cre** | reverse analysis | binary/firmware/mobile/front-end logic | `ida-reverse/` `ghidra-reverse/` `binary-ninja-reverse/` `radare2/` `apk-reverse/` `mobile-reverse/` `macos-reverse/` `js-reverse/` `browser-extension-reverse/` `dotnet-reverse/` `go-rust-reverse/` `firmware-pentest/` `hardware-security/` `malware-analysis/` `protocol-reverse/` `thick-client/` `reverse-engineering/` |
| **cae** | code audit | source code/dependency/supply chain | `code-audit/` + `supply-chain-security/` |
| **cbe** | Blue Team/Forensics | Hunting, Detection, IR Artifacts | `threat-hunting/` `digital-forensics/` |
| **cce** | Cryptography | Algorithm/Protocol/Key Misuse | `reverse-engineering` Schema Documentation |
| **llm** | AI Security | Prompt/Agent | `llm-security/` |
| **doc** | Documentation Officer | Report/writeup/Picture | `docs-generator/` + `diagram-generator/` |

## Lead mandatory agreement

```text
1. Output PRIMARY (master-route) + lead_role=lead
2. Write scope.md (ops/scope-contract)
3. Specify specialist_roles[] and handoff conditions
4. End of each stage: update timeline + workitems; decide to continue/change roles/make a report
5. It is forbidden to skip scope and directly scan production through cpe.
```

## Handoff rules

| triggers the | deliverable | from → to |
|---------|------|--------|
| lead → cie | requires asset surface | scope + known domain name/IP |
| cie → cpe | has survival surface/service | assets list + port/URL |
| cpe → cre | requires reverse verification/client logic | sample path + suspicious point |
| cre → cpe | restore protocol/key/check | algorithm description + reproduction command |
| any → doc | Stage or task completed | Evidence/Finding/Path Draft |
| any → lead | blocking/override/change path | timeline remarks + blocked reason |

## How to use single-player Agent (features)

It is not necessary to actually start 6 Agents:

```text
Within the same session:
  [lead] planning
  [cie] execute the reconnaissance skill
  [cpe] switch to pentest-tools
  …
Use role prefix tags when outputting to facilitate timeline retrieval:
  [cpe] nuclei high findings → E-003
```

## Relationship with master-route

- `master-route` determined **PRIMARY skill**  
- `role-map` determines **who is responsible for the current stage** (can be written in scope.md)  
- Multi-stage task PRIMARY is usually `attack-chain/` and is redistributed by lead  

## MUST NOT

- Don't assume the Z3r0 session API exists  
- Do not initiate additional scans of unauthorized targets for the role  
