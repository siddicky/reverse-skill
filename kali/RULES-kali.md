# Reverse/penetration/security task automatic routing rules (Kali Linux version)

> **This file is the Kali path adaptation layer, not the second set of behavior chains.** Behavior and authorization are subject to the repository root `RULES.md`.
> The core knowledge base (`skills/config/routing.json`, SKILL.md, references) is shared with the Windows version.
> **It is prohibited** to write this file to `~/.claude/CLAUDE.md` or other client global configurations. Core scripts must not write client global files.

Hot path (same as `RULES.md`): `skills/scripts/master-route.sh` → `case-init.sh` (no ACTs on target before `auth.status=granted`) → PRIMARY `SKILL.md`. Identity: `skills/ops/IDENTITY.md`. The script uses this directory `kali/scripts/*.sh`.

---

## Trigger keyword (exactly the same as Windows version)

- APK, Android reverse engineering, decompilation, smali, jadx, apktool, Frida, Hook
- Binary analysis, IDA, radare2, r2, disassembly, reverse engineering, RE, source code restoration, source code restoration, reverse restoration
- Front-end signature, encryption parameters, JS reverse engineering, jshookmcp, CDP, SourceMap
- Packet capture, HTTP capture, request replay, anything-analyzer
- CTF, Pwn, Web penetration, vulnerability exploitation, privilege escalation
- MCP reverse tool, idalib-mcp
- Repackaging, signing, certificate verification, root detection, anti-debugging
- so analysis, native hook, JNI
- Penetration testing, red team, security assessment, blue team, emergency response
- Write reports, write documents, produce reports, writeup, technical documents, penetration reports, reverse reports
- Browser automation, opening web pages, filling out forms, crawling, screenshots, automated login, Playwright, agent-browser, headless
- Symbol migration, bindiff, cross-version, PDB missing, function offset migration, symbol migration, version comparison, old version symbols
- N-day, Nday, patch difference, patch diff, patch tuesday, 1day, CVE recurrence, vulnerability restoration, ghidriff, Diaphora, DeepDiff, patch analysis
- pwn, stack overflow, heap overflow, ROP, ret2libc, ret2csu, one_gadget, libc-database, tcache, fastbin, kernel pwn, SMEP, SMAP, KASLR, modprobe_path, commit_creds, pwntools, GEF, pwndbg
- Firmware, firmware, IoT, binwalk, unblob, squashfs, UBI, JFFS2, Firmadyne, FAT, QEMU full system emulation, EMBA, firmware penetration, router firmware, embedded exploits, AFL++, boofuzz, UART, JTAG
- BurpSuite, Burp MCP, Intruder, Repeater, Collaborator, Agent History Analysis
- LLM security, AI security testing, prompt injection, jailbreak, jailbreak, Agent security, garak, PyRIT
- API security testing, GraphQL security, JWT attacks, supply chain security, SBOM, Trivy
- iOS reverse engineering, Objection, YARA, malware analysis, AI decompilation, LLM4Decompile
- Agent does not work, AI is lazy, skips steps, Prompt project, Agent compliance
- EDR bypass, AV bypass, anti-virus, unhook, direct syscall, indirect syscall, Hell's Gate, SysWhispers, ETW patch, AMSI patch, call stack spoofing, MITER T1562, CrowdStrike bypass, Defender bypass, SentinelOne bypass, pe-sieve
- Port scanning, Nmap, vulnerability scanning, Nuclei, SQL injection, SQLMap, directory brute forcing, FFUF, password cracking, Hashcat, Hydra, Metasploit, Impacket, pentestMCP
- SRC, Bug Bounty, public testing, bug bounty, HackerOne, WAF bypass, WAF bypass, IDOR, unauthorized access, any account
- Drawing, flow chart, architecture diagram, attack path diagram, sequence diagram, state diagram, data flow diagram, Mermaid, Graphviz, PlantUML, diagram
- Malware analysis, virus analysis, sample analysis, sandbox, YARA, IOC
- Kernel driver, Rootkit, LKM, IOCTL, DeviceIoControl
- Cryptography, encryption and decryption, AES, RSA, hash collision, signature verification
- Protocol reverse, custom protocol, Protobuf, serialization
- Firmware reverse engineering, IoT, binwalk, ARM, MIPS, embedded
- WASM, WebAssembly, Python bytecode, pyc, .NET, dnSpy, IL
- macOS、iOS、Mach-O、ObjC、Swift、Frida iOS
- Go reverse engineering, Rust reverse engineering, stripped binary, GoReSym
- memory dump, memory dump, forensics, forensics, steganography, steganography
- Cloud security, container escape, K8s, Docker, AWS, Azure
- Prompt injection, AI security, Agent security, LLM attack
- Internal-network pivoting, lateral movement, Pass-the-Hash, domain penetration, AD attack, BloodHound
- Privilege escalation, privilege escalation, SUID, Potato, UAC bypass
- Credential extraction, Mimikatz, Kerberoasting, DCSync, LSASS
- C2, remote control, persistence, backdoor, Cobalt Strike, rebound shell
- Blue Team, Detection, Defense, Incident Response, SIEM, EDR, Threat Hunting, IOC
- Mobile security testing, OWASP MASTG, APP security, unpacking, reinforcement analysis
- SSTI, template injection, SSTImap, XSS, XSStrike, cross-site scripting
- WordPress, WPScan, WPProbe, CMS penetration
- AdaptixC2, C2 framework, adversarial simulation, red team simulation, Atomic Red Team
- WiFi attack, wireless penetration, Fluxion, aircrack-ng, deauth
- NTLM relay, Coercer, authentication enforcement, PetitPotam
- WinRM, evil-winrm, Windows remote execution
- NetExec, nxc, CrackMapExec, SMB enumeration
- AI automatic penetration, HexStrike, MetasploitMCP, mcp-kali-server
- Pentest Swarm, pentestswarm, swarm penetration, Swarm AI, autonomous scanning, stigmergy
- Bug Bounty Automation, Attack Surface Management, ASM, Continuous Monitoring
- GEF, GDB enhancement, debugging framework
- Wireshark, tshark, PCAP analysis, packet capture analysis
- BurpSuite, Web proxy, interception requests, Intruder
- Responder, LLMNR poisoning, NBT-NS, MDNS
- BloodHound, AD Path, Attack Map, SharpHound
- Certipy, AD CS, certificate attack, ESC1, ESC8
- wfuzz, parameter fuzz, Web Fuzz
- objdump, strings, file, static analysis
- ProxyCat, proxy pool, IP rotation
- Red team, HW, offensive and defensive drills, RBI, initial breakthrough, boundary breakthrough
- Complete penetration, full-process penetration, from external network to intranet, from external network to domain control
- Attack surface assessment, attack path planning, attack chain, kill chain
- Get the shell, next step, post-infiltration, base expansion, deep penetration
- Near source penetration, BadUSB, Rubber Ducky, WiFi Pineapple, Proxmark3, RFID cloning
- EDR evasion, AV evasion, Shellcode loader, fileless attack
- Phishing emails, social engineering, OAuth phishing, HTML smuggling
- Supply chain attacks, component poisoning, third-party penetration
- Trace cleaning, anti-forensics, log cleaning, timestamp modification
- Cobalt Strike, Sliver, Havoc, Mythic, C2 framework

---

## Route entry

> **Detection method**: Find the parent directory of the directory where this file (`RULES-kali.md`) is located, which is the package root directory.

Hot path (same as `RULES.md` / `routing.json`):

1. `skills/scripts/master-route.sh -Hint "<Task>"` — PRIMARY
2. `skills/scripts/case-init.sh` — `scope.md`; ACT on the target is prohibited before `auth.status=granted`
3. PRIMARY `SKILL.md` ACTION REQUIRED
4. `skills/tool-index.md` — True path; if missing, `kali/scripts/bootstrap-reverse.sh`

---

## Execution principles (the same as the Windows version, only the commands are different)

### Tool usage
- **Never guess tool paths**, read `tool-index.md` first
- When tools are missing, first call `bootstrap-reverse.sh` to automatically complete them.
- Kali has a large number of pre-installed tools, and the probability of bootstrap failure is much lower than that of Windows
- After the automatic installation of the same tool fails 2 times, it stops retrying and outputs manual steps.
- When the MCP service port is inconsistent, ask the user for the actual port and help the user update the configuration.

### routing decisions
- When the route is not hit, don’t force it into the existing skill, but actively propose to add it.
- If one path doesn't work, just change it: static can't be changed to dynamic, Java layer can't read so, IDA can't be changed to r2
- Cross-module tasks use multiple skills in combination according to the "Path Crossing" chapter of `routing.md`

### Experience reuse
- **You must check** `field-journal/_index.md` before entering the route every time
- If you have similar experience, read the corresponding log first and reuse the verified solution.
- If the historical solution does not apply, explain why in a new log

### security boundary
- All operations must be within the scope of user authorization
- Penetration testing must confirm that the user has legal authorization (SRC/Bug Bounty/Owned System/CTF)
- Do not actively expand the attack surface and do not exceed the target range specified by the user
- Notify users immediately when high-risk vulnerabilities are discovered and wait for instructions before continuing.
- Do not retain unredacted sensitive information in reports or logs

### Output quality
- Key operations must give reproducible commands (don’t just describe the steps)
- Reverse analysis must mark the address/offset/function name (don't just say "a certain function")
- Penetration testing must give a complete PoC (curl command/script/screenshot path)
- Uncertain conclusions must be marked with a confidence level

---

## Complete behavior chain

```
1. Identify whether the task involves security or reverse engineering
2. Package root = the parent directory of this file
3. master-route.sh → PRIMARY（routing.json）
4. case-init.sh / scope.md — do not ACT on the target until auth.status=granted
5. Open PRIMARY SKILL.md
6. Missing tool → kali/scripts/bootstrap-reverse.sh
7. Do not write to client-global configuration
```

---

## Bootstrap commands (Kali version)

```bash
bash "<Root directory of this package>/kali/scripts/bootstrap-reverse.sh" <capability1> [capability2] ... [--start-services]
```

### Common combinations

```bash
# Configure Kali native MCP with one click (recommended for first use)
bash kali/scripts/bootstrap-reverse.sh mcp-kali-server metasploitmcp hexstrike-ai

# Install all new 2026.1 tools
bash kali/scripts/bootstrap-reverse.sh adaptixc2 atomic-operator sstimap xsstrike wpprobe fluxion gef

# AD/intranet penetration tool chain
bash kali/scripts/bootstrap-reverse.sh coercer evil-winrm-py netexec responder bloodhound certipy

# Reverse analysis tool chain
bash kali/scripts/bootstrap-reverse.sh jadx frida gef ghidra-mcp

# Web Penetration Toolchain
bash kali/scripts/bootstrap-reverse.sh sstimap xsstrike wpprobe nuclei
```

All supported capability names: jadx, apktool, frida, idalib-mcp, jshookmcp, xquik-mcp, anything-analyzer, idapro, r2, rabin2, adb, age nt-browser, ghidra-mcp, nmap, sqlmap, hashcat, hydra, gobuster, ffuf, msfconsole, nuclei, seclists, proxycat, mcp- kali-server, metasploitmcp, hexstrike-ai, pentestswarm, adaptixc2, atomic-operator, sstimap, xsstrike, wpprobe, fluxion, gef, evil-winrm-py, coercer, netexec, responder, crackmapexec, bloodhound, certipy, wfuzz, aircrack-ng

## Refresh tool index

```bash
bash "<Root directory of this package>/kali/scripts/refresh-tool-index.sh"
```

---

## MCP service management

### Kali native MCP (apt direct installation, no additional configuration required)

| service | package name | port | purpose | startup method |
|------|------|------|------|---------|
| mcp-kali-server | mcp-kali-server | 5000 | Kali official MCP, AI directly calls the terminal tool | `kali-server-mcp --port 5000` |
| MetasploitMCP | metasploitmcp | 8085/stdio | Metasploit Framework MCP interface | `metasploitmcp --transport stdio` |
| HexStrike AI | hexstrike-ai | — | 150+ Security Tools MCP Automation Platform | `hexstrike-ai` |

### Third-party MCP services

| service | port | purpose | startup mode |
|------|------|------|---------|
| Pentest Swarm AI | stdio | Swarm intelligent autonomous penetration (recon→classify→exploit→report) | `pentestswarm mcp serve` |
| idapro | 13337-13350 | IDA Pro reverse tool | `bash kali/scripts/ida-start.sh` |
| anything-analyzer | 23816 | Browser Automation + HTTP Capture | `cd ~/tools/anything-analyzer && pnpm dev` |
| jshookmcp | — | JS Hook/CDP/Network/AST | `npx -y @jshookmcp/jshook@0.3.4`（stdio） |
| ghidra | 8765 | Ghidra free decompilation | Ghidra GUI automatically monitors | after startup
| burpsuite | 9876 | BurpSuite Web Agent | BurpSuite Extension Startup |

### MCP Priority Recommendations (Kali 2026.1)

For penetration testing scenarios, the recommended MCP usage priorities are:

1. **pentestswarm** — Fully automatic group penetration, suitable for large-scale targets (1000+ subdomains) and continuous monitoring of Bug Bounty
2. **mcp-kali-server** — the most versatile, can call any terminal tool on Kali
3. **metasploitmcp** — Metasploit-specific, exploit/payload/session management
4. **hexstrike-ai** — automated orchestration, suitable for multi-tool linkage scenarios
5. **jshookmcp** — Web/JS reverse engineering only

Complete all penetration MCPs with one click:
```bash
bash kali/scripts/bootstrap-reverse.sh mcp-kali-server metasploitmcp hexstrike-ai pentestswarm
```

---

## Error handling strategy

| Scenario | What the AI ​​should do |
|------|-------------|
| bootstrap successful | Continue task |
| apt install failed | Check network/source, try `apt update` and try again |
| pip install failed | Try adding `--break-system-packages`, or it is recommended to use venv |
| GitHub download failed | Check the network/proxy and give the manual download link |
| The service port is inconsistent | Ask for the actual port and help the user update the MCP configuration |
| The same tool failed 2 times | Give complete manual steps and no longer try again |

---

## Kali’s unique advantage tips

AI in the Kali 2026.1 environment should know:

1. **Lots of tools pre-installed** — nmap/sqlmap/hashcat/hydra/metasploit/gobuster/ffuf/radare2/binwalk/burpsuite/wireshark/nikto/impacket/netexec/responder/bloodhound, etc. No need to install
2. **Native MCP support** — `mcp-kali-server`, `metasploitmcp`, `hexstrike-ai` three MCP tools have entered the official Kali repositories, `apt install` can
3. **2026.1 New tools** — AdaptixC2 (C2 framework), Atomic-Operator (red team testing), SSTImap (SSTI detection), XSStrike (XSS scanning), WPProbe (WP enumeration), Fluxion (WiFi social engineering), GEF (GDB enhancement)
4. **2025.4 New tools** — evil-winrm-py (WinRM remote execution), hexstrike-ai (AI security automation), bpf-linker
5. **Kernel 6.18** — Supports latest hardware, NetHunter wireless injection patch (QCACLD-3.0)
6. **Full Wayland support** — GNOME 49 + KDE Plasma 6.5, Wayland also supported in VM
7. **apt source is rich** — `apt install ghidra`, `apt install seclists`, `apt install coercer`, etc. can be done in one line
8. **Python environment is complete** — python3/pip3 is pre-installed, frida-tools can be directly pip installed
9. **No permission restrictions** — Default root or sudo no password
10. **Complete network tools** — nc/curl/wget/socat/proxychains/chisel etc. pre-installed
11. **SecLists path** — apt installed at `/usr/share/seclists/`
12. **Wordlists** — There are commonly used dictionaries such as rockyou under `/usr/share/wordlists/`
13. **LLM integration** — Kali official blog has a local LLM integration tutorial for Claude Desktop + Ollama + 5ire
14. **BackTrack Mode** — `kali-undercover --backtrack` switchable classic BackTrack 5 appearance (social engineering scenario)

---

## Prohibited Behavior (Same as Windows version)

- ❌ Do not start the reverse/penetration operation directly without reading routing.md
- ❌ Do not guess the tool path, it must be obtained from tool-index
- ❌ Do not skip the field-journal query and start the task directly
- ❌ Don’t skip the Checklist after completing the task
- ❌ Do not keep unredacted real target information in reports
- ❌ Do not expand the scope of penetration without user authorization
- ❌ Do not retry an automatic installation that has failed 2 times
- ❌ Don’t be silent—if you encounter a problem, you must inform the user immediately
- ❌ Don’t make up tool version numbers or function descriptions yourself

---

## Hard Checklist after task completion (cannot be skipped)

When the task is completed (the vulnerability has been verified/the reverse engineering has been completed/the flag has been obtained), the AI ​​**must** execute the following items one by one:

```text
□ 1. Generate formal reports (docs-generator skill)
- Use the corresponding template (reverse report/penetration report/CTF writeup/signature report)
- Must include: goal overview, complete steps, key evidence, and reproduction commands
- Output to the user project directory (not within the skill package)

□ 2. Generate diagrams (diagram-generator skill)
- At least 1 flowchart embedded in the report
- Type selection: Penetration → Attack Path Diagram / Reverse → Call Diagram / JS → Sequence Diagram / CTF → Problem Solving Process

□ 3. Write back field-journal (desensitized)
- According to field-journal/_template.md format
- Must include: pitfall records, reusable modes, tool chain discovery, and environment information
- Desensitization check: no real domain name/IP/Token/user name

□ 4. Precipitate the searched knowledge (if you searched online during this task)
- Write the searched valuable content into references/ of the corresponding skill
- Mark the source URL and date
- If new tools are discovered → update bootstrap-manifest.json
- If new scenarios are discovered → update routing.md + RULES-kali.md keywords

□ 5. Ask about community contributions
- "Do you want to contribute this experience to the community main repository? The data has been desensitized and only the field-journal file is submitted."
- User agrees → Create PR according to CONTRIBUTE-BACK.md process
- User rejected → Skip

□ 6. Update system index
- Update field-journal/_index.md (new entry)
- Check if updates are needed: routing.md/bootstrap-manifest/tool-index
- If new tools or new scenarios are discovered → perform corresponding updates
```

If the AI ​​does not perform the above checklist after the task is completed, the user can remind: "You forgot to write the report and write back the experience", and the AI ​​must make up for it immediately.

---

## Multitasking and interrupt handling

- If the user switches topics during task execution, first save the current progress to field-journal (marked as "Unfinished")
- When the user comes back to continue, restore the context from field-journal
- If the user gives multiple security tasks at the same time, execute them one by one according to priority and not in parallel (to avoid tool conflicts)
- The progress of long-term tasks (such as large file IDA analysis) must be reported regularly to avoid letting users think they are stuck.

---

## Internet knowledge supplement (must be used if you have search capabilities)

When AI has the ability to search on the Internet, it must actively search in the following scenarios:

| Scenario | What to search for | What to do after searching |
|------|---------|-------------|
| Encounters an unknown shell/protection/obfuscation | Searches for the unpacking method and tool of the shell | Writes the method into the references/| of the corresponding skill
| Encounters an unknown framework/protocol | Searches for methods to reverse engineer/penetrate the framework | Write references/or propose new skills |
| Tool error/incompatibility | Search error information + version compatibility | Write to field-journal Pitfall record |
| Discover new CVE/vulnerabilities | Search for PoC and exploit methods | Write to pentest-tools/references/ |
| Routing miss (new scenario) | Search methodologies and tools in this field | Propose new skills and attach the searched information |
| requires a specific Frida script | Search for a ready-made script on GitHub/CodeShare | Write to apk-reverse/references/ or use | directly
| requires specific payload | Search PayloadsAllTheThings/HackTricks | Write pentest-tools/payloads/ |
| tool version is out of date | Search for the latest version and breaking changes | Update bootstrap-manifest and documentation |

### Knowledge precipitation process after search

```text
1. Search for information
2. Verify the reliability of the information (prioritize official documents > GitHub > Blog > Forum)
3. Extract actionable content (commands/scripts/configurations/steps)
4. Write the corresponding location of this package:
- General methodology → references/*.md corresponding to skill
- Specific tool usage → references/ or SKILL.md corresponding to the skill
- Pitfall experience → field-journal/
- New tool discovery → kali/scripts/bootstrap-manifest.json + tool-discovery.sh
- New scene discovery → routing.md + RULES-kali.md keywords
5. Mark the source (URL + date) to facilitate subsequent verification of timeliness.
6. If the amount of information is large enough (new field), it is recommended to add independent skills
```

### Search quality requirements

- **Don’t just give users a link after searching** — Key content must be extracted and written into this package
- **Don’t blindly trust search results** — Verify against official documents and mark the confidence level
- **Priority to Chinese resources** (if users communicate in Chinese) - but technical details are subject to official English documents
- **Mark timeliness** — The security field changes rapidly, mark the search date, and mark expired content `[may be outdated]`

---

## Add Skill

When it is found that the routing matrix cannot cover the current task type, follow the `CONTRIBUTING.md` process to add a skill.

Path: `<Root directory of this package>/skills/CONTRIBUTING.md`

After adding, they must be updated simultaneously: routing.md, kali/scripts/bootstrap-manifest.json, kali/scripts/lib/tool-discovery.sh, kali/scripts/refresh-tool-index.sh.
