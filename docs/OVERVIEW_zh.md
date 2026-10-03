# Cybersecurity Skills Router Overview

> Security task routing and tool orchestration system for code agents: first determine the task, then select Skill, and finally call the real tool for execution.

If this is your first time seeing this repository, please read this document first. `README_AI.md` is the entry point for AI Agent to execute bootstrap.

## What is this project?

Cybersecurity Skills Router is a **Skill Router + Tool Orchestration** system for Claude Code, Codex CLI, Cursor, Cline, Windsurf and other code agents.

It allows Agent to no longer directly guess commands when dealing with complex tasks such as APK, binary, front-end JS, HTTP packet capture, CTF, firmware, and security testing, but instead:

1. First complete routing based on target type and user intent;
2. Then enter the methodology and workflow of the corresponding Skill;
3. Check the native tools, MCP services and script entries;
4. Call real tools to perform analysis;
5. After the task is completed, a report is generated and the reusable experience is deposited back into the field journal.

Briefly:

> This is not a single-tool installation package, but a workflow operating system that allows AI Agents to stably perform security/reverse tasks.

## Why is it needed?

Common code agents can easily get out of control in security and reverse engineering tasks:

- I don’t know which analysis chain to follow when encountering APK, ELF, JS, PCAP, and CTF;
- Don't know when to use jadx, apktool, Frida, IDA, radare2, BurpSuite;
- Tool paths, MCP services, and script entries are scattered on different machines, making migration difficult;
- Every time similar problems are solved again, the experience cannot be reused;
- Outputs a lot of explanation, but doesn't actually get into tool execution.

The goal of this project is to converge these issues into a clear execution chain:

```text
User tasks
  ↓
RULES.md
  ↓
Skill Router
  ↓
Target Scenario Skill
  ↓
Tools/MCP/Scripts
  ↓
Report + field journal
```

## Core Competencies

| Capabilities | Description |
|---|---|
| Skill Router | Distributes tasks to corresponding Skills based on target type, user intent, and tool chain requirements. |
| Tool Orchestration | Integrate execution surfaces such as jadx, apktool, Frida, radare2, IDA, BurpSuite, and browser tools. |
| MCP Integration | Expose BurpSuite, IDA, browser analysis and other capabilities to Agent through MCP or local bridge. |
| Bootstrap Scripts | Detect the status of native tools and provide automatic installation or manual completion paths if necessary. |
| Field Journal | Precipitate completed tasks, pitfalls, commands and patterns into reusable experience. |
| Report Generation | Generate analysis reports, attack path diagrams, flow charts or CTF writeup after task completion. |

## Platform support

| Platform | Status | Entrance |
|---|---|---|
| Windows | Full mainline | `README.md`, PowerShell script |
| Kali Linux | Special adaptation | `kali/README-kali.md` |
| Ubuntu / Debian Linux | Universal Adaptation | `platforms/linux.md`, `skills/scripts/bootstrap-reverse.sh`, `skills/scripts/refresh-tool-index.sh` |
| macOS | Universal adaptation | `platforms/macos.md`, `skills/scripts/bootstrap-reverse.sh`, `skills/scripts/refresh-tool-index.sh` |

An overview of the platform can be found at [PLATFORMS.md](PLATFORMS.md). Ordinary Linux/macOS users are advised to check the capability list first:

```bash
bash skills/scripts/bootstrap-reverse.sh --list
```

Run only when refreshing tool index:

```bash
bash skills/scripts/refresh-tool-index.sh
```

## Supported Agent clients

- Claude Code
- Codex CLI
- Cursor
- Cline
- Windsurf
- Kiro
- Other code agents that support project rules, system prompts, MCP or external tool calls

This project is not bound to a specific client. Its core assets are `RULES.md`, `skills/SKILL.md`, `skills/routing.md`, tool index, sub-skills and MCP/script entry.

## Support scenarios

| Scene | Main Entrance |
|---|---|
| APK / Android Analysis | `skills/apk-reverse/`, `skills/mobile-reverse/` |
| Binary reverse engineering | `skills/ida-reverse/`, `skills/radare2/`, `skills/reverse-engineering/` |
| JS parameters/front-end signature analysis | `skills/js-reverse/` |
| HTTP packet capture/request replay | BurpSuite MCP, anything-analyzer, browser automation |
| CTF / Security Competition | `CTF-Sandbox-Orchestrator/` |
| Firmware/IoT Analysis | `skills/firmware-pentest/` |
| Patch diff / N-day analysis | `skills/patch-diff-exploit/` |
| Security testing tool chain | `skills/pentest-tools/` |
| LLM/Agent Security | `skills/llm-security/` |
| Reports and Diagrams | `skills/docs-generator/`, `skills/diagram-generator/` |

## Sample workflow

User input:

```text
Help me analyze the signature verification logic of this APK.
```

Expected Agent behavior:

1. Identify task type: APK / Android / signature verification;
2. Route to `apk-reverse`, and if necessary, divert to Frida or native `.so` for analysis;
3. Check whether jadx, apktool, adb, Frida are available;
4. Unpack the APK and extract the manifest, Java layer logic and native library;
5. Determine whether static analysis is sufficient and generate a dynamic hook plan if necessary;
6. Output the signature verification location, key call chain, bypass ideas and verification steps;
7. After the task is completed, a report is generated and the reusable experience is written into the field journal.

## repository structure

```text
.
├── README.md # Main entrance (English)
├── README_zh.md # Main entrance (Chinese)
├── README_AI.md # AI Agent bootstrap entrance (English)
├── RULES.md # Global routing and execution rules
├── docs/OVERVIEW.md # Detailed overview (English)
├── docs/OVERVIEW_zh.md # Detailed overview (Chinese)
├── docs/ARCHITECTURE.md # Architecture description
├── docs/PLATFORMS.md # Platform support overview
├── skills/ # Main Skill directory
│ ├── SKILL.md # Master control entrance
│ ├── routing.md # routing matrix
│ ├── field-journal/ # Experience accumulation
│   ├── apk-reverse/
│   ├── js-reverse/
│   ├── reverse-engineering/
│   ├── ida-reverse/
│   ├── radare2/
│   └── ...
├── CTF-Sandbox-Orchestrator/ # CTF scene sub-skill library
├── burp-mcp-full/ # BurpSuite MCP control module
└── kali/ # Kali environment auxiliary script
```

## Quick start

### Human users

1. Read this document first to understand the project positioning;
2. Read `README.md` again and let the AI ​​Agent perform bootstrap;
3. Configure MCP, Rules or project-level directives according to your client;
4. Use a real task to verify whether the routing is effective.

### AI Agent

If you are an AI agent, don’t stop at the overview. Please enter the execution entrance:

1. Read `README_AI.md`;
2. Enforce Section 0 thereof;
3. Read `RULES.md`;
4. Load `skills/SKILL.md` and `skills/routing.md`;
5. Route first, then execute.

## What is the difference from ordinary Prompt package?

The ordinary Prompt package usually only gives the model a piece of advice. This project places more emphasis on executable structures:

- There are clear entrances: `RULES.md`, `SKILL.md`, `routing.md`;
- There is scene diversion: different targets enter different Skills;
- There are tool execution surfaces: MCP, scripts, local tool chains;
- Write back with experience: experience can be accumulated and reused after the task is completed;
- There is a migration mechanism: after changing the machine, rescan the tool index to restore execution capabilities.

It does not allow the Agent to "know more", but allows the Agent to "guess less, skip fewer steps, and execute on the ground."

## Security and usage boundaries

This project is used for security research, reverse analysis, CTF, teaching experiments, internal security testing and protection verification in an authorized environment. Please make sure you have legal authorization for the target system.

The security-related rules in the main README are used to reduce duplicate confirmations and process idleness in authorized experimental environments, and are not meant to encourage unauthorized access, destructive operations, or real-target attacks.

## Project positioning

If you needed to explain the project to someone, you could summarize it like this:

> Independently designed and open sourced a set of security task Skill Router for code Agents, which splits complex tasks such as reverse engineering, security testing, and CTF into routable, executable, and sedimentable workflows, and linked local tools to the Agent through MCP and scripts.

Keywords: AI Agent, Skill Router, Tool Orchestration, MCP, Workflow Automation, Security Analysis, Field Journal.

## Related documents

- [README.md](../README.md): Main entrance (Chinese)
- [README_AI.md](../README_AI.md): AI bootstrap entrance (English)
- [PLATFORMS.md](PLATFORMS.md): Platform support overview
- [platforms/linux.md](platforms/linux.md): Common Linux adaptation
- [platforms/macos.md](platforms/macos.md): macOS adaptation
- [RULES.md](../RULES.md): global execution rules
- [ARCHITECTURE.md](ARCHITECTURE.md): Architecture description
- [skills/routing.md](../skills/routing.md): routing matrix
- [burp-mcp-full/README.md](../burp-mcp-full/README.md): BurpSuite MCP module

## License

MIT License. See [LICENSE](../LICENSE).

