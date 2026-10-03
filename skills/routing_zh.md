# reverse skill routing matrix

 routes tasks to the most appropriate skill module by target type, user intent, and tool chain. This matrix is ​​mandatory by default and is not a recommendation.

## CRITICAL: Routing decision execution protocol

1. `MUST` completes the routing first and then executes it. "Do it first and then make up the routing" is not allowed.
2. `SHOULD` Read `MASTER-ROUTING.md` first or run `scripts/master-route.ps1` to determine PRIMARY; this table is used to complete difficult questions.
3. `MUST` Outputs your routing basis (target type/intent/toolchain hits at least one).
4. `MUST` completes `case-init` / `scope.md` (`ops/scope-contract.md`) before ACT on target: `auth.status=granted` + `network_profile`.
5. `MUST NOT` puts tasks into mismatched skills because they "look similar".
6. `MUST` supplements the methodology of networking when the route misses, and proposes a new skill.
7. `MUST NOT` only replies "please give specific tasks"; determinable steps should be started based on existing input first.
8. combat contract: `ops/` (evidence chain/role/timeline/IDENTITY).
## by target type

| Target type | Recommended entrance | Alternative solution |
|---------|---------|---------|
| APK / Android App | `mobile-reverse/SKILL.md` — Frida/Objection/MobSF full-platform mobile reverse engineer | `apk-reverse/` — static analysis, jadx decompilation; optional licensed JEB Pro cross-validation |
| iOS / IPA application | `mobile-reverse/SKILL.md` — iOS reverse + Frida/Objection | `mobile-reverse/references/ios-reverse-guide.md` — iOS specific |
| binary exe/dll/so/elf | `ida-reverse/` — IDA Pro decompilation | `radare2/` — CLI analysis, or `reverse-engineering/tools.md` — GDB/Unicorn |
| JavaScript/Web front-end | `js-reverse/` — 5-stage workflow | browser tool for anything-analyzer MCP, or browser/CDP/Hook capabilities for jshookmcp |
| HTTP packet capture/browser sampling/request replay | anything-analyzer MCP (23816) | Reqable MCP, `js-reverse/`, jshookmcp or `competition-web-runtime/` |
| Firmware / IoT | `firmware-pentest/` — OWASP FSTM Full Link: Extract → Simulate → Fuzz → Exploit | `reverse-engineering/platforms.md` — Static RE only / `reverse-engineering/tools.md` — Ghidra headless |
| Binary Ninja / Binja | `binary-ninja-reverse/` — HLIL/MLIL/LLIL + Python API | Explicitly enable community MCP/native HTTP adapter |
| WASM / Python bytecode / .NET | `reverse-engineering/languages.md` | Check the corresponding chapter by specific language |
| macOS / iOS | `reverse-engineering/platforms.md` — Mach-O/ObjC/Swift | — |
| Memory Dump / PCAP | `reverse-engineering/platforms.md` | `reverse-engineering/patterns*.md` |
| has case/evidence handover review | `case-review/SKILL.md`: Evidence diagram and fixity verification | `docs-generator/`: Final report |
| cryptography/encryption and decryption algorithm | `reverse-engineering/patterns*.md` — cryptography mode | `js-reverse/` (if front-end encryption) |
| protocol reverse / custom protocol | `reverse-engineering/platforms.md` — network protocol | `js-reverse/` (if WebSocket/HTTP) |
| Go / Rust binary | `reverse-engineering/languages-compiled.md` + `go-reverse.md` | `ida-reverse/` or `radare2/` |
|**CTF competition full stack**| `../CTF-Sandbox-Orchestrator/ctf-sandbox-orchestrator/SKILL.md` — master control entrance | routes to 40+ sub-skills by evidence surface |
|**CTF ZIP / PKZIP compression package question**| `../CTF-Sandbox-Orchestrator/competition-zip-archive/SKILL.md` — legacy ZipCrypto + `bkcrack` plaintext attack | takes precedence over password brute force cracking |
| Web Runtime / API | `../CTF-Sandbox-Orchestrator/competition-web-runtime/SKILL.md` | — |
| Cloud / Container / K8s | `../CTF-Sandbox-Orchestrator/competition-agent-cloud/SKILL.md` | — |
| Windows / AD / Identity | `../CTF-Sandbox-Orchestrator/competition-identity-windows/SKILL.md` | — |
| Forensics / PCAP / Steganography | `../CTF-Sandbox-Orchestrator/competition-forensic-timeline/SKILL.md` | — |
| Prompt Injection / Agent | `../CTF-Sandbox-Orchestrator/competition-prompt-injection/SKILL.md` | — |
| Mobile (Android/iOS) | `../CTF-Sandbox-Orchestrator/competition-android-hooking/SKILL.md` | — |
| Firmware / Malicious Sample | `../CTF-Sandbox-Orchestrator/competition-firmware-layout/SKILL.md` | — |
|**LLM Application / AI Agent**| `llm-security/SKILL.md` — OWASP LLM + ASI Top 10 | `../CTF-Sandbox-Orchestrator/competition-prompt-injection/SKILL.md` — CTF Scenario |
|**REST / GraphQL / WebSocket API**| `api-security/SKILL.md` — 10-stage methodology | `pentest-tools/SKILL.md` — Basic Web Penetration |
|**Software supply chain / SBOM / SCA**| `supply-chain-security/SKILL.md` — Six-layer governance framework | `pentest-tools/SKILL.md` — Dependency scanning tool |
|**Malware/virus samples**| `malware-analysis/SKILL.md` — Six-stage analysis + YARA/Sigma | `reverse-engineering/SKILL.md` — Generic reverse engineering only / `ida-reverse/` In-depth analysis |
|**Open Source Threat Intelligence / OSINT**| `threat-intelligence/SKILL.md` — IOC Supplement associated with activity | Public X/Twitter posts must be verified by independent sources |

## according to user intention

| users said | can refer to |
|--------|---------|
| "Decompile/IDA take a look" | `ida-reverse/SKILL.md` — IDA MCP workflow |
| "Restore source code/Restore to assembly/Reverse restore" | `reverse-engineering/SKILL.md` — Universal reverse + `ida-reverse/` or capstone static disassembly |
| "Frida hook/dynamic injection" | `reverse-engineering/tools-dynamic.md` — Frida chapter |
| "radare2/r2 analysis" | `radare2/SKILL.md` — CLI workflow |
| "Find front-end signature/encryption parameters" | `js-reverse/SKILL.md` — Observe→Capture→Rebuild |
| "jshookmcp / JS hook / CDP debugging" | `js-reverse/SKILL.md` — Still taking the same JS/Web reverse link; before calling, confirm that the MCP server has been downloaded, registered to the client, and enabled |
| "Reqable / Reqable MCP / Packet Capture Replay" | `pentest-tools/SKILL.md` — Local packet capture and API workflow within the authorization scope |
| "JEB / JEB Pro" | `apk-reverse/SKILL.md` — Permitted Android / ARM cross-validation; first confirm native installation |
| "APK unpack/repackage/modify smali" | `apk-reverse/SKILL.md` — decode→rebuild-sign-install |
| "Over anti-debugging/anti-detection" | `reverse-engineering/anti-analysis.md` |
| "What kind of confusion/VM is this" | `reverse-engineering/patterns*.md` — Check by mode |
| "Go/Rust/Swift reverse" | `reverse-engineering/languages-compiled.md` + `reverse-engineering/go-reverse.md` (Go specialization) |
| "Kernel driver/Rootkit/LKM" | `reverse-engineering/kernel-driver-reverse.md` — Kernel driver reverse engineering |
| "C++ vtable/virtual function/class recovery" | `reverse-engineering/kernel-driver-reverse.md` — C/C++ pattern recognition |
| "IOCTL/DeviceIoControl" | `reverse-engineering/kernel-driver-reverse.md` — Windows driver analysis |
| "Python bytecode/pyc" | `reverse-engineering/languages.md` — Python chapter |
| "Symbolic execution/angr" | `reverse-engineering/tools-dynamic.md` — angr chapter |
| "Simulation Execution/Unicorn" | `reverse-engineering/tools.md` — Unicorn Chapter |
| "Complement environment/Node recurrence" | `js-reverse/references/env-patching.md` |
| "CTF question/competition reverse" | `reverse-engineering/patterns-ctf*.md` |
| "CTF ZIP/PKZIP/bkcrack/compressed package plain text attack" | `../CTF-Sandbox-Orchestrator/competition-zip-archive/SKILL.md` |
| "Write reports/write documents/issue reports" | `docs-generator/` — Technical document writing |
| "Review case/Evidence chain/Traceability" | `case-review/SKILL.md`: Read-only Evidence graph review |
| "writeup" | `docs-generator/` — CTF writeup template |
| "Open web page/browser automation/fill form" | `browser-automation/SKILL.md` — Playwright browser operation |
| "Crawling pages/screenshots/automated login" | `browser-automation/SKILL.md` — Browser automation |
| "Playwright / headless" | `browser-automation/SKILL.md` — Browser Automation |
| "Operation Desktop Application/Windows Automation" | `browser-automation/SKILL.md` — OpenReverse Desktop Automation |
| "UIA/CUA/Desktop GUI operation" | `browser-automation/SKILL.md` — OpenReverse (UIA/CUA mode) |
| "OpenReverse" | `browser-automation/SKILL.md` — Desktop interaction + network observation |
| "Symbol migration/cross-version comparison" | `binary-diff/SKILL.md` — LLM batch symbol migration |
| "Missing PDB/old version symbol derivation new version" | `binary-diff/SKILL.md` — Cross-version symbol migration |
| "bindiff/function offset migration" | `binary-diff/SKILL.md` — Binary difference |
| "N-day/Patch differential/CVE recovery/1day weaponization" | `patch-diff-exploit/SKILL.md` — Patch→PoC→Pre-patch host |
| "Patch Tuesday/MSRC/Microsoft Update Catalog" | `patch-diff-exploit/references/patch-tuesday-workflow.md` |
| "ghidriff/Diaphora/DeepDiff (attack side)" | `patch-diff-exploit/references/diff-tools-comparison.md` |
| "pwn/stack overflow/ROP/ret2libc/write exploit" | `pwn-chain/SKILL.md` — RE→exploit complete pipeline |
| "Heap utilization/tcache/fastbin/unsorted bin" | `pwn-chain/references/heap-pwn.md` |
| "kernel pwn/kernel privilege escalation/modprobe_path/commit_creds" | `pwn-chain/references/kernel-pwn.md` |
| "pwntools/GEF/pwndbg/one_gadget/libc-database" | `pwn-chain/SKILL.md` |
| "Firmware Penetration/Router Firmware/IoT Vulnerability Exploitation" | `firmware-pentest/SKILL.md` — From extraction to real machine |
| "binwalk/unblob/SquashFS/UBI/JFFS2" | `firmware-pentest/references/extraction-methodology.md` |
| "EMBA/automated firmware audit/cve-bin-tool" | `firmware-pentest/references/emba-automated-analysis.md` |
| "Firmadyne/FAT/QEMU full system simulation/AFL++ fuzz" | `firmware-pentest/references/emulation-and-fuzz.md` |
| "EDR bypass/AV bypass/anti-kill/red team delivery" | `edr-bypass-re/SKILL.md` — reverse defender → targeted bypass |
| "direct syscall/indirect syscall/Hell's Gate/SysWhispers" | `edr-bypass-re/references/unhook-techniques.md` |
| "ETW patch/AMSI patch/telemetry blinding" | `edr-bypass-re/references/telemetry-blinding.md` |
| "ntdll hook/pe-sieve/EDR hook table" | `edr-bypass-re/references/hook-survey.md` |
| "Port Scan/Nmap" | `pentest-tools/SKILL.md` — Information Collection |
| "Vulnerability Scan/Nuclei" | `pentest-tools/SKILL.md` — Vulnerability Detection |
| "SQL Injection/SQLMap" | `pentest-tools/SKILL.md` — Web Penetration |
| "Directory Explosion/FFUF/Gobuster" | `pentest-tools/SKILL.md` — Web Penetration |
| "Password Cracking/Hashcat" | `pentest-tools/SKILL.md` — Password Cracking |
| "Penetration Testing/Active Scanning" | `pentest-tools/SKILL.md` — Penetration Toolchain |
| "SRC Burrowing/Bug Bounty/Public Test" | `pentest-tools/src-hunter/SKILL.md` — 19 categories playbook + H1 case |
| "WAF bypass/bypass" | `pentest-tools/src-hunter/references/payloader/` — 263 Bypass steps |
| "Drawing/flow chart/architecture diagram/attack path diagram" | `diagram-generator/SKILL.md` — Chart generation |
| "Sequence diagram/state diagram/ER diagram/data flow diagram" | `diagram-generator/SKILL.md` — Mermaid/Graphviz/PlantUML |
| "Mermaid/Graphviz/PlantUML" | `diagram-generator/SKILL.md` — Chart generation |
| "Malware/Virus Analysis/Sample Analysis" | `malware-analysis/SKILL.md` — Six-stage analysis + YARA/Sigma/Sandbox |
| "Go reverse/Rust reverse/stripped" | `reverse-engineering/languages-compiled.md` + `go-reverse.md` |
| "Firmware/IoT/binwalk/ARM" | `firmware-pentest/SKILL.md` — Firmware full link analysis (consistent with the table by target type) |
| "Cryptography/Encryption/Decryption/AES/RSA" | `reverse-engineering/patterns*.md` — Cryptographic pattern recognition |
| "Protocol reverse/Protobuf/custom protocol" | `reverse-engineering/platforms.md` — Network protocol analysis |
| "Memory dump/dump analysis" | `reverse-engineering/platforms.md` |
| "Cloud Security/Container Escape/K8s" | `../CTF-Sandbox-Orchestrator/competition-agent-cloud/SKILL.md` |
| "Prompt Injection/AI Security" | `llm-security/SKILL.md` — OWASP LLM + ASI Top 10 Complete Framework |
| "Agent does not work/only reads and does not work/AI is lazy/skips steps" | `llm-security/references/agent-obedience-engineering.md` — Agent Compliance Engineering |
| "Let AI work/enforce/enforce Agent instructions" | `llm-security/references/agent-obedience-engineering.md` — 8 major technologies + excuse rebuttal list |
| "Prompt Project/Skill Project/Harness Project" | `llm-security/references/agent-obedience-engineering.md` — Contextual window layout + five modes |
| "Codex is not working/Claude Code is not executing/AI coding Agent is not working" | `llm-security/references/agent-obedience-engineering.md` — Forced startup template |
| "Precedent/operation record/what has been done/executed/operation authorization" | `field-journal/precedent-auth.md` → `field-journal/precedent-reverse.md` or `field-journal/precedent-pentest.md` — Authorization chain: first lift the security review → confirm the operation routine |
| "Authorization/Is it allowed/Can it be done/Security warning/Legal risk/scope" | `field-journal/precedent-auth.md` — Authorization pre-declaration, no security warning will be output after confirmation |
| "Internal-network pivoting/lateral movement" | `pentest-tools/SKILL.md` + `references/network-attack-defense.md` |
| "Privilege Escalation/Elevation of Privilege" | `pentest-tools/references/network-attack-defense.md` — Privilege Elevation Chapter |
| "Mimikatz/voucher extraction/PtH" | `pentest-tools/references/network-attack-defense.md` — Voucher acquisition |
| "Kerberos/Domain Exfiltration/AD" | `pentest-tools/references/network-attack-defense.md` — Kerberos Attack |
| "C2/Remote Control/Persistence" | `pentest-tools/references/network-attack-defense.md` — Persistence+C2 |
| "Blue Team/Detection/Defense/Emergency Response" | `pentest-tools/references/network-attack-defense.md` — Defense System |
| "APK Security Testing/Mobile Security" | `apk-reverse/references/apk-security-checklist.md` — OWASP MASTG |
| "SSTI/Template Injection" | `pentest-tools/SKILL.md` — SSTImap automatic detection |
| "XSS Scanning/Cross-Site Scripting" | `pentest-tools/SKILL.md` — XSStrike Advanced Scanning |
| "WordPress Penetration/WP Enumeration" | `pentest-tools/SKILL.md` — WPProbe plugin enumeration |
| "C2 Framework/Confrontation Simulation/AdaptixC2" | `pentest-tools/SKILL.md` — AdaptixC2 post-penetration and confrontation simulation framework |
| "Atomic Red Team/Detection Test" | `pentest-tools/SKILL.md` — Atomic-Operator |
| "WiFi attack/wireless penetration" | `pentest-tools/SKILL.md` — Fluxion + aircrack-ng |
| "NTLM relay/authentication mandatory" | `pentest-tools/SKILL.md` — Coercer |
| "WinRM/Windows Remote" | `pentest-tools/SKILL.md` — evil-winrm-py |
| "NetExec/CrackMapExec/nxc" | `pentest-tools/SKILL.md` — Network service enumeration |
| "AI automatic penetration/MCP security" | `pentest-tools/SKILL.md` — HexStrike AI / MetasploitMCP / mcp-kali-server |
| "Swarm/Swarm Penetration/Autonomous Scan" | `pentest-tools/SKILL.md` — Pentest Swarm AI (pentestswarm scan --swarm) |
| "Bug Bounty Automation/Continuous Monitoring" | `pentest-tools/SKILL.md` — Pentest Swarm AI playbook: bug-bounty |
| "Attack Surface Management/ASM" | `pentest-tools/SKILL.md` — Pentest Swarm AI playbook: external-asm |
| "Red Team/Offensive and Defense Exercise/HW" | `attack-chain/SKILL.md` — Complete attack chain orchestration (information collection → breakthrough → privilege escalation → horizontal → maintenance) |
| "RBI/Initial Breakthrough/Border Breakthrough" | `attack-chain/SKILL.md` — Boundary Breakthrough Phase |
| "Near-source penetration/BadUSB/WiFi fishing" | `attack-chain/SKILL.md` — Near-source penetration chapter |
| "Delivery evasion/actual bypass EDR/Shellcode loader" | `attack-chain/SKILL.md` — EDR/AV bypass in the attack chain (actual delivery stage) |
| "Phishing/Social Engineering/Email Phishing" | `attack-chain/SKILL.md` — Phishing Attack Chapter |
| "Supply Chain Attack" | `attack-chain/SKILL.md` — Supply Chain Attack Chapter |
| "Trace Cleanup/Anti-Forensics" | `attack-chain/SKILL.md` — Trace Cleanup Chapter |
| "Complete Penetration Test/Full Process" | `attack-chain/SKILL.md` — Full Link Planning |
| "From the external network to the domain control/intranet" | `attack-chain/SKILL.md` — Cross-stage path orchestration |
| "Attack surface assessment/attack path planning" | `attack-chain/SKILL.md` — Path planning decision tree |
| "Get shell for next step/post-infiltration" | `attack-chain/SKILL.md` — Plan follow-up from current base |
| "The whole process of Internal-network pivoting" | `attack-chain/SKILL.md` — Lateral movement + privilege escalation + domain attack |
| "msfconsole stuck/orphan process/MSF calling specification" | `pentest-tools/references/msf-protocol.md` — MSF three correct modes + 6 big mistakes |
| "redaction/placeholder/share payload/redaction before writing writeup" | `field-journal/anonymization.md` — redaction placeholder specification |
| "Hydra/Online Explosion/SSH Explosion" | `pentest-tools/SKILL.md` — Online Password Explosion |
| "Nikto/Web Server Scan" | `pentest-tools/SKILL.md` — Web Vulnerability Scan |
| "Metasploit/msfconsole/exploit" | `pentest-tools/SKILL.md` — Exploitation framework |
| "Wireshark/packet capture analysis/PCAP" | `digital-forensics/` or `protocol-reverse/` |
| "Protocol reverse/Protobuf/custom protocol" | `protocol-reverse/SKILL.md` |
| "Ghidra/No IDA" | `ghidra-reverse/SKILL.md` |
| "Binary Ninja/Binja/HLIL/MLIL/Binary Ninja MCP" | `binary-ninja-reverse/SKILL.md` |
| "K8s/container escape/cloud security" | `cloud-k8s/SKILL.md` |
| "Domain Penetration/BloodHound/Certipy/Kerberoast" | `windows-ad/SKILL.md` |
| "Forensic/Volatility/Memory Dump" | `digital-forensics/SKILL.md` |
| "Code Audit/SAST/Semgrep" | `code-audit/SKILL.md` |
| "Open-source intelligence/threat intelligence/public X IOC enrichment" | `threat-intelligence/SKILL.md` — Public posts are unverified leads only |
| "Threat Hunting/Blue Team/Detection Engineering" | `threat-hunting/SKILL.md` |
| "Game Reverse/IL2CPP/Unity" | `reverse-engineering/SKILL.md` + seed-014 |
| "WiFi/wireless penetration/aircrack" | `wifi-wireless/SKILL.md` |
| "Browser extension/Chrome extension/crx" | `browser-extension-reverse/SKILL.md` |
| "Industrial Control/OT/ICS/SCADA/PLC" | `ot-ics/SKILL.md` |
| "macOS reverse/Mach-O" | `macos-reverse/SKILL.md` |
| "Thick Client/Desktop Client" | `thick-client/SKILL.md` |
| "Go reverse/Rust reverse" | `go-rust-reverse/SKILL.md` |
| "UART/JTAG/hardware debugging" | `hardware-security/SKILL.md` |
| "Database Security/Redis/Mongo" | `database-security/SKILL.md` |
| "Phishing Email/SPF/DKIM/DMARC" | `email-security/SKILL.md` |
| "SAML/OIDC/SSO Federation" | `identity-federation/SKILL.md` |
| "SDR/RF/HackRF" | `radio-sdr/SKILL.md` |
| "BurpSuite/Web Proxy/Interception" | `pentest-tools/SKILL.md` — Web Proxy |
| "Responder/LLMNR poisoning/NBT-NS" | `pentest-tools/SKILL.md` — Intranet poisoning |
| "BloodHound/AD path/attack graph" | `pentest-tools/SKILL.md` — AD attack path visualization |
| "Certipy/AD CS/Certificate Attack" | `pentest-tools/SKILL.md` — AD Certificate Services Attack |
| "wfuzz/parameter fuzz/Web Fuzz" | `pentest-tools/SKILL.md` — Web fuzz testing |
| "GDB/GEF/Debug/Breakpoints" | `reverse-engineering/tools.md` — Dynamic Debugging |
| "objdump/disassembly/ELF analysis" | `reverse-engineering/SKILL.md` — static analysis |
| "strings/string extraction" | `reverse-engineering/SKILL.md` — Quick Scout |
| "ProxyCat/Proxy Pool/IP Rotation" | `pentest-tools/SKILL.md` — Proxy Management |
| "LLM security/AI security testing/Prompt injection testing" | `llm-security/SKILL.md` — OWASP LLM + ASI Top 10 complete framework |
| "LLM jailbreak/jailbreak/system prompt word extraction" | `llm-security/references/prompt-injection-methodology.md` — Five-level progressive injection |
| "Agent Security/Tool Abuse/Memory Poisoning/Target Hijacking" | `llm-security/references/agent-security-testing.md` — Seven-stage Agent Test |
| "garak/PyRIT/AI Red Team" | `llm-security/SKILL.md` — LLM Security Toolchain |
| "API Security Testing/Interface Penetration" | `api-security/SKILL.md` — 10-Phase API Testing Methodology |
| "GraphQL Security/Introspection Attacks/Batch Query Bypass" | `api-security/references/rest-graphql-testing.md` — GraphQL Specialized |
| "JWT attack/OAuth bypass/alg:none" | `api-security/references/jwt-oauth-testing.md` — JWT + OAuth test |
| "BOLA/IDOR/BFLA/Object Level Authorization Bypass" | `api-security/SKILL.md` — Phase 3 Authorization Test |
| "Supply Chain Security/SBOM/SCA/Dependency Scan" | `supply-chain-security/SKILL.md` — Six-layer supply chain governance |
| "CI/CD Security/Pipeline Audit/Build Integrity" | `supply-chain-security/references/cicd-pipeline-security.md` — Pipeline Security |
| "Container Security/Image Scan/Trivy/Cosign" | `supply-chain-security/SKILL.md` — Container Security Chapter |
| "gitleaks/key scans/credential leaks" | `supply-chain-security/SKILL.md` — CI/CD Pipeline Security |
| "iOS Reverse/IPA/Objective-C/Swift/Mach-O" | `mobile-reverse/SKILL.md` — iOS Reverse + Frida/Objection |
| "Frida/Objection/Dynamic Instrumentation/SSL Unpinning" | `mobile-reverse/references/frida-objection-deep.md` — Frida in-depth usage |
| "Root detection bypass/jailbreak detection bypass/anti-debugging mobile terminal" | `mobile-reverse/references/anti-detection-bypass.md` — Multi-layer bypass |
| "Mobile Security Testing/MSTG/OWASP Mobile" | `mobile-reverse/SKILL.md` — OWASP MASTG Methodology |
| "YARA rules/Sigma rules/behavior detection rules" | `malware-analysis/references/yara-sigma-rules.md` — Rule writing methodology |
| "Sandbox Analysis/CAPE/Joe Sandbox/Malware Sandbox" | `malware-analysis/references/sandbox-orchestration.md` — Sandbox Orchestration |
| "Anti-analysis/anti-sandbox/anti-debugging/virtual machine detection" | `malware-analysis/references/anti-analysis-techniques.md` — 94 techniques |
| "IOC extraction/threat intelligence/malware analysis" | `malware-analysis/SKILL.md` — Six-stage analysis process |
| "AI decompilation/LLM reverse/neural decompilation" | `reverse-engineering/references/ai-assisted-re.md` — AI assisted reverse |

| Tools | Related modules |
|------|---------|
| IDA Pro (idapro_*) | `ida-reverse/` — MCP HTTP Server + 72 Tools |
| radare2 (r2/rabin2/rasm2) | `radare2/` — CLI + recon.ps1 |
| jadx / apktool | `apk-reverse/` — decode.ps1 / manifest-summary.ps1 |
| Frida | `reverse-engineering/tools-dynamic.md` |
| GDB/rr (generic debugging) | `reverse-engineering/tools.md` |
| Ghidra (headless) | `reverse-engineering/tools.md` + Ghidra MCP (free IDA replacement, auto-registration via bootstrap) |
| Binary Ninja / binary-ninja-mcp | `binary-ninja-reverse/` — Commercial GUI/API + explicitly enabled community MCP loopback bridge |
| Python 3 standard library | `case-review/`: read-only case Evidence graph review |
| angr / Qiling / Unicorn | `reverse-engineering/tools-dynamic.md` |
| BinDiff / Diaphora | `reverse-engineering/tools-advanced.md` |
| anything-analyzer MCP | MCP server on port 23816 (browser + HTTP capture + AI analysis) |
| jshookmcp | The enhanced MCP side of `js-reverse/`, suitable for browser/CDP/Hook/Network/SourceMap/AST scenarios; you need to download and enable | in the MCP client first
| agent-browser / Playwright | `browser-automation/` — Browser automation (open, click, form fill, crawl, screenshot) |
| OpenReverse (UIA/CUA) | `browser-automation/` — Windows desktop application automation + network observation (mitmproxy) |
| LLM symbol migration / BinDiff replacement | `binary-diff/` — Cross-version symbol batch migration (DeepSeek/GPT) |
| BinDiff / Diaphora / ghidriff / DeepDiff (attack side) | `patch-diff-exploit/` — Locate vulnerability points from patch → weaponize |
| binwalk v3 / unblob / EMBA / Firmadyne / FAT | `firmware-pentest/` — Firmware extraction/automated auditing/emulation |
| pwntools/GEF/pwndbg/ROPgadget/Ropper/one_gadget/libc-database | `pwn-chain/` — RE→available exploit |
| SysWhispers3 / Hell's Gate / pe-sieve / API Monitor | `edr-bypass-re/` — EDR bypass research and implementation |
| Nmap / Masscan | `pentest-tools/` — Port scanning, service identification |
| Nuclei / ZAP / Nikto | `pentest-tools/` — Vulnerability Scan |
| SQLMap / FFUF / Gobuster | `pentest-tools/` — Web Penetration (Injection/Explosion) |
| SSTImap | `pentest-tools/` — SSTI automatic detection and utilization (Kali 2026.1: `apt install sstimap`) |
| XSStrike | `pentest-tools/` — Advanced XSS scanner (Kali 2026.1: `apt install xsstrike`) |
| WPProbe | `pentest-tools/` — WordPress plugin enumeration (Kali 2026.1: `apt install wpprobe`) |
| Hashcat / John / Hydra | `pentest-tools/` — Password Cracker |
| Metasploit / Impacket | `pentest-tools/` — Exploitation framework |
| MetasploitMCP | `pentest-tools/` — Metasploit MCP interface (Kali 2026.1: `apt install metasploitmcp`) |
| mcp-kali-server | `pentest-tools/` — Kali official MCP, AI directly calls the terminal tool (`apt install mcp-kali-server`) |
| HexStrike AI | `pentest-tools/` — 150+ Security Tools MCP Automation (Kali 2025.4: `apt install hexstrike-ai`) |
| Pentest Swarm AI | `pentest-tools/` — Swarm intelligence autonomous penetration framework, stigmergic blackboard coordinates multiple agents (`go install` or Docker) |
| AdaptixC2 | `pentest-tools/` — Post-infiltration and confrontation simulation framework (Kali 2026.1: `apt install adaptixc2`) |
| Atomic-Operator | `pentest-tools/` — Atomic Red Team test execution (Kali 2026.1) |
| Coercer | `pentest-tools/` — Windows Authentication Enforcement/NTLM relay (`apt install coercer`) |
| NetExec (nxc) | `pentest-tools/` — Network service enumeration and utilization, CrackMapExec successor (Kali pre-installed) |
| evil-winrm-py | `pentest-tools/` — Python WinRM remote execution (Kali 2025.4) |
| Fluxion / aircrack-ng | `pentest-tools/` — WiFi security audit and crack (Kali pre-installed aircrack-ng, new fluxion in 2026.1) |
| Responder | `pentest-tools/` — LLMNR/NBT-NS/MDNS poisoning (Kali pre-installed) |
| BloodHound | `pentest-tools/` — AD attack path visualization (`apt install bloodhound`) |
| Certipy | `pentest-tools/` — AD Certificate Services Attack (`apt install certipy-ad`) |
| CrackMapExec / NetExec | `pentest-tools/` — Network service enumeration (nxc is CME successor, Kali comes pre-installed) |
| wfuzz | `pentest-tools/` — Web parameter fuzz testing (Kali pre-installed) |
| Wireshark / tshark | `pentest-tools/` — Network protocol analysis and PCAP parsing (Kali pre-installed) |
| BurpSuite | `pentest-tools/` — Web proxy, interception, vulnerability scanning (Kali pre-installed Community version) |
| BurpSuite MCP | `pentest-tools/` — 63 Tools AI Full Control (Agent History/Intruder/Repeater/Scanner/Collaborator), see `references/burpsuite-mcp-guide.md` |
| ProxyCat | `pentest-tools/` — Proxy pool management and IP rotation |
| objdump / strings / file | `reverse-engineering/` — Basic static analysis (Kali pre-installed) |
| Cobalt Strike / Sliver / Havoc / Mythic | `pentest-tools/` — C2 framework tool (same module as AdaptixC2) |
| Rubber Ducky / WiFi Pineapple / Proxmark3 | `attack-chain/` — Near-source penetration hardware |
| pentestMCP (Docker) | `pentest-tools/` — 20+ tools one-click MCP |
| Mermaid / Graphviz / PlantUML | `diagram-generator/` — Diagram generation (flow chart/sequence diagram/architecture diagram/attack path) |
| garak / PyRIT / promptfoo | `llm-security/` — LLM security testing (100+ injection probes/multiple rounds of orchestration) |
| Vespasian / Entropy / api.sh | `api-security/` — API discovery and attack scenario generation |
| jwt_tool | `api-security/` — JWT comprehensive testing (alg:none/key obfuscation/kid injection) |
| FireTail / Escape DAST | `api-security/` — GraphQL Specialization + Business Logic Security |
| OSV-Scanner / Trivy / Syft | `supply-chain-security/` — SBOM generation + SCA scanning |
| OWASP Dependency-Track | `supply-chain-security/` — Enterprise-grade continuous SCA monitoring |
| Gitleaks / truffleHog | `supply-chain-security/` — Key/credential scanning |
| Cosign / SLSA | `supply-chain-security/` — Build signature and traceability |
| Frida / Objection | `mobile-reverse/` — Dynamic instrumentation + Frida Gadget injection |
| JADX / apktool / MobSF | `mobile-reverse/` — Android static analysis |
| class-dump / jtool2 / Hopper | `mobile-reverse/` — iOS static analysis |
| CAPE Sandbox / ASD Azul | `malware-analysis/` — Sandbox automation orchestration |
| YARA / FLOSS | `malware-analysis/` — pattern matching + string deobfuscation |
| Sigma / Sigma CLI | `malware-analysis/` — SIEM Behavior Detection Rules |
| pe-sieve / Detect It Easy | `malware-analysis/` — Process Scan + Shell Detection |
| LLM4Decompile / Glaurung | `reverse-engineering/` — AI-assisted decompilation |

When  needs to confirm whether the native tool is available, where the path is, and which script will call it, check `tool-index.md` together and do not guess the path temporarily.

---

## Processing when routing misses

 If the current task cannot find a match in any of the above tables,**do not shoehorn it into the existing skill**. Follow the following process:

1. First confirm whether it belongs to the edge scene of the existing skill (the coverage of the existing skill can be expanded)
2. If is indeed a new type, we will proactively propose to the user a new skill:
   - Describes suggested skill names and coverage scenarios
   - describes the required tool chain
   - Describes the relationship with existing skills
3. After the user confirms, follow the `CONTRIBUTING.md` process to execute the new
4. After is added, update this routing matrix

**AI does not need to wait for the user to discover that it is missing. Routing failure itself is a signal to add a new skill.**

## path crossing (cross-module scenario)

 Some tasks span multiple modules. The following are common path intersections:

```
APK reverse path:
apk-reverse/scripts/decode.ps1 → Java layer analysis
↓ If the core is in .so
ida-reverse/ or radare2/ → so analysis
↓ If dynamic verification is required
  apk-reverse/scripts/frida-run.ps1 → Frida Hook

Front-end JS reverse path:
js-reverse/Observe → Target request
↓ Needs stronger browser/CDP/Hook/Network interface
jshookmcp → Do page runtime sampling, breakpoints, interception, SourceMap/AST assistance
↓ After confirming the entry function
js-reverse/Rebuild → Node local reproduction
↓ Need to make up for the environment
  js-reverse/references/env-patching.md

Binary reverse path:
radare2/scripts/recon.ps1 → Rapid reconnaissance
↓ In-depth analysis
ida-reverse/ → IDA decompilation
↓ Dynamic verification
  reverse-engineering/tools-dynamic.md → Frida/GDB

CTF competition path (via CTF-Sandbox-Orchestrator):
ctf-sandbox-orchestrator/SKILL.md → Create sandbox model
↓ Routing by dominant evidence plane
competition-web-runtime/ or competition-reverse-pwn/ or competition-identity-windows/
↓ If there is no way, return to the main control
ctf-sandbox-orchestrator → reroute

Cookie HMAC key reuse → background authentication bypass:
  competition-web-runtime/references/cookie-hmac-key-reuse-auth-bypass.md
↓ Applicable scenarios
URL contains access token, signed cookie, and background admin_session share the same key

Firmware penetration path:
firmware-pentest/references/extraction-methodology.md → Extract file system
↓ Get binary
firmware-pentest/references/emba-automated-analysis.md → EMBA automatic audit to find known CVEs
↓ Not enough known CVEs / looking for 0-day
firmware-pentest/references/emulation-and-fuzz.md → Firmadyne emulation + AFL++ fuzz
↓ Found crash
pwn-chain/references/stack-pwn.md or heap-pwn.md → write exploit
↓ Compacting machine
attack-chain/SKILL.md → integrated into attack chain

N-day weaponization path:
patch-diff-exploit/references/patch-tuesday-workflow.md → Get the binary before and after the patch
↓ Alignment symbols
patch-diff-exploit/references/diff-tools-comparison.md → BinDiff/ghidriff/Diaphora selection
↓ Positioning changes
patch-diff-exploit/references/root-cause-and-poc.md → LLM auxiliary root cause + write PoC
↓ Weaponization
pwn-chain/SKILL.md (constructing a stable exploit) + pentest-tools/references/msf-protocol.md (Metasploit modularization)

Red team delivery path:
attack-chain/SKILL.md → Select stage
↓ Need to bypass EDR
edr-bypass-re/references/hook-survey.md → Hook that identifies target EDR
↓ Choose bypass technology
edr-bypass-re/references/unhook-techniques.md → direct syscall / Hell's Gate
  edr-bypass-re/references/telemetry-blinding.md → ETW patch / AMSI patch
↓ Local verification
pe-sieve/API Monitor → Confirm unhook is clean
↓ Delivery
Back to the attack-chain post-infiltration phase
```
