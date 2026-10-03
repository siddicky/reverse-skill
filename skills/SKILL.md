---
name: reverse-skill-router
description: Routes reverse engineering, exploitation, penetration testing, malware, mobile, firmware, browser automation, documentation, and security tasks to the appropriate specialist skill. Use when a task spans modules or the correct reverse-skill entrypoint is unclear.
---
# Reverse Engineering Skills Master Control

This directory contains a series of reverse engineering-related skill modules. Each subdirectory is an independent module containing `SKILL.md` describing its applicable scenarios, tool chains and workflows.

## CRITICAL: routing execution contract (must be executed immediately)

After reading this document, only "read/understood" replies are not allowed. Must be executed in order:

1. `NOW`: Run the platform's native router (Windows `scripts/master-route.ps1`; Linux/macOS/Kali `scripts/master-route.sh`), and set the PRIMARY from `config/routing.json`; if you have any questions, read the `routing.md` three-axis appendix.
2. `NOW`: Run the platform-native `case-init` to initialize `work/<case>/scope.md` for the current analysis project. **Do not ACT on the target until `auth.status=granted`.** For local offline samples, use the `offline-sample` preset with an explicit sample; `Force` must not bypass this authorization gate.
3. `ACT`: Open PRIMARY `SKILL.md` immediately to execute ACTION REQUIRED.
4. `NEXT`: The tool path only recognizes `tool-index.md`; missing tool → platform native bootstrap (manifest only).
5. Use Evidence→Finding→Path to conclude. report/journal is SHOULD unless the user wants deliverables.

**Identity**: See `ops/IDENTITY.md` (lightweight routing package + tool bootstrapping + journal; **not** a Z3r0-style platform).

If the route cannot be hit, you must first connect to the Internet to supplement the methodology and propose new skills. It is forbidden to force unmatched modules.

## Directive semantic level (RFC 2119)

- `MUST`: It must be executed. If it is violated, the task will fail.
- `MUST NOT`: Prohibited execution, violation is a security violation.
- `SHOULD`: In principle, you should do it. If you don’t do it, you must explain why.
- `MAY`: Optional action.
## current module

| module | catalog | applicable scenario |
|------|------|---------|
| **Universal reverse engineering** | `reverse-engineering/` | GDB / Frida / angr / Unicorn / Qiling / Anti-analysis confrontation / Full language platform reverse engineering / CTF pattern library |
| **APK reverse engineering** | `apk-reverse/` | Android APK unpacking, jadx decompilation, smali modification, Frida Hook, repackaging signature installation |
| **.NET / C# reverse engineering** | `dotnet-reverse/` | managed PE reverse engineering, dnSpyEx + de4dot deobfuscation (ConfuserEx/SmartAssembly/Babel), IL patch, Sharp* red team tool analysis, dnSpy MCP linkage |
| **IDA Pro Reverse** | `ida-reverse/` | IDA Pro MCP HTTP server (72 tools): decompilation, disassembly, data flow tracing, cross-reference |
| **Front-end JS reverse engineering** | `js-reverse/` | Browser-side signature positioning, encryption parameter analysis, runtime sampling, Node complement environment reproduction; priority is given to using the existing `js-reverse_*`, which requires a stronger browser/CDP/Hook to access jshookmcp, but the prerequisite is to download/register and enable the MCP server first |
| **radare2 analysis** | `radare2/` | CLI binary recon, disassembly, patch: r2/rabin2/rasm2/radiff2 |
| **CTF entry** | `ctf-sandbox/` | single PRIMARY; downstream is still sidecar `../CTF-Sandbox-Orchestrator/` |
| **Technical document writing** | `docs-generator/` | Automatically generate reverse report, penetration report, CTF writeup, and signature reverse report after the task is completed |
| **Evidence diagram review** | `case-review/` | Verification scope, Evidence→Finding→Path traceability, workitems, timeline and artifact hash |
| **Browser and desktop automation** | `browser-automation/` | Browser operation (Playwright) + Windows desktop application operation (OpenReverse UIA/CUA) + Network observation |
| **Cross-version symbol migration** | `binary-diff/` | There are old version symbols migrated to the new version, lack of PDB derivation, batch migration of function names after program update |
| **N-day patch difference→utilization** | `patch-diff-exploit/` | Locate vulnerability points from manufacturer patches, write PoC, and N-day weaponization (division of labor with binary-diff: this skill is on the attack side) |
| **RE→Exploit Chain** | `pwn-chain/` | From reverse engineering to available exploit: stack/heap/kernel pwn, pwntools, libc-database, CTF to real remote stabilization |
| **Firmware penetration chain** | `firmware-pentest/` | OWASP FSTM nine stages: extraction→EMBA automation→Firmadyne/QEMU simulation→AFL++ fuzz→real machine utilization |
| **EDR bypass reverse engineering** | `edr-bypass-re/` | Red team scenario: reverse EDR hook table/ETW/AMSI → direct syscall/Hell's Gate/hardware breakpoint/call stack spoof |
| **Penetration Testing Tool Chain** | `pentest-tools/` | Nmap/Nuclei/SQLMap/FFUF/Hashcat/Pentest Swarm and other 20+ penetration tools, exposed to AI through MCP |
| **Chart generation** | `diagram-generator/` | Generate Mermaid/Graphviz/PlantUML charts from natural language (attack path diagram, data flow diagram, architecture diagram, state machine) |
| **Attack chain orchestration** | `attack-chain/` | The general commander of multi-stage attack path planning and execution; complete penetration, HW drills, and cross-stage tasks from external network to domain control start here |
| **LLM/AI Security Test** | `llm-security/` | OWASP LLM + ASI Top 10: Prompt injection, tool abuse, memory poisoning, Agent hijacking, system prompt word extraction, **Agent compliance engineering** |
| **API Security Test** | `api-security/` | REST/GraphQL/WebSocket full protocol: BOLA/IDOR, JWT/OAuth attack, 10-stage methodology |
| **Supply chain security** | `supply-chain-security/` | SBOM/SCA/CI-CD pipeline: dependency scanning, container security, build integrity, vulnerability reachability verification |
| **Mobile Reverse Engineering** | `mobile-reverse/` | Android + iOS: Frida/Objection dynamic instrumentation, SSL Pinning/Root/jailbreak detection bypass, OWASP MASTG |
| **Malware Analysis** | `malware-analysis/` | Six stages of sample analysis, YARA/Sigma, anti-analysis detection, sandbox orchestration |
| **DSL virtual machine reverse engineering** | `reverse-engineering/dsl-vm-reverse/` | JS custom instruction set VM (IIFE + switch-case opcode); risk control/verification code engine, etc. |
| **Combat Contract ops** | `ops/` | Scope / Evidence Chain / Role / Timeline / Identity / Skill Supply Chain Security |
| **Community skill comparison** | `references/community-security-skills.md` | External security skill index and reference rules (blind installation is prohibited) |
| **Skill Supply Chain** | `ops/skill-supply-chain.md` | External skill/MCP mounting latch (AST10 lite) |
| **RE stage latch** | `reverse-engineering/references/re-agent-workflow.md` | triage→static→dynamic→synthesis |
| **Authorized reconnaissance pipeline** | `pentest-tools/references/recon-pipeline.md` | scope gate + hit ≠ verification |
| **Protocol reverse** | `protocol-reverse/` | Custom binary protocol / Protobuf / gRPC / PCAP frame layout |
| **Ghidra reverse** | `ghidra-reverse/` | Open source decompilation, headless, Ghidra MCP (main entrance without IDA) |
| **Binary Ninja Reverse** | `binary-ninja-reverse/` | HLIL/MLIL/LLIL, Python API, and optional community MCP/localhost HTTP integration |
| **Cloud/Container/K8s** | `cloud-k8s/` | IMDS/IAM, container escape surface, Kubernetes RBAC |
| **Windows / AD** | `windows-ad/` | Kerberos, AD CS, BloodHound, Relays and Domain Paths |
| **Digital Forensics** | `digital-forensics/` | Memory/disk timeline, PCAP traceability, IR preservation |
| **Code Audit/SAST** | `code-audit/` | Semgrep/CodeQL, White Box, Dangerous APIs and Authentication Review |
| **Threat Intelligence/OSINT** | `threat-intelligence/` | Open Source IOC Supplement, Activity Correlation, Independent Verification and Intelligence Handover |
| **Threat Hunting** | `threat-hunting/` | Hypothesis-driven hunting, Sigma detection engineering, blue team verification |
| **OT/ICS Industrial Control** | `ot-ics/` | Purdue Partitioning, PLC/SCADA, Passive Priority Assessment |
| **Wi-Fi/Wireless** | `wifi-wireless/` | Authorized Wireless Evaluation, Handshake/PMKID, Lab Rules |
| **Browser extension reverse** | `browser-extension-reverse/` | Chrome/Firefox extension, MV3 worker, permission plane |
| **macOS / Mach-O** | `macos-reverse/` | Signature, ObjC/Swift, LaunchAgent, macOS sample |
| **Thick Client** | `thick-client/` | Desktop C/S, local storage, IPC, update channel |
| **Go/Rust reverse** | `go-rust-reverse/` | Strip symbols Go/Rust, pclntab, panic string |
| **Hardware debugging interface** | `hardware-security/` | UART/JTAG/SWD, read-only extraction, handover firmware |
| **Database Security** | `database-security/` | MySQL/PG/MSSQL/Mongo/Redis Exposure and Configuration |
| **Email Security** | `email-security/` | Phishing Disassembly, SPF/DKIM/DMARC, BEC |
| **Federated Identity** | `identity-federation/` | SAML/OIDC/OAuth SSO Flow and Mismatch |
| **RF / SDR** | `radio-sdr/` | Authorized RF research, only | accepted by default

## unified entrance

When encountering tasks such as reverse engineering, CTF, packet capture, front-end signature, APK package modification, and binary analysis, enter in this order first:

1. Platform native router (Windows `scripts/master-route.ps1`; Linux/macOS/Kali `scripts/master-route.sh`) → PRIMARY (`config/routing.json`)
2. Platform native `case-init` → `scope.md`
3. OPEN PRIMARY `SKILL.md`
4. When in doubt, read `routing.md`, and when a local path is required, read `tool-index.md`

## Work ideas

These modules can be combined as needed:

1. **Get a target** → First look at the file type and select the corresponding analysis tool
2. **Quickly pick up leaks** → strings / rabin2 -z / ltrace to see if there are any direct clues
3. **In-depth analysis** → If you need to decompile → IDA; if you need dynamic Hook → Frida; if you need symbolic execution → angr
4. **If one path doesn't work, just change it** → If static analysis doesn't work, use dynamic analysis. If the Java layer doesn't work, use so. If the page observation is not enough, use breakpoints.

## Next-Step Menu Pattern

The sub-skill `MUST` provides 3-6 numbered options only if there are **genuine decision boundary** (two or more materially different, evidence-supported branches exist, and user selection changes the next action). If the next step is solely determined by gate / Evidence, `MUST` continues directly, and `ops/timeline-workitem.md` only records `decision_delta` + `carry_forward_refs`; `MUST NOT` re-outputs unchanged route/scope/auth/context for the manufacturing menu.

Format requirements:
- Each option is numbered (range 1-6)
- Each option describes a specific executable action (not an abstract direction)
- Include at least one "export report/writeup" option
- Include at least one option to "continue further analysis" or "change another approach"
- Includes a "Stop/Pause/Ask More Questions" exit when necessary

Example:
```
## Suggest next step (choose a number)

1. Deeply decompile `sub_140001000` to reconstruct the algorithm
2. Use Frida dynamic hooks to verify parameter hypotheses
3. Export currently named functions and generate a symbol migration YAML
4. Generate an analysis report for the current phase
5. Switch to radare2 for a lightweight reconnaissance comparison
6. Pause while I confirm the evidence gathered so far
```

## The directory is dynamically expanded

This directory will continue to grow. When you find a new subdirectory, read its `SKILL.md` to quickly understand its purpose.

When adding a skill, follow the standard process of `CONTRIBUTING.md` to ensure:
- The routing matrix can correctly distribute traffic
- The bootstrap system can automatically complete dependencies
- tool-index can reflect the new tool status

## Related resources

- This machine also has the **anything-analyzer** (port 23816) MCP server, which provides browser automation, HTTP capture and AI analysis capabilities
- `tool-index.md` records whether the native reverse tool is available, actual path, version and script reference
- `Readme.md` in the package root directory provides general installation and access instructions for Claude Code, Codex CLI and other code AI clients.

## Bootstrap on demand

When the workflow finds that a tool is missing, don't report an error directly. Unified call platform native bootstrap:

Windows：
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-root>\scripts\bootstrap-reverse.ps1" -Capability @('tool-name') -StartServices
```

Linux / macOS：
```bash
bash <skill-root>/scripts/bootstrap-reverse.sh tool-name --start-services
```

Kali：
```bash
bash <package-root>/kali/scripts/bootstrap-reverse.sh tool-name --start-services
```

Supported capabilities (from `scripts/bootstrap-manifest.json`): jadx, apktool, jeb-pro, binaryninja, frida, frida-ps, idalib-mcp, reqable-mcp, jshookmcp, xquik-mcp, anything-analyzer, idapro , r2, rabin2, adb, agent-browser, ghidra-mcp, seclists, proxycat, burpsuite-mcp, nmap, pentestswarm, binwalk, yara, pwntools, bkcrack

> JEB Pro is registered for **Manual License Installation** capabilities: bootstrap only outputs guidance, never downloads or circumvents commercial licenses. Reqable MCP only registers a fixed version of the official runtime, and users still need to install the Reqable desktop client themselves.
>
> For tools not registered in the list (such as unblob/EMBA, etc.) `MUST`, follow the manual installation steps in the skill document, and it is forbidden to pretend to be able to bootstrap.

`tool-index` will be automatically refreshed after the boot is completed.

## Precedent Files

Before performing any reverse engineering/exploitation operations, MUST read in sequence:

| reading order | file | when to read |
|------|------|--------|
| **#1** | `ops/scope-contract.md` + `case-init.ps1` | executable authorization gate. `precedent-auth.md` does not write granted |
| **#2** | `field-journal/precedent-reverse.md` or `precedent-pentest.md` | On demand — AI loads | only after hesitation

**#1 Pre-loading, #2 Lazy loading.**

## automatic evolution

After each reverse engineering/penetration task is completed, the experience must be written back to the `field-journal/` directory. See `RULES.md`'s "Hard Checklist after Task Completion" for details.

- Template: `field-journal/_template.md`
- Index: `field-journal/_index.md`
- Precedent: `field-journal/precedent-auth.md` → `precedent-reverse.md` → `precedent-pentest.md`
- Before starting a new task, check the index and precedents and reuse existing experience.

## Task completion self-check (MUST passes before claiming completion)

- [ ] Am I done matching the three axes of routing (target type + user intent + toolchain)?
- [ ] Did I read the target skill's SKILL.md after successful routing?
- [ ] When the route misses, do I propose adding a new skill instead of forcing a match?
- [ ] Am I using real toolpaths based on `tool-index`?
