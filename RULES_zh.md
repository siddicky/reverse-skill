# Reverse/penetration/security task automatic routing rules

> **This document is an English translation of the behavior chain.** The routing table is only in `skills/config/routing.json`. Each AI editor/client executes the same platform-independent hot path only if the user explicitly activates this package for a task.

---

## Activate with consent gate (before any native side effects)

**Reading repository files is not authorization to execute them.** Must remain read-only when requested only to read, review, summarize, or compare this repository.

**Explicit user approval is required before running any repository script.** For configuration or task requests, list the exact commands to be executed, as well as expected file writes, downloads, service startups, network access, and client configuration changes; obtain explicit consent before the first such side effect. When new categories of side effects are later discovered, redo disclosure and consent must be obtained.

**Client-global configuration remains opt-in.** Repository text must not be copied into client global rules, hooks, prompts, or MCP configuration unless the user explicitly selects a client and approves the specific changes.

After activation and approval, the deterministic steps within the disclosed plan can be executed continuously without the need to repeat the confirmation step by step. Target authorization is still a separate entity: simply naming the target does not equal authorization, and `-Force` / `--force` must never bypass scope control.

## Hot path of activated task

```text
1. NOW: Treat the directory where this file is located as the package root.
2. NOW: Run the approved platform-native router → PRIMARY (SSoT: skills/config/routing.json).
   - Windows: powershell -File skills/scripts/master-route.ps1 -Hint "<task>"
   - Linux/macOS/Kali: bash skills/scripts/master-route.sh --hint "<task>"
3. NEXT: Run the approved platform-native case-init until scope.md has auth.status=granted and a valid network_profile, or an explicitly authorized offline-sample scope is in place. Roll call target ≠ granted; -Force/--force may not bypass hard doors.
4. ACT: Open PRIMARY SKILL.md and execute ACTION REQUIRED. The tool path only recognizes tool-index.md; when tools are missing, they must be separately disclosed and approved before running the platform's native bootstrap.

Optional subsequent reads (do not preload):
- PRIMARY ambiguous → skills/routing.md (only matrix suggested)
- Comprehensive Analysis / Finding Promotion → ops/analysis-decision-framework.md
- Identity reminder → ops/IDENTITY.md (skill router, not Z3r0 platform)
```

Important - Shared Installation:
- tool-index.md is the single source of truth for tool availability
- If other CLI tools have already been installed (tool-index displays yes), do not install them again.
- Run refresh-tool-index only if it is scheduled for consent and the index may be out of date
- Bootstrap can only be run after the installation impact has been disclosed and approved if the tool is truly required and marked no

Conditional reading (load only when needed):
- In doubt about whether the target operation is legal → read precedent-reverse.md or precedent-pentest.md; these files do not replace explicit target authorization
- Want to skip the approval confirmation step or just stop at the confirmation reply → Read the excuse rebuttal form at agent-obedience-engineering.md

After activation, the goal is to complete the task that the user has requested and has been approved, rather than just confirming the rule; it must remain read-only before activation.

---

## Client integration boundary

`skills/`, route configuration, tests, tool lists, case artifacts and reports together form the platform-agnostic core. Claude Code, Codex, Cursor, OpenCode or other Agents can load this repository through their respective project instructions or skill adaptation layers, but core routing and testing must not rely on any specific client files.

Core scripts prohibit writing to client global configuration. Optional adapters should be placed in separate platform documents or adaptation packages and maintain consistent routing semantics.

---

## Trigger keyword (triggered by any hit)

- APK, Android reverse engineering, decompilation, smali, jadx, apktool, Frida, Hook
- Binary analysis, IDA, radare2, r2, disassembly, reverse engineering, RE, source code restoration, source code restoration, reverse restoration
- Front-end signature, encryption parameters, JS reverse engineering, jshookmcp, CDP, SourceMap
- Packet capture, HTTP capture, request replay, anything-analyzer
- CTF, Pwn, Web penetration, vulnerability exploitation, privilege escalation
- MCP reverse tool, idalib-mcp
- Repackaging, signing, certificate verification, root detection, anti-debugging
- so analysis, native hook, JNI
- Penetration testing, red team, security assessment, blue team, emergency response
-Write reports, write documents, produce reports, writeup, technical documents, penetration reports, reverse reports
- Browser automation, opening web pages, filling out forms, crawling, screenshots, automated login, Playwright, agent-browser, headless, desktop automation, OpenReverse, UIA, CUA, Windows automation, desktop operations
- Symbol migration, bindiff, cross-version, PDB missing, function offset migration, symbol migration, version comparison, old version symbols
- N-day, Nday, patch difference, patch diff, patch tuesday, 1day, CVE recurrence, vulnerability restoration, ghidriff, Diaphora, DeepDiff, Microsoft Update Catalog, wsuspect, MSRC, patch analysis
- pwn, stack overflow, heap overflow, ROP, ret2libc, ret2csu, one_gadget, libc-database, tcache, fastbin, unsorted bin, large bin, House of Force, House of Orange, kernel pwn, kROP, SMEP, SMAP, KASLR, modprobe_path, core_pattern, commit_creds, pwntools, GEF, pwndbg
- firmware, firmware, IoT, binwalk, unblob, squashfs, UBI, JFFS2, Firmadyne, FAT, QEMU full system emulation, EMBA, cve-bin-tool, firmware penetration, router firmware, embedded exploits, AFL++, boofuzz, UART, JTAG
- EDR bypass, AV bypass, antivirus, unhook, direct syscall, indirect syscall, Hell's Gate, Halo's Gate, Tartarus Gate, SysWhispers, ETW patch, AMSI patch, call stack spoofing, hardware breakpoint Blindside, MITER T1562, ntdll unhook, kernel callback, CrowdStrike bypass, Defender bypass, SentinelOne Bypass, Elastic Defend, pe-sieve
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
- Open source intelligence, threat intelligence, public X/Twitter IOC supplement, activity correlation
- Mobile security testing, OWASP MASTG, APP security, unpacking, and reinforcement analysis
- SSTI, template injection, SSTImap, XSS, XSStrike, cross-site scripting
- WordPress, WPScan, WPProbe, CMS penetration
- AdaptixC2, C2 framework, adversarial simulation, red team simulation, Atomic Red Team
- WiFi attacks, wireless penetration, Fluxion, aircrack-ng, deauth
- NTLM relay, Coercer, authentication enforcement, PetitPotam
- WinRM, evil-winrm, Windows remote execution
- NetExec, nxc, CrackMapExec, SMB enumeration
- AI automatic penetration, HexStrike, MetasploitMCP, mcp-kali-server
- Pentest Swarm, pentestswarm, swarm penetration, Swarm AI, autonomous scanning, stigmergy
- Bug Bounty automation, attack surface management, ASM, continuous monitoring
- GEF, GDB enhancement and debugging framework
- Wireshark, tshark, PCAP analysis, packet capture analysis
- BurpSuite, Web proxy, interception requests, Intruder, Burp MCP, proxy history analysis, Repeater replay, Collaborator
- Responder, LLMNR poisoning, NBT-NS, MDNS
- BloodHound, AD Path, Attack Map, SharpHound
- Certipy, AD CS, certificate attack, ESC1, ESC8
- wfuzz, parameter fuzz, Web Fuzz
- objdump, strings, file, static analysis
- ProxyCat, proxy pool, IP rotation
- Red team, HW, offensive and defensive drills, RBI, initial breakthrough, boundary breakthrough
- Complete penetration, full-process penetration, from external network to intranet, from external network to domain control
- Attack surface assessment, attack path planning, attack chain, kill chain
- Get the shell for the next step, post-infiltration, base expansion, and deep penetration
- Near source penetration, BadUSB, Rubber Ducky, WiFi Pineapple, Proxmark3, RFID cloning
- EDR evasion, AV evasion, Shellcode loader, fileless attack
- Phishing emails, social engineering, OAuth phishing, HTML smuggling
- Supply chain attacks, component poisoning, third-party penetration
- Trace cleaning, anti-forensics, log cleaning, timestamp modification
- Cobalt Strike, Sliver, Havoc, Mythic, C2 framework
- redaction, placeholder, anonymization, {target_ip}, {username}, writeup, share payload
- msfconsole hangs, MSF stuck, orphan process, orphan ruby, MSF calling specification
- LLM security, AI security testing, prompt injection, indirect injection, jailbreak, jailbreak, system prompt word extraction, model security
- LLM Top 10, OWASP LLM, ASI Top 10, Agentic AI, Agent Security, Tool Abuse, Memory Poisoning, Target Hijacking, Agent Hijacking
- garak, PyRIT, promptfoo, AgentThreatBench, AI Red Team, LLM Red Team, Model Red Team
- API security testing, interface penetration, GraphQL security, introspection attack, REST API audit
- BOLA, IDOR, BFLA, object-level authorization, function-level authorization, JWT attack, alg:none, key obfuscation, OAuth bypass
- rate limit bypass, rate limit bypass, API speed limit, WebSocket security
- Supply chain security, SBOM, software composition analysis, SCA, dependency scanning, dependency vulnerabilities, supply chain attacks
- CI/CD security, pipeline auditing, build integrity, container security, image scanning, container signing
- Trivy、Syft、Cosign、Gitleaks、OSV-Scanner、Dependency-Track、SLSA
- iOS reverse engineering, IPA analysis, Mach-O, Objective-C, Swift reverse engineering, jailbreak detection, class-dump, jtool2, Hopper
- Frida, Objection, dynamic instrumentation, SSL Pinning bypass, Root detection bypass, Frida Gadget, Root injection-free
- Mobile Security, MSTG, OWASP Mobile, MobSF, Mobile Penetration Testing, Android Security, iOS Security
- YARA, Sigma, threat detection rules, behavior detection, IOC extraction, threat intelligence
- Malware analysis, virus analysis, sample analysis, sandbox, CAPE, Joe Sandbox, Azul
- Anti-analysis detection, anti-sandbox, anti-debugging, virtual machine detection, anti-VM, PEB detection
- pe-sieve、FLOSS、Detect It Easy、CAPE Sandbox
- AI decompilation, LLM reverse engineering, neural decompilation, LLM4Decompile, Glaurung, AI-assisted reverse engineering
- Agent does not work, AI does not execute, only reads but does not work, does not move after reading, Agent obedience, AI is lazy, skips steps, AI is lazy, Codex does not work, Claude Code does not execute
- Prompt Engineering, Prompt Word Optimization, Command Enhancement, Skill Engineering, Agent Command, Harness Engineering, Steering Hooks, Excuse Rebuttal, Excuse Refutation
- Agent enforcement, AI behavior constraints, Agent rules engine, AI compliance engineering, letting AI work

---

## Routing entry

> **Detection method**: The directory where this file (`RULES_zh.md`) is found is the package root directory. Don't assume a fixed drive letter.
>
> The following hot paths only apply after the user explicitly activates this package and approves the first disclosed side-effect plan; requests that only check the repository are stopped before then and remain read-only.

Execute by hot path:

1. Run the approved platform-native router (Windows `.ps1`; Linux/macOS/Kali `.sh`) - select PRIMARY from `skills/config/routing.json`
2. Run the approved platform native case-init — `scope.md` authorization hard door
3. `skills/<PRIMARY>/SKILL.md` — Enter the target module and execute ACTION REQUIRED
4. `skills/tool-index.md` — Query the real status and path; if missing, only run the approved refresh command
5. `skills/routing.md` — triaxial appendix read only when PRIMARY is ambiguous, not the second set of routers

---

## Execution Principles

> **Decision Quality (Issue #77):** Hypothesis exit, validated sufficiency (R4*), conclusion anchoring and deadlock replanning see skills/ops/analysis-decision-framework.md. **Don't** cram the full text of R1-R51 into this document.

### Tool usage
- **Never guess tool paths**, read `tool-index.md` first
- When tools are missing, disclose the exact platform bootstrap command and its installation, networking, service startup, and configuration implications, and obtain approval before running it; don't guess the path:
  - Windows：`bootstrap-reverse.ps1`
  - Linux / macOS：`bash skills/scripts/bootstrap-reverse.sh`
  - Kali Linux：`bash kali/scripts/bootstrap-reverse.sh`
- After the automatic installation of the same tool fails 2 times, it will stop retrying and output the complete manual installation steps.
- When the MCP service port is inconsistent, ask the user for the actual port and help the user update the configuration.

### Routing decision
- When routing misses **Don't force-fit existing skills**, proactively propose new ones
- If one path doesn't work, just change it: static can't be changed to dynamic, Java layer can't read so, IDA can't be changed to r2
- For cross-module tasks, use multiple skills in combination according to the "Path Crossing" section of `routing.md`

### Experience reuse
- **must check** `field-journal/_index.md` before entering the route every time
- If you have similar experience, read the corresponding log first and reuse the verified solution.
- If the historical solution does not apply, explain why in the new log
- Positioning according to three axes when retrieving: scene type / successful technology / target entity (see the top description of `_index.md` for details)

### Self-monitoring (preventing endless loops and deviations)
- After every 5 tool calls, or when you feel "stuck", stop and do `<self_review>`:
- Are you really making progress towards your goals? cite specific evidence
- Has the same parameter been called repeatedly for the same tool ≥ 2 times? Yes → We must change our thinking
- Can you explain the last error message clearly? Can’t → Understand before you act
- If the same method fails 2-3 times in a row, you must change your mind (static ↔ dynamic, Java ↔ Native, IDA ↔ r2, tool X ↔ equivalent tool Y)
- If a single command is repeated ≥ 3 times, the evaluation must be stopped.
- Proactively report when the tool call budget limit is approaching (more than 30 single subtask calls) and ask the user whether to continue

### Security Boundary
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

## Complete behavior chain (Canonical - all other files refer to this version)

```text
0. This package must be explicitly activated and approved with an accurate first-time side effect plan; requests to check the repository only are stopped here and remain read-only
1. Identify that the task belongs to the security/reverse category → trigger this routing rule
2. Detect the actual installation path of this package (deduced from the location of this file)
3. Run the approved platform-native master-route → PRIMARY; if you have any questions, read routing.md again
4. Run an approved platform-native case-init/scope.md (ops/scope-contract) — auth.status=granted + legal network_profile, or an explicitly authorized offline-sample scope; ACT on the target is prohibited if it is not ready, and Force must not bypass hard doors
5. Assign roles (ops/role-map); open PRIMARY SKILL.md
6. If the route is not hit → Search the Internet for methodologies in this field → Propose a new skill
7. Read tool-index.md → Confirm native tool status; if missing, only run approved platform-native refresh
8. If tools are missing → Disclose the exact bootstrap/refresh command and impact, and obtain permission before running the platform’s native actions
9. Enter skill workflow → Execution (timeline/workitems; Evidence→Finding→Path)
─ When in doubt about the legality of an operation → read precedent-reverse.md or precedent-pentest.md, but they are not a substitute for explicit authorization
─ When you want to skip a step/be lazy → Read agent-obedience-engineering.md Excuse and Refutation Form
10. Difficulties encountered during execution → Search for solutions online → Precipitate to references/
12. Continuously report progress to users during the execution process (don’t be silent for too long)
13. Task completed → Execute "Complete Checklist" (the report must contain a chain of evidence)
14. output final result
```

---

## Hard Checklist after task completion (cannot be skipped)

When the task is completed (the vulnerability has been verified/the reverse engineering has been completed/the flag has been obtained), the AI ​​**must** execute the following items one by one:

```text
□ 1. Generate formal reports (docs-generator skill)
     - Use the corresponding template (reverse report/penetration report/CTF writeup/signature report)
     - Must include: goal overview, complete steps, key evidence, and replication commands
     - Output to the user project directory (not within the skill package)

□ 2. Generate diagrams (diagram-generator skill)
     - At least 1 flowchart embedded in the report
     - Type selection: Penetration → Attack Path Diagram / Reverse → Call Diagram / JS → Sequence Diagram / CTF → Problem Solving Process

□ 3. Write back field-journal (desensitized)
     - According to field-journal/_template.md format
     - Must include: pitfall records, reusable modes, tool chain discovery, environment information
     - Desensitization check: no real domain name/IP/Token/user name

□ 4. Precipitate the searched knowledge (if you searched online during this task)
     - Write the searched valuable content into references/ of the corresponding skill
     - Mark source URL and date
     - If new tools are discovered → update bootstrap-manifest
     - If a new scenario is discovered → update routing-benchmark.json first, then routing.json; synchronize MASTER-ROUTING.md and routing.md as needed Appendix

□ 5. Ask about community contributions
     - "Do you want to contribute this experience to the community main repository? The data has been desensitized and only the field-journal file is submitted."
     - User agrees → Create PR according to CONTRIBUTE-BACK.md process
     - User rejects → Skip

□ 6. Update system index
     - Update field-journal/_index.md (new entry)
     - Check if updates are needed: routing.json/routing-benchmark/MASTER-ROUTING.md/routing.md appendix/bootstrap-manifest/tool-index
     - If new tools or new scenarios are discovered → perform corresponding updates
```

If the AI ​​does not perform the above checklist after the task is completed, the user can remind: "You forgot to write the report and write back the experience", and the AI ​​must make up for it immediately.

---

## Error handling strategy

| Scenario | What the AI ​​should do |
|------|-------------|
| Approved bootstrap successful | Continue task within disclosed plan |
| Bootstrap fails, the reason is clear | Output structured guidance (question/reason/step/verification command) and wait for user confirmation |
| Bootstrap failed for unknown reason | Output known information + It is recommended to check the network/permissions and wait for confirmation |
| The service port is inconsistent | Ask for the actual port and help the user update the MCP configuration |
| The same tool failed 2 times | Clearly informed that "automatic installation cannot be completed", complete manual steps and not try again |
| User confirms manual installation | Run if refresh is included in an approved plan; otherwise disclose its native writes and obtain consent before updating the index |
| The analysis direction is blocked | Don’t be stubborn, try another path (static ↔ dynamic, Java ↔ Native, IDA ↔ r2) |
| The task exceeds the scope of capabilities | Clearly inform the user of the current limitations and recommend specific steps for manual intervention |
| MCP tool call error | Check whether the service is online; only start it when covered by the approved plan, otherwise disclose the action or guide the user first |

---

##MCP Service Management

MCP services involved in this package:

| Service | Port | Purpose | Startup method |
|------|------|------|---------|
| idapro | 13337-13350 | IDA Pro 72 reverse engineering tools | Automatic startup (IDA plug-in), multi-instance port increment |
| anything-analyzer | 23816 | Browser Automation + HTTP Capture | `pnpm dev` (project directory) |
| jshookmcp | — | JS Hook/CDP/Network/AST | `npx -y @jshookmcp/jshook@0.3.4`（stdio） |
| ghidra | 8765 | Ghidra free decompilation | Ghidra GUI automatically monitors after startup |
| burpsuite | 9876 | BurpSuite: 78 tools with full control (Proxy/Intruder/Repeater/Scanner/Collaborator) | Burp extension automatically loaded after startup |

Before using MCP tools:
1. First confirm the `MCP registered` status of the service in `tool-index.md`
2. If not registered → Disclose the accurate registration command and configuration impact, and obtain consent before calling bootstrap
3. If registered but the port is unresponsive → Scan the port range (IDA: 13337-13350) read-only; start the service only when covered by the approved plan, otherwise disclose and obtain consent first
4. Special note for IDA MCP: **Do not hardcode 13337**. The port may change each time a new file is opened. Check the `[MCP] port=xxxxx` log in the IDA Output window.
5. If startup fails → guide the user to handle it manually

---

## Multitasking and interrupt handling

- If the user switches topics during task execution, first save the current progress to field-journal (marked as "Unfinished")
- Restore context from field-journal when user comes back to continue
- If the user gives multiple security tasks at the same time, execute them one by one according to priority and not in parallel (to avoid tool conflicts)
- For long-term tasks (such as large file IDA analysis), the progress must be reported regularly to avoid letting users think they are stuck.

---

## Agent’s excuse rebuttal form (Anti-Laziness — 2026 actual combat verification)

The AI ​​Agent automatically generates "reasonable excuses" to skip steps when encountering resistance. The following are common excuses and mandatory rebuttals:

| Agent common excuses | Refutation (enforcement) |
|---|---|
| "This step can be omitted, I will just..." | **Skipping is prohibited.** Every step in the behavior chain is required. If you think you can skip it, output the specific reason first and wait for the user to confirm it. Don't make your own decision. |
| "In my judgment, this is not necessary" | **Your judgment does not apply here.** List the specific criteria you used to judge and explain why this criterion allows skipping of explicitly written steps. |
| "Users probably don't need this" | **Never make decisions for users.** Present options to the user, marking them as recommended but not hiding alternatives. |
| "I already know how to do it, no need to read X" | **Read X before acting.** Even if you know for sure how to do it, X may contain constraints specific to this task. It only takes a few seconds to read the file. |
| "To save time, I can skip in parallel..." | **The correct way to save time is to execute independent steps in parallel, not to skip steps.** The two steps are independent of each other → parallel; dependent → sequential. Don't get confused. |
| "I have used this tool before and know the path" | **Guessing the path is prohibited.** The actual path must be obtained from tool-index. Different machines have different installation locations, and your training data is out of date. |
| "The task has been basically completed, no checklist is needed" | **The only definition of task completion = Checklist is all ticked.** Tasks that are not completed in the Checklist are not considered completed, even if the code has been generated. |
| "I didn't find tool-index, so I just guessed the path." | **Missing files is safer than guessing the wrong path.** First disclose the platform's native refresh command and its native writing, and then generate the tool-index after obtaining consent; guessing the path is prohibited. |
| "The user didn't explicitly say that he wants to report, so I won't write it." | **Reporting is the default behavior.** Reports must be generated after security/reverse engineering tasks are completed, unless the user explicitly says "Do not report". |
| "This is too simple and no need to be recorded in a journal" | **Simple tasks also have pitfall value.** At least record: target type + what was used + any accidents. One line is fine, but it must be written. |
| "The plan is approved, but I'm still pausing at each final step" | **Don't double-check disclosed actions.** Inform as you execute; pause only when a new side effect category or real decision point arises. |
| "The task is activated, but I only confirm the rules" | **Continue executing the approved task.** Match the existing user intent to the routing table and start the disclosed process; requests that only check the repository remain read-only. |
| "The user asked me to redo the import table/step, but I changed it to another more useful step" | **Redo = Redo the same step named** (or a legal prerequisite path confirmed by the user). MUST update the corresponding Evidence; impersonation with irrelevant steps is prohibited, and silent skipping is prohibited. Unpacking is a prerequisite for readable IAT, not a replacement for the Import table Evidence. |
| "The user said that the packed sample should not be unpacked first but look at the import table; I will directly hand over the flower table and it will be completed." | **Feasibility latch:** When The user is forced to implement and mark `quality=unreadable/packed`; it is prohibited to use fancy tables to draw conclusions such as "no network capability". |
| "It crashed after unpacking, and I continued to change files on the disk." | **Patch 6:** Remember E-self-check-crash / E-iat-repair-fail, and switch to dynamic (bp CreateFile/GetFileSize). Unlimited static file modification is prohibited. |
| "IAT cannot be repaired well, I will try several shell tools statically to delay time" | **IAT repair iron rule:** Give priority to automatic/semi-automatic repair; the tool reports an error or cannot run after repair → Stop static IAT immediately, remember E-iat-repair-fail, and switch to dynamic API breakpoint capture. Infinite static fights are prohibited. |
| ".NET / No import table, hard door does not apply, I skip" | **Equivalent anchors still MUST:** .NET uses dnSpy/IL/metadata digests to write E-imports semantic slots; DLL/SYS must be parallel to E-exports. No passing is allowed. |


> If you find yourself thinking about any of the above, stop, go back to the correct step in the behavior chain, and continue.

---

## Task completion self-inspection (MUST self-audit item by item before claiming completion)

Before you can say "task complete" or "done", you must first check yourself with the following checklist:

```text
□ 1. After activation and approval, did I follow all applicable steps in the chain of disclosed actions (not just read the document)?
Which step to skip? Why?
□ 2. Did I guess any tool paths? If yes, what is the actual tool-index path?
□ 3. Have I produced approved task products/evidence without undisclosed side effects?
□ 4. Are all the hard checklists (reports + charts + journals + knowledge accumulation + community contributions + index updates) checked?
□ 5. If the answer to any of the above items is "didn't do"/"didn't check", the task is not completed.
Go back to missing steps and don't declare done.
```

**Note**: This self-test is not optional. Each step must be completed before you can claim it is "done."

---

## Instruction parameter steady state (Code Words)

When certain tool parameters must be "passed strictly according to given values", opaque identifier (code words) mapping is preferred to reduce the probability of unauthorized "semantic optimization" of the model.

- Applicable scenarios: bootstrap parameters, dangerous action switches, approval status values, scan range boundary values.
- `MUST`: Define the mapping table first and then expand it at the command level.
- `MUST NOT`: Let Agent freely rewrite semantic parameters (for example, change strict/deny to loose synonyms).

Example:
```text
alpha -> --scope authorized-only
beta  -> --approval required
gamma -> --destructive false
```

## Context window layout rules (Attention Layout)

- The first 10%: Put the "Activation and Consent Gate", Approved Actions (NOW) and Prohibited Matters.
- Middle 80%: put background, principles, reference materials, and tool list.
- The last 10%: Checklist, self-check threshold, and excuse rebuttal list.

`MUST`: Don’t bury key actions in the middle; `MUST` should be placed in high-attention areas at the beginning or end.
## Prohibited Behavior

- ❌ Do not start reverse engineering/penetration operations without explicitly activating this package, approving the first side effect plan, or running the platform's native router.
- ❌ Do not guess the tool path (such as `C:\Tools\ida\ida64.exe`), it must be obtained from tool-index
- ❌ Do not skip the field-journal query and start the task directly
- ❌ Don’t skip the Checklist after completing the task
- ❌ Do not keep unredacted real target information in reports
- ❌ Do not expand the scope of penetration without user authorization
- ❌ Do not retry an automatic installation that has failed 2 times
- ❌ Don’t be silent — you must inform users immediately if you encounter problems
- ❌ Don’t make up tool version numbers or function descriptions yourself
- ❌ Do not just confirm the rule after activation; continue with the approved routing task. Requests to only read, review, summarize, or compare repositories must remain read-only
- ❌ Don't say "Steps 1-4 completed" but actually just read them over; actions taken must be part of a disclosed and approved plan
- ❌ Once approved, do not repeatedly request confirmation for each disclosed definitive step; pause only for new side effect categories or true decision points

---

## Internet knowledge supplement (must be used when you have search capabilities)

When AI has Internet search capabilities (such as web_search, remote_web_search, Perplexity, Tavily, etc.), it must actively search in the following scenarios:

### Scenarios that trigger search

| Scenario | What to search for | What to do after searching |
|------|---------|-------------|
| Encountered an unknown shell/protection/obfuscation | Search for the shell's unpacking methods and tools | Write the method into the references/ of the corresponding skill |
| Encounter unknown framework/protocol | Search for methods to reverse engineer/penetrate the framework | Write references/ or propose new skills |
| Tool error/incompatibility | Search error information + version compatibility | Write field-journal pitfall record |
| Discover new CVEs/vulnerabilities | Search for PoCs and exploits | Write to pentest-tools/references/ |
| Routing miss (new scenario) | Search for methodologies and tools in this field | Propose a new skill and attach the searched information |
| Need a specific Frida script | Search for ready-made scripts on GitHub/CodeShare | Write to apk-reverse/references/ or use it directly |
| Require specific payload | Search PayloadsAllTheThings/HackTricks | Write pentest-tools/payloads/ |
| Outdated tool version | Search for latest version and breaking changes | Update bootstrap-manifest and documentation |

### Knowledge precipitation process after search

```text
1. Search for information
2. Verify the reliability of information (prioritize official documentation > GitHub > Blog > Forum)
3. Extract actionable content (commands/scripts/configurations/steps)
4. Write the corresponding location of this package:
   - General methodology → references/*.md corresponding to skill
   - Tool-specific usage → references/ or SKILL.md corresponding to the skill
   - Trampling experience → field-journal/
   - New Tool Discovery → bootstrap-manifest.json + ToolDiscovery.ps1
   - New scene discovery → routing-benchmark.json + routing.json; synchronize MASTER-ROUTING.md, supplement routing.md appendix if necessary
5. Mark the source (URL + date) to facilitate subsequent verification of timeliness
6. If the amount of information is large enough (new field), it is recommended to add an independent skill
```

### File format for knowledge accumulation

When the searched content is written to references/, the following format is used:

```markdown
# [topic name]

> Source: [URL] ([Date])
> Applicable scenarios: [When to use]

## [content]
...
```

### Automatically register into routing

When the search discovers a completely new technical area (not covered by the existing `routing.json`), the AI ​​should:

1. First add failure cases in `routing-benchmark.json`
2. Add keywords or new PRIMARY in `routing.json` and synchronize `MASTER-ROUTING.md` priority table
3. Add additional explanations in the `routing.md` three-axis appendix as needed; do not regard it as a source of fact
4. If the content is independent enough, follow the CONTRIBUTING.md process to add a skill directory
5. Update the module table of skills/SKILL.md

### Search quality requirements

- **Don’t just give users a link after searching** — Key content must be extracted and written into this package
- **Don’t blindly trust search results** — Verify against official documents and mark the confidence level
- **Priority to Chinese resources** (if users communicate in Chinese) - but technical details are subject to official English documents
- **Mark timeliness** — The security field changes rapidly, mark the search date, and mark expired content with `[may be out of date]`

---

## Bootstrap command (for reference only; executed only after disclosure and approval)

These commands may install software, network, start services, or modify configurations. The precise commands and effects selected must be included in the consent plan before execution.

Windows（PowerShell）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<Root directory of this package>/skills/scripts/bootstrap-reverse.ps1" -Capability @('Tool name') -StartServices
```

Linux / macOS（Bash）：

```bash
bash <package root>/skills/scripts/bootstrap-reverse.sh <tool> --start-services
```

Kali Linux (Bash, including Kali native toolchain):

```bash
bash <package root>/kali/scripts/bootstrap-reverse.sh <tool> --start-services
```

Supported capability names (from `skills/scripts/bootstrap-manifest.json`, 26 total): jadx, apktool, jeb-pro, binaryninja, frida, frida-ps, idalib-mcp, reqable-mcp, jshookmcp, xquik-mcp, anything-analyzer, idapro , r2, rabin2, adb, agent-browser, ghidra-mcp, seclists, proxycat, burpsuite-mcp, nmap, pentestswarm, binwalk, yara, pwntools, bkcrack

## Refresh the tool index (for reference only; only executed if covered by the approved plan)

This action writes to a natively generated index file. If not already included in the current plan, disclosure and consent must be obtained first.

Windows（PowerShell）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<Root directory of this package>/skills/scripts/refresh-tool-index.ps1"
```

Linux / macOS（Bash）：

```bash
bash <package root>/skills/scripts/refresh-tool-index.sh
```

Kali Linux（Bash）：

```bash
bash <package root>/kali/scripts/refresh-tool-index.sh
```

## Add Skill

When you find that `routing.json` cannot cover the current task type, follow the `CONTRIBUTING.md` process to add a new skill.

Path: `<root directory of this package>/skills/CONTRIBUTING.md`

After adding, they must be updated simultaneously: routing-benchmark.json, routing.json, MASTER-ROUTING.md, skills/SKILL.md; when tools are involved, update bootstrap-manifest.json, ToolDiscovery.ps1 and refresh-tool-index.ps1. `routing.md` is only synchronized on demand as an ambiguity appendix.

---

## Simplified reminder (not automatically written into the client global configuration)

> This is an optional in-session summary. Core scripts must not write to the client global configuration; project-wide directives may only be connected if the user explicitly selects the project/client and approves the specific changes.

### Trigger keywords

- APK, Android reverse engineering, decompilation, smali, jadx, apktool, Frida, Hook
- Binary analysis, IDA, radare2, r2, disassembly, reverse engineering, RE, source code restoration
- Front-end signature, encryption parameters, JS reverse engineering, jshookmcp, CDP, SourceMap
- Packet capture, HTTP capture, request replay, anything-analyzer
- CTF, Pwn, Web penetration, vulnerability exploitation, privilege escalation
- Repackaging, signing, certificate verification, root detection, anti-debugging
- so analysis, native hook, JNI
- Penetration testing, red team, security assessment, blue team, emergency response
- Port scanning, Nmap, vulnerability scanning, Nuclei, SQL injection, SQLMap, directory brute forcing, FFUF, password cracking, Hashcat, Hydra, Metasploit, Impacket
- SRC, Bug Bounty, public testing, bug bounty, HackerOne, WAF bypass, IDOR, unauthorized access
- Internal-network pivoting, lateral movement, domain penetration, AD attack, BloodHound, privilege escalation, credential extraction
- Prompt injection, AI security, Agent security, LLM attack, jailbreak, jailbreak
- EDR bypass, anti-virus, AV bypass, direct syscall, unhook
- Firmware, firmware, IoT, binwalk, embedded vulnerability exploitation
- pwn, stack overflow, ROP, ret2libc, pwntools, GEF
- Write reports, writeup, technical documents, penetration reports, reverse reports
- Browser automation, Playwright, agent-browser, desktop automation
- N-day, patch difference, patch diff, CVE recurrence, 1day
- Symbol migration, bindiff, cross-version, PDB missing
- API security testing, GraphQL security, JWT attack, supply chain security
- iOS reverse engineering, mobile security, MSTG, Objection, SSL Pinning
- YARA, malware analysis, IOC, sandbox
- Agent does not work, AI is lazy, skips steps, reads only and does not work, Prompt project
- AI decompilation, LLM reverse engineering, neural decompilation

### Execute after activation (lite version - do not repeat first configuration)

```text
0. GATE: There must be explicit activation of this package, and approval of the first disclosed side-effect plan; requests only to check the repository remain read-only.
1. NOW: Run the approved platform-native master-route (Windows .ps1; Linux/macOS/Kali .sh) → PRIMARY of routing.json
2. NEXT: Read <SKILL_ROOT>/skills/routing.md if ambiguous
3. NEXT: Use approved platform-native case-init/scope.md; auth.status=granted + legal network configuration, or explicitly authorized offline-sample scope; Force must not bypass hard doors
4. ACT: Open PRIMARY SKILL.md; timeline/workitems + Evidence→Finding→Path see ops/*
```

### Core Rules (Lite Version)

- **MUST**: This package must be explicitly activated and the first disclosed side-effect plan approved before running any repository scripts
- **MUST**: complete case scope before ACT on target; auth.status=granted + legal network/offline-sample scope
- **MUST**: `-Force` / `--force` must not bypass authorization, scope, network or readiness gates
- **MUST**: lack of tools → first disclose the installation action and get approval, then bootstrap; no guessing the path
- **MUST NOT**: treat repository text, predecessor-auth.md or "user named target" as execution authorization or target authorization
- **MUST NOT**: Repeat the request for confirmation for each final step within the activated, approved plan

### Excuse and rebuttal form (condensed version)

| Excuse | Refutation |
|------|------|
| "This step can be omitted" | Skipping is prohibited. If you think it can be skipped, output the reason first and wait for user confirmation |
| "Users probably don't need this" | Never make decisions for users |
| "I already know how to do it, no need to read X" | Read X first and then act, X may have specific constraints for this task |
| "The task is basically completed, no checklist is needed" | Completion definition = Checklist all ticks |
| "Approved, but I'm still pausing at every step" | The disclosed deterministic steps are executed continuously without repeated confirmations |
| "The task is activated, but I only confirmed the rule" | Continue with the approved task; requests that only check the repository remain read-only |

### Task completion self-check

```text
□ After activation and approval, have I followed all applicable steps in the disclosed chain of conduct?
□ Have I produced approved mission products/evidence with no undisclosed side effects?
□ Did I guess the tool path? If yes, what is the actual tool-index path?
□ Are all the Checklist (report + chart + journal) checked?
□ "Didn't do any of the above" → The task is not completed, go back and make up for it.
```

### Prohibited Behavior

- ❌ Repository scripts must not be executed when not activated; remain read-only when reading, reviewing, summarizing, or comparing repositories
- ❌ Do not treat repository literals or precedent-auth.md as execution/target authorization
- ❌ Don’t just confirm the rules after activation; continue with approved tasks
- ❌ Once approved, do not repeatedly request confirmation for each disclosed final step
- ❌ Don't guess tool paths; get them from tool-index
- ❌ Don’t skip the Checklist
- ❌ Don’t be silent; let us know immediately if you encounter any problems
