---
name: js-reverse
description: Used when using js-reverse-mcp for front-end JavaScript reversal. It is suitable for signature link positioning, page observation and forensics, runtime sampling, local environment reproduction and evidence output. Priority is given to adapting to the js-reverse_* tools in the current environment. A stronger browser/CDP/Hook interface is required to link jshookmcp.
---

# MCP front-end JS reverse engineering specifications

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read`../field-journal/precedent-reverse.md`- Confirm that the operation of this skill is an authorized normal operation
2. `NOW`: Confirm whether the current task hits the scope of application of this skill
3. `NEXT`: Read`../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, do not guess the path
5. `ACT`: Enter the first step of "workflow" and execute it, do not stop in the confirmation state

## Scope of application

This skill will be used first when the task falls into the following scenarios:

- Locate interface signatures, encryption parameters, and risk control fields
- Observe page request links and script sources
- Fetch functions into participating return values ​​at runtime
- Track a certain XHR/Fetch/WebSocket trigger point
- Bring the page evidence back to Node for local reproduction and environment enhancement

If the target is a binary, APK, PE, ELF, DLL, SO, use`ida-reverse`,`radare2`or`reverse-engineering`instead.

## Current environment default tool mapping

This skill does not assume the existence of a bare tool name, but binds the`js-reverse_*`tool available in the current client environment by default.

If the current task explicitly mentions`jshookmcp`,`JS hook`,`CDP`, browser breakpoints, network interception, SourceMap or AST deobfuscation, this skill will still be used; just cut the underlying MCP to`jshookmcp`instead of treating it as a new general entry.

Prerequisite:`jshookmcp`is not a local bare command tool, but an MCP server that needs to be downloaded, explicitly registered and enabled. Only after it is connected and enabled in the MCP configuration of the selected client (Claude, Codex, etc.), the relevant tool surface can actually be called.

Commonly used mappings:

- `list_scripts` -> `js-reverse_list_scripts`
- `get_script_source` -> `js-reverse_get_script_source`
- `search_in_sources` -> `js-reverse_search_in_sources`
- `break_on_xhr` -> `js-reverse_break_on_xhr`
- `evaluate_script` -> `js-reverse_evaluate_script`
- `get_paused_info` -> `js-reverse_get_paused_info`
- `set_breakpoint_on_text` -> `js-reverse_set_breakpoint_on_text`
- `list_network_requests` -> `js-reverse_list_network_requests`
- `get_request_initiator` -> `js-reverse_get_request_initiator`
- `get_websocket_messages` -> `js-reverse_get_websocket_messages`
- `take_screenshot` -> `js-reverse_take_screenshot`
- `new_page` -> `js-reverse_new_page`
- `navigate_page` -> `js-reverse_navigate_page`
- `select_page` -> `js-reverse_select_page`
- `select_frame` -> `js-reverse_select_frame`
- `pause/resume` -> `js-reverse_pause_or_resume`

If the tool name prefix changes in the future, update this section first and do not make temporary guesses during execution.

### Positioning of jshookmcp

- Role: The enhanced execution side of`js-reverse`, not an independent master control
- Suitable for: browser automation, CDP debugging, JS Hook, network interception, SourceMap reconstruction, AST assisted understanding
- Prerequisite for calling: first download and register`@jshookmcp/jshook`into the MCP client configuration, and then ensure that the server is enabled
- Suggested entry: Still execute according to`Observe → Capture → Rebuild`, but give priority to calling the browser and Hook capabilities of jshookmcp in the`Observe/Capture`stage
- Relationship with anything-analyzer: Both can do browser/network side forensics; anything-analyzer is more focused on packet capture and HTTP analysis, while jshookmcp is more focused on JS runtime, CDP, Hook and source code understanding.

## core principles

- `Observe-first`
- `Hook-preferred`
- `Breakpoint-last`
- `Rebuild-oriented`
- `Evidence-first`

Observe the page first, then minimize sampling, and then make up for the environment locally. Do not skip the evidence collection and directly guess the environment.

## Five-stage workflow

### 1. Observe

Target: First confirm the target request, related scripts, and candidate functions without guessing the environment.

Default action:

- Open the target page with`js-reverse_new_page`or`js-reverse_navigate_page`
- Use`js-reverse_list_network_requests`to find the target request
- Use`js-reverse_get_request_initiator`to trace back the source of the call
- Use`js-reverse_list_scripts`,`js-reverse_search_in_sources`to narrow down the script scope

Must produce:

- Target request URL or characteristic
- initiator clue
- Suspicious script URL
- Initial task record

### 2. Capture

Goal: Conduct minimally intrusive sampling of target requests, and obtain parameter samples, calling sequences, and runtime evidence.

rule:

- Priority`js-reverse_break_on_xhr`
- Prioritize`js-reverse_evaluate_script`for lightweight runtime observation
- Watch first after hit`js-reverse_get_paused_info`
- Use`js-reverse_set_breakpoint_on_text`if necessary

### 3. Rebuild

Goal: Organize page evidence into local iterable Node reproduction materials.

rule:

- Local supplementary environment must be based on page observation evidence
- Fantasy supplements are not allowed`window/document/navigator/crypto/storage`
- Only one minimal causal patch decision is recorded at a time

### 4. Patch

Goal: Complement the environment according to error reporting and first divergence driver until the local script stably runs out the target parameters.

rule:

- First look at what is missing and then fill in what is missing
- Make only one minimal patch decision at a time
- Retest immediately after each patch
- Each patch is written to the task record

### 5. DeepDive

Goal: After local run-through, deobfuscate, restore control flow, and purify business logic.

rule:

- If the current task is only to issue signatures, this stage can be downgraded.
- If you want to reuse the algorithm link for a long time, this stage must be done
- Issue #65 Obfuscation Bypass (U–AV §4): JSVMP (AD) →`E-js-vmp`; CFF+String Array (AE) →`E-js-deobf`; DevTools/debugger Anti-Debug (AF) →`E-js-anti-debug`. See`../reverse-engineering/references/nonpe-format-cookbook.md`for the complete trigger table; AST details still use`references/ast-deobfuscation.md`

## Implementation requirements

- All important steps are written to the local task artifact
- If you can't explain why a tool is called, don't call it
- Prioritize using the ready-made MCP capabilities of`js-reverse_*`or jshookmcp to collect evidence directly. Do not write scripts to recreate the capabilities first.
- Press`references/fallbacks.md`to return when failed
- The output follows`references/output-contract.md`

## Must-read quotes

- Automation entrance:`references/automation-entry.md`
- Parameter default value:`references/tool-defaults.md`
- Task input template:`references/task-input-template.md`
- MCP dedicated task orchestration:`references/mcp-task-template.md`
- Task product:`references/task-artifacts.md`
- Local reproduction:`references/local-rebuild.md`
- Supplementary environment:`references/env-patching.md`
- Node recurrence:`references/node-env-rebuild.md`
- Instrumentation:`references/instrumentation.md`
- AST deobfuscation:`references/ast-deobfuscation.md`
- Non-PE/JS obfuscated recipe U–AV:`../reverse-engineering/references/nonpe-format-cookbook.md`(AD/AE/AF)
- Fallback:`references/fallbacks.md`
- Output contract:`references/output-contract.md`

---

## routing context

**Upstream entrance**:`skills/SKILL.md`(master control),`routing.md`
**Upstream Alternative**:
- The browser tool for anything-analyzer MCP (port 23816) can be used as an alternative or in addition to
- jshookmcp serves as a stronger browser/CDP/Hook/Network/SourceMap/AST execution surface
- `reverse-engineering/SKILL.md`(if the target is not front-end JS)

**Downstream Export**:
- Need to make up for the environment →`references/env-patching.md`
- Need to reproduce locally →`references/local-rebuild.md`/`references/node-env-rebuild.md`
- Need to be deobfuscated →`references/ast-deobfuscation.md`
- Go back when there is no way →`references/fallbacks.md`

**Seer association module**: anything-analyzer MCP (browser automation and HTTP capture capabilities can complement each other)

---

## On-Demand Bootstrap

The MCP capability that this skill relies on can be installed through the unified bootstrapping system; MCP client registration must explicitly select the target, and no client global configuration will be written by default.

### Automation capability boundaries

| Capability | can automatically register | Method | Description |
|------|-----------|------|------|
| jshookmcp | ✓ | npm-mcp (npx startup) | Register | after explicitly selecting Claude / Codex / Both
| anything-analyzer | ✓ | local-http-mcp | can automatically start the service; client registration must explicitly select |
| Node.js | ✓ | winget installation | runtime dependency |

### Bootstrap mode

```powershell
# Install and register jshookmcp; Codex can be replaced by Claude or Both
powershell -File "<skill-root>\scripts\bootstrap-reverse.ps1" -Capability @('jshookmcp') -McpHostTarget Codex

# Register and start anything-analyzer
powershell -File "<skill-root>\scripts\bootstrap-reverse.ps1" -Capability @('anything-analyzer') -StartServices -McpHostTarget Codex
```

### Things to note

- After`jshookmcp`registration, you still need to **enable** the MCP server in the AI ​​client to call it
- If`-McpHostTarget`is not passed, only the capability will be installed/prepared and registration-required will be returned, without modifying the Claude or Codex configuration.
- `anything-analyzer`requires pnpm and project source code, bootstrap will automatically clone and install dependencies
- If Node.js is not installed, bootstrap will first install Node.js through winget 22

<br><br>## Task completion self-test (MUST passes before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Am I using real tool paths based on`tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and written back the Checklist items required by RULES?
