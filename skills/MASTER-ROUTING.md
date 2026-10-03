# reverse-skill PRIMARY fast path

> `scripts/master-route.ps1`and`scripts/master-route.sh`must maintain the same routing contract; the platform only changes the execution entry, not the routing semantics.

## Execute the contract

```text
1. Route first and act later
2. Output PRIMARY path + one sentence basis
3. case-init/scope.md (ops/scope-contract) — auth not granted disallows ACT on target
4. Specify lead + specialist roles (ops/role-map)
5. Open PRIMARY's SKILL.md now → ACTION REQUIRED
6. The tool path only recognizes tool-index; if it is missing, bootstrap (only manifest capability)
7. The process appends timeline/workitems; the conclusion goes to Evidence→Finding→Path
8. Miss → Read the full table of routing.md or propose a new skill
```

### Windows

```powershell
powershell -File skills\scripts\master-route.ps1 -Hint "<user task>"
# By default, the work/master-route-<ts>/route-scope.md of the current project is written out; when calling from other directories, the project root is explicitly specified.
powershell -File skills\scripts\master-route.ps1 -Hint "<user task>" -ProjectRoot "C:\path\to\analysis-project"
powershell -File skills\scripts\case-init.ps1 -Hint "<user task>" -CaseName "my-case"
# case is written to work/<case>/ of the current project by default; -PackageRoot remains compatible, -ProjectRoot has a higher priority
powershell -File skills\scripts\case-init.ps1 -Hint "<user task>" -CaseName "my-case" -ProjectRoot "C:\path\to\analysis-project"
# One-time molding can ACT (authorization + target + network file):
powershell -File skills\scripts\case-init.ps1 -Hint "<task>" -CaseName "my-case" -AuthGranted -TargetUrl "https://target/" -NetworkProfile authorized_target_only
# Local offline sample:
powershell -File skills\scripts\case-init.ps1 -Hint "offline apk" -CaseName "my-sample" -Preset offline-sample -Sample ".\app.apk"
# Smoke: verify + script analysis + routing matrix (including Chinese Hint)
powershell -File skills\scripts\smoke.ps1
# Light scope access control before ACT (not ready for exit 2; -Force is a compatible parameter and cannot bypass hard doors)
powershell -File skills\scripts\case-guard.ps1 -CaseRoot work\my-case
# Evidence append
powershell -File skills\scripts\append-evidence.ps1 -CaseRoot work\my-case -Id E-001 -Title "..." -ReproCommand "..."
python3 skills/case-review/scripts/review_case.py work/<case> --verify-hashes --strict
```

### Linux / macOS / Kali

PowerShell installation is not required for the core route/case flow:

```bash
bash skills/scripts/master-route.sh --hint "<user task>"
bash skills/scripts/master-route.sh --hint "<user task>" --project-root "/path/to/analysis-project"
bash skills/scripts/case-init.sh --hint "<user task>" --case-name "my-case"
bash skills/scripts/case-init.sh --hint "<user task>" --case-name "my-case" --project-root "/path/to/analysis-project"
# Local offline sample:
bash skills/scripts/case-init.sh --hint "offline apk" --case-name "my-sample" --preset offline-sample --sample ./app.apk
# Light scope access control before ACT (--force is a compatible parameter and cannot bypass hard doors):
bash skills/scripts/case-guard.sh --case-root work/my-sample
# Routing parity:
bash skills/scripts/test-routing.sh
bash skills/scripts/test-bootstrap-manifest.sh
python3 skills/case-review/scripts/review_case.py work/<case> --verify-hashes --strict
```

## operational contracts (ops)

| Documentation | Purpose |
|------|------|
|`ops/IDENTITY.md`| We are a routing package, not a Z3r0 platform |
|`ops/scope-contract.md`| Startup threshold |
|`ops/evidence-finding-path.md`| Evidence chain |
|`case-review/SKILL.md`| Evidence diagram review and report handover |
|`ops/role-map.md`| role→skill |
|`ops/timeline-workitem.md`| Timeline and Overlay |
|`ops/sandbox-profile.md`| Tool comparison |
|`ops/skill-supply-chain.md`| Install security latch for external skill/MCP |
|`references/community-security-skills.md`| Community skill ecology (reference without merging the library) |
| `reverse-engineering/references/re-agent-workflow.md` | RE：triage→static→dynamic→synthesis |
|`pentest-tools/references/recon-pipeline.md`| Authorized reconnaissance pipeline + evidence door |

## Priority (high → low)

> The order must be consistent with the`priority`array of`config/routing.json`. To change the routing, only change JSON, and then change this table.`verify-routing-coherence.ps1`will parse this table.

| ID | Condition | PRIMARY |
|----|------|---------|
| **R4** | DSL VM / fireye / custom opcode VM |`reverse-engineering/dsl-vm-reverse/`|
| **R1** | APK / smali / jadx / apktool | `apk-reverse/` |
| **R2** | IPA / iOS / Objection / MobSF / mobile | `mobile-reverse/` |
| **R3** | JS signature / front-end encryption / jshook / CDP |`js-reverse/`|
| **R30** | browser extension reverse |`browser-extension-reverse/`|
| **R31** | macOS / Mach-O | `macos-reverse/` |
| **R33** | Go / Rust Binary |`go-rust-reverse/`|
| **R5** | .NET / dnSpy / de4dot / ConfuserEx | `dotnet-reverse/` |
| **R9** | Malicious Sample / YARA / Sandbox |`malware-analysis/`|
| **R21** | protocol / Protobuf / PCAP protocol |`protocol-reverse/`|
| **R22** | Ghidra / Open source decompilation |`ghidra-reverse/`|
| **R45** | Binary Ninja / Binja / HLIL / MLIL / Binary Ninja MCP | `binary-ninja-reverse/` |
| **R6** | IDA / Decompile / Disassembly Deep Digging |`ida-reverse/`|
| **R7** | radare2 / r2 | `radare2/` |
| **R8** | firmware / binwalk / IoT / EMBA |`firmware-pentest/`|
| **R34** | Hardware debug port / UART/JTAG |`hardware-security/`|
| **R28** | OT / ICS / Industrial control |`ot-ics/`|
| **R17** | pwn / ROP / stack exploit |`pwn-chain/`|
| **R16** | N-day / patch difference |`patch-diff-exploit/`|
| **R18** | EDR / anti-kill / syscall |`edr-bypass-re/`|
| **R24** | Windows / AD / Kerberos / AD CS | `windows-ad/` |
| **R37** | Federal Identity SAML/OIDC |`identity-federation/`|
| **R23** | Cloud / Container / K8s |`cloud-k8s/`|
| **R35** | Database Security |`database-security/`|
| **R25** | Forensics / Memory Dump / Timeline |`digital-forensics/`|
| **R44** | OSINT / Threat Intelligence / Public X IOC Supplement |`threat-intelligence/`|
| **R36** | Email/Phishing Analysis |`email-security/`|
| **R29** | Wi-Fi / Wireless Penetration |`wifi-wireless/`|
| **R38** | RF/SDR Research |`radio-sdr/`|
| **R32** | Thick client security |`thick-client/`|
| **R26** | Code Audit / SAST / Semgrep |`code-audit/`|
| **R27** | Threat Hunting / Detection Engineering / Blue Team |`threat-hunting/`|
| **R10** | Attack Chain / Red Team / Lateral / Full Penetration |`attack-chain/`|
| **R11** | Nmap / Nuclei / SQLMap / SRC / Penetration Tools |`pentest-tools/`|
| **R12** | API / GraphQL / BOLA / JWT attack |`api-security/`|
| **R13** | SBOM / Trivy / Supply Chain |`supply-chain-security/`|
| **R14** | LLM / Prompt Injection / Agent Security |`llm-security/`|
| **R15** | bindiff / symbol migration / PDB |`binary-diff/`|
| **R19** | Browser/Desktop Automation |`browser-automation/`|
| **R40** | Case/Evidence Chart Review |`case-review/`|
| **R20** | report / writeup |`docs-generator/`|
| **R39** | Diagram / Mermaid / Graphviz / PlantUML / Architecture Diagram |`diagram-generator/`|
| **R41** | CTF / AWD / Shooting range (single entrance, 40 sub-skills not expanded) |`ctf-sandbox/`|
| **R0** | Universal Reverse / Anti-Debugging / OLLVM / Unknown Binary |`reverse-engineering/`|

Missed the strong keyword → PRIMARY=`R0`and prompted to open`routing.md`(ambiguous appendix, not the second set of routers).

## boundary

| task | processing |
|------|------|
| pure CTF multi-type arrangement | PRIMARY`ctf-sandbox/`→ sidecar`../CTF-Sandbox-Orchestrator/`|

## Reading order

```text
RULES.md → MASTER-ROUTING.md → PRIMARY SKILL.md
  → (optional) routing.md three axes / field-journal
  → tool-index.md → bootstrap → ACT
```
