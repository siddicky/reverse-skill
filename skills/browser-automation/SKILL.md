---
name: browser-automation
description: |
 unified automation portal. Covers browser automation (Playwright) and Windows desktop application automation (OpenReverse).
 browser scenario: opening web pages, clicking, filling out forms, crawling, screenshots, automated login, penetration page interaction.
 Desktop scenario: operate GUI tools such as IDA/x64dbg, Windows UI Automation, visual-driven interaction, and desktop application network packet capture.
 trigger keywords: browser automation, desktop automation, opening web pages, filling out forms, crawling, screenshots, automated login, Playwright, agent-browser, headless, OpenReverse, UIA, CUA, desktop operations, Windows automation.
---

# Automation (Desktop & Browser Automation)

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Confirm whether the current task hits the applicable scope of this skill
2. `NOW`: Read `../tool-index.md`, verify tool availability and actual path
3. `NEXT`: Call bootstrap when tools are missing, do not guess the path
4. `ACT`: Enter the first step of "workflow" and execute it, do not stop in the confirmation state

## applicable scope

 Use this skill when the task belongs to the following scenarios:

### browser scenario (Playwright/agent-browser)
- Open the web page and operate the page elements (click, fill in the form, submit)
- crawls page content or takes screenshots
- Automated login process
- Interacting with web pages during penetration testing (submitting payload, triggering XSS)
- Automated processing of verification code page
- Batch form submission

### desktop application scenario (OpenReverse)
- operates Windows desktop applications (IDA Pro, x64dbg, Wireshark, etc.)
- requires vision-driven interaction (CUA mode)
- requires structured UI operations (UIA mode)
- Network traffic observation of desktop applications (built-in mitmproxy)
- GUI operation of automated reverse engineering tool
- black box testing desktop software

### Division of labor between and other tools

| Scenario | What to use |
|------|--------|
| Operation web page (in-browser) |**Playwright / agent-browser**|
| Operating desktop application (Windows GUI) |**OpenReverse**|
| packet capture analysis, HTTP request capture | anything-analyzer or OpenReverse network lane |
| JS breakpoint, Hook, CDP debugging | jshookmcp |
| Positioning signature algorithm, supplementary environment reproduction | js-reverse |

 simple judgment:
- targets web page → Playwright
- targets Windows desktop applications → OpenReverse
- requires both → use  in combination

---

## Part 1: Browser Automation (Playwright/agent-browser)

### Core Workflow

```bash
# 1. Open page
agent-browser open <url>

# 2. Get interactive elements (return @e1, @e2... references)
agent-browser snapshot -i

# 3. Use reference to operate element
agent-browser click @e1
agent-browser fill @e2 "text"

# 4. Close  when finished
agent-browser close
```

### command reference

```bash
# Navigation
agent-browser open <url>
agent-browser close

# page snapshot
agent-browser snapshot # Complete accessibility tree
agent-browser snapshot -i # Only interactive elements (recommended)

# interactive operation
agent-browser click @e1
agent-browser fill @e2 "text"
agent-browser type @e2 "text"
agent-browser press Enter
agent-browser scroll down 500

# Get information
agent-browser get text @e1
agent-browser get title
agent-browser get url

# waits for
agent-browser wait @e1
agent-browser wait 2000
agent-browser wait --load networkidle
```

### Notes
- must execute `agent-browser close`, otherwise the process leaks
- Take a snapshot before operating , do not guess the element reference
- After submits the form, use `wait --load networkidle` and other pages to stabilize

---

## Part 2: Desktop Application Automation (OpenReverse)

### Overview

[OpenReverse](https://github.com/zhexulong/openreverse) is a desktop interaction and evidence collection framework for AI Agent, supporting:
- **UIA mode**: Windows UI Automation, structured desktop control operation
- **CUA mode**: Vision-driven interaction (Computer Use Agent), suitable for complex GUI
- **network observation**: built-in mitmproxy agent + local crawling

### interactive mode selection

| mode | suitable for the scene | bottom layer |
|------|---------|------|
| UIA | Target application has standard Windows controls (buttons, text boxes, lists) | Windows UI Automation API |
| CUA | Target application UI complex or non-standard controls (IDA’s disassembly view, custom rendering interface) | Visual recognition + mouse and keyboard |

### Network observation mode

| mode | suitable for scene |
|------|---------|
| Proxy Lane | The target application can configure the proxy (recommended) |
| Local Lane | The target application cannot use the proxy and needs to be crawled locally |

### installation and configuration

```bash
# 1. Clone project
git clone https://github.com/zhexulong/openreverse.git
cd openreverse

# 2. Installation depends on
npm install

# 3. Access Agent host (Claude Code / Codex / Zed)
npm run init:agents -- --target=all /path/to/project

# 4. Install CUA runtime (if visual driver mode is required)
npm run install:cua-runtime
npm run doctor:cua-runtime

# 5. Install network observation dependencies (if packet capture is required)
npm run install:mitmproxy
npm run doctor:network
```

### Common combination

| requires | configuration |
|------|------|
| only operates desktop applications | UIA or CUA, not connected to the network lane |
| Operation desktop application + packet capture | UIA/CUA + proxy lane |
| Operation desktop application + local crawl | UIA/CUA + local lane |

### reverse scenario example

```text
Scenario: Automated operation of IDA Pro for batch analysis

1. Open IDA Pro in OpenReverse CUA mode
2. Automatically load target binary
3. Wait for the analysis to complete
4. Export function list through UI operation
5. Also use network lane to observe IDA’s network behavior (such as Lumina requests)
```

```text
Scenario: Automated x64dbg debugging

1. Start x64dbg in OpenReverse UIA mode
2. Load the target program
3. Set breakpoints
4. Run and observe register/memory changes
5. Take screenshots to save evidence
```

---

## On-Demand Bootstrap

### Automation capability boundary

| Tool | can be installed automatically | Installation method | Description |
|------|-----------|---------|------|
| Playwright | ✓ | npm + npx playwright install | Browser Automation Engine |
| agent-browser CLI | ✓ | npm install -g agent-browser | Browser operation CLI |
| Node.js | ✓ | winget | pre-dependency |
| OpenReverse | ✗ | Manual clone + npm install | Experimental stage, heavy dependence on |
| mitmproxy | ✗ | manual installation | OpenReverse network observation dependency |

### bootstraps trigger

- browser operation missing Playwright → automatic bootstrap
- desktop operation requires OpenReverse → guide users to install manually (given complete steps)

### OpenReverse manual installation guide

 If AI detects a need for desktop application automation but OpenReverse is not installed:

```markdown
⚠️**Requires OpenReverse for desktop application automation**

**Installation steps**:
1. `git clone https://github.com/zhexulong/openreverse.git`
2. `cd openreverse && npm install`
3. `npm run init:agents -- --target=all <your project path>`
4. If you need visual mode: `npm run install:cua-runtime`
5. If you need network observation: `npm run install:mitmproxy`

**Verification**: `npm run doctor:cua-runtime` and `npm run doctor:network`
```

---

## routing context

**upstream entrance**: `skills/SKILL.md` (master control), `routing.md`
**applicable scenarios**: Any task that requires automated operation of browsers or desktop applications
**downstream outlet**:
- The request captured by needs to be analyzed → `anything-analyzer` or `js-reverse`
- requires JS debugging/Hook → `jshookmcp`
- needs to restore the signature algorithm → `js-reverse`
- desktop application is a reverse engineering tool → `ida-reverse/`

**Similar association module**: `js-reverse` (JS may need to be analyzed after browser operation), `ida-reverse` (OpenReverse can automatically operate IDA GUI)


## task completion self-test (MUST passed before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Am I using real toolpaths based on `tool-index`?
- [ ] Did I produce reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and written back the Checklist items required by RULES?
