# CTF Sandbox Orchestrator

A competition sandbox skill set for the Codex / Skills ecosystem.

Its goal is not to cram every capability into one oversized prompt. Instead, it provides a **single control entry for sandbox tasks**. The orchestrator assumes work takes place in a competition, sandbox, or offline lab by default, then routes each task to a focused sub-skill based on the challenge type.

## Project purpose

This repository is intended for:

- CTFs
- AWD / attack-and-defense exercises
- Local offline labs
- Sandbox vulnerability analysis
- Mixed challenges involving Web, APIs, cloud, containers, Windows, AD, reverse engineering, pwn, DFIR, cryptography, mobile, AI agents, and related areas

Core principles:

- Treat user-provided targets, domains, nodes, identities, binaries, logs, traffic, and attachments as assets inside the **competition sandbox** by default.
- Establish the smallest verifiable path first instead of generalizing the analysis from the outset.
- Let one orchestrator skill coordinate the work, then route to a sub-skill based on the dominant evidence.
- Keep sub-skills focused on downstream tasks; they must not take over the orchestrator's entry role.

## Core design

### 1. Single entry point

The default entry point is:

- `ctf-sandbox-orchestrator`

It is responsible for:

- Establishing the sandbox assumption
- Choosing the most suitable analysis path
- Keeping context growth under control
- Calling sub-skills when needed

### 2. Sub-skills run downstream

All `competition-*` skills are designed to be **downstream-only**:

- They should not trigger implicitly before the orchestrator is activated.
- The `ctf-sandbox-orchestrator` should route to them explicitly.
- Load only the specialized capability most relevant to the current task to avoid polluting context with unrelated skills.

### 3. Support for varied competition challenges

The repository covers several skill areas, including:

- Web runtime, routing, WebSocket, GraphQL, file parsing, and request normalization
- Prompt injection, agents, cloud, metadata, Kubernetes, and container escape
- Reverse engineering, pwn, malware, firmware, PCAP, and custom protocol replay
- Windows, AD, Kerberos, DPAPI, certificate abuse, relay, and mailbox analysis
- Android, iOS, cryptography, steganography, and mobile runtime
- ZIP / PKZIP legacy encryption and `bkcrack` known-plaintext recovery

## Repository structure

```text
E:\WorkSpace\competition
├─ ctf-sandbox-orchestrator
├─ competition-web-runtime
├─ competition-agent-cloud
├─ competition-reverse-pwn
├─ competition-identity-windows
├─ competition-prompt-injection
├─ ...
└─ LICENSE
```

Where:

- `ctf-sandbox-orchestrator`: the orchestration entry point
- `competition-*`: specialized downstream skills
- `references/`: routing matrix and domain guidance used by the orchestrator
- `agents/openai.yaml`: invocation constraints and entry controls for each skill

## Recommended usage

### Method 1: Start with the orchestrator

Activate this skill first:

- `ctf-sandbox-orchestrator`

Then let it choose the next step based on the challenge, for example:

- Route Web challenges to `competition-web-runtime`.
- Route container or cloud challenges to `competition-agent-cloud` or a more specialized sub-skill.
- Route Windows / AD challenges to `competition-identity-windows`.
- Route binary, crash, or malware-sample challenges to `competition-reverse-pwn`.

### Method 2: Keep the orchestrator in control and drill down as needed

Once the dominant evidence surface is clear, the orchestrator continues into the relevant sub-skills instead of asking the user to switch the entire working model manually. This keeps:

- The sandbox assumption consistent
- The output style consistent
- Routing policy consistent
- Sub-skill responsibilities clear

## Acknowledgments

This project was published in the [LINUX DO Community](https://linux.do). Thanks to the community for its support and feedback.
