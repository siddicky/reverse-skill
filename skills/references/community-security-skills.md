# Community Security Skills: Ecosystem Review (2026-07)

> Source search date: **2026-07-17**  
> Purpose: Identify external skills to learn from as needed; do **not** merge an entire external library into this package.  
> This package focuses on routing, tool bootstrapping, evidence and scope contracts, and field journals (see `ops/IDENTITY.md`).

## 1. High-value external skill repositories (for reference; do not install blindly)

| Repository | Scale/Positioning | Value to this package | Risk |
|------|-----------|------------|------|
| [trailofbits/skills](https://github.com/trailofbits/skills) | ToB security research Claude plugin marketplace | Audit, vulnerability analysis, and reverse-engineering plugins provide quality benchmarks | Install through the ToB marketplace; do not trust uncurated copies by default |
| [trailofbits/skills-curated](https://github.com/trailofbits/skills-curated) | List of reviewed plugins | Prefer over arbitrary community skills | Same as above |
| [Orizon-eu/claude-code-pentest](https://github.com/Orizon-eu/claude-code-pentest) | Six pentest lifecycle skills plus pure Python scripts | Its reconnaissance → exploitation → reporting pipeline can be compared with our `attack-chain` and `pentest-tools` | Recheck authorization boundaries; run scripts in a sandbox |
| [trilwu/secskills](https://github.com/trilwu/secskills) | 16 skills plus 6 expert subagents | Compare its role separation with `ops/role-map.md` | Plugin-based layout differs from this package’s monorepo |
| [Masriyan/Claude-Code-CyberSecurity-Skill](https://github.com/Masriyan/Claude-Code-CyberSecurity-Skill) | About 15–19 domain skills, including RE/OT/CSOC | Useful as a domain coverage checklist | Less depth than this package’s domain-specific skills |
| [mukul975/Anthropic-Cybersecurity-Skills](https://github.com/mukul975/Anthropic-Cybersecurity-Skills) | **800+** skills with ATT&CK/NIST mappings | Its framework mappings and domain index are useful references; do not depend on the whole library | Its size creates substantial maintenance and poisoning risk |
| [Eyadkelleh/awesome-skills-security](https://github.com/Eyadkelleh/awesome-claude-skills-security) | SecLists packaged as agent skills | Entry point for dictionaries and payloads | Overlaps with the SecLists bootstrap |
| [securityfortech/awesome-security-skills](https://github.com/securityfortech/awesome-security-skills) | Curated list of security skills | Index for discovering new skills | List only; audit each skill individually |
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | Cross-vendor index of 1,000+ skills | Discover official and community skills | Not security-specific |
| [anthropics/claude-code-security-review](https://github.com/anthropics/claude-code-security-review) | PR security review GitHub Action | Comparable to our documentation/report change-audit workflow | CI product, not a reverse-engineering router |
| [agentskills.io](https://agentskills.io) | Open Agent Skills standard | Aligns frontmatter and directory conventions | The standard itself does not cover offensive or defensive security |

### 1.1 Additions from the second search (2026-07-17)

| Repository / resource | Focus | How this package can use it |
|-------------|------|----------|
| [trailofbits/skills](https://github.com/trailofbits/skills) plugins: `audit-context-building` `differential-review` `semgrep-rule-creator` `sharp-edges` `dwarf-expert` `burpsuite-project-parser` | Audit context, differential security review, dangerous APIs, DWARF, and Burp project parsing | Compare with `ida-reverse`, `docs-generator`, and the audit workflow; **do not merge the whole repository** |
| [HexRaysSA/ida-claude-code-plugins](https://github.com/HexRaysSA/ida-claude-code-plugins) | Official IDA Claude plugins, including domain automation marked unsafe | Compare its MCP path with `ida-reverse`; unsafe plugins stay disabled by default |
| [P4nda0s/reverse-skills](https://github.com/P4nda0s/reverse-skills) | IDA-NO-MCP: export decompilation before analysis; rev-frida/dex-dump/u3d | Complements offline export when MCP is unavailable |
| [2389-research/binary-re](https://github.com/2389-research/binary-re) | triage → static (r2/Ghidra) → dynamic (QEMU/GDB/Frida) → synthesis | See `re-agent-workflow.md` for the reverse-engineering phase gates |
| [incogbyte/android-reverse-engineering-claude-skill](https://github.com/incogbyte/android-reverse-engineering-claude-skill) | APK unpacking, endpoint extraction, and adaptive Frida bypass | Compare with `apk-reverse`; dynamic scripts require scope authorization |
| [OwenPawl/cerberus-re-skill](https://github.com/OwenPawl/cerberus-re-skill) | Apple-focused Ghidra + LLDB + Frida three-loop workflow | Reference for macOS/iOS dynamic analysis |
| [ljagiello/ctf-skills](https://github.com/ljagiello/ctf-skills) | CTF reverse engineering/pwn; install tools as needed | Compare with CTF-Sandbox and `pwn-chain` |
| [shuvonsec/claude-bug-bounty](https://github.com/shuvonsec/claude-bug-bounty) | /recon → /hunt → /validate → /report | Compare with `recon-pipeline.md` and the scope gate |
| [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) | Web payloads and a Prompt Injection chapter | Prefer `pentest-tools/payloads`; see `llm-security` for LLM security |
| [HackTricks](https://hacktricks.wiki/) | Penetration methodology and **AI/MCP abuse** | See the MCP section of `skill-supply-chain` |
| [appsecsanta AI pentesting agents 2026](https://appsecsanta.com/research/ai-pentesting-agents-2026) | Classification of 39+ open-source AI penetration-agent architectures | Multiple agents are not inherently required; we use `role-map` |
| Snyk review, “More skills ≠ better” | Skill stacking can reduce audit quality | Supports the “deep skills + routing” strategy |

## 2. Security standards and threats (2025–2026)

| Source | Key points | Placement of this package |
|------|------|----------|
| [OWASP Agentic Skills Top 10](https://owasp.org/www-project-agentic-skills-top-10/) | Malicious skills, supply chain, permission abuse, memory poisoning, etc. | `ops/skill-supply-chain.md` |
| [Anthropic Agent Skills Engineering](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) | Install only trusted sources; review scripts and dependencies | Same as above; bootstrap also forbids guessing paths |
| ClawHavoc and other poisoning incidents documented in AST10 | Mass registration of malicious skills | Forbid one-click installation from unknown registries into this package |

## 3. Existing package coverage vs. broad external coverage

| Domain | reverse-skill | Why we do not vendor broad external libraries |
|------|---------------|--------------------------------|
| APK/JS/IDA/r2/firmware/pwn | **Deep, domain-specific skills** plus scripts | Preserve depth and bind workflows to tool-index |
| Pentesting/attack chains/SRC | pentest-tools + attack-chain + src-hunter | Orizon-style projects can inform methodology |
| LLM/agent security | llm-security | AST10 reinforces the need to secure the skills themselves |
| Evidence/scope/roles | **ops/** (a distinguishing feature) | Most skill packages lack a case-level contract |
| OT/ICS / pure GRC / fraud F3 | No dedicated skill | If routing has no match, propose a new skill or external resource; do not force-fit it |
| 800+ micro-skills | Not copied | Use MASTER routing plus domain skills instead of fragmentation |

## 4. Reference rules (MUST)

```text
1. Do not pull the entire repository of 800+ skills with git submodule as a runtime dependency
2. When borrowing ideas, extract the stages, checklists, and command patterns into this package’s references or an existing skill.
3. Before considering an external script for the bootstrap manifest, inspect its dependencies and network behavior in an isolated environment.
4. For a new scenario, add a skill through CONTRIBUTING and update routing and RULES keywords.
5. Record the source URL and search date using this file’s format.
6. Before installing or merging, follow the checklist in `ops/skill-supply-chain.md`.
7. At runtime, load only the PRIMARY skill from MASTER-ROUTING (plus necessary secondary skills) to avoid overloading context.
```

## 4.1 Reusable takeaways incorporated into this package (not external dependencies)

| Takeaway | Path |
|------|------|
| RE four stages | `reverse-engineering/references/re-agent-workflow.md` |
| authorized reconnaissance | `pentest-tools/references/recon-pipeline.md` |
| Attack-chain lifecycle gate | `attack-chain/references/lifecycle-checklist.md` |
| Skill Supply Chain | `ops/skill-supply-chain.md` |
| domain coverage | `references/domain-coverage-map.md` |

## 5. Recommended priorities for future iterations

| Priority | Action |
|--------|------|
| P0 complete | Ops contract, MASTER routing, and skill supply-chain security documentation |
| P1 | Compare with Orizon/ToB and add pentest phase checklists to attack-chain references |
| P2 | Optionally configure an allowlist of external skills; keep it out of the default path |
