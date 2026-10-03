# Security/Reverse/Penetration Technology Document Template

This document provides document templates for reverse engineering, penetration testing, vulnerability analysis and other security projects. After the task is completed, AI should create a new document in the user project directory and output it according to the corresponding template.

---

## 0. Evidence Chain (all security reports MUST include)

> Full text of contract: `skills/ops/evidence-finding-path.md`  
> Case Catalog: `work/<case>/` (`case-init.ps1`)

The  report text**MUST**contains the following chapters (can be incorporated into "core findings" but fields must not be omitted):

### 0.1 Scope Summary
- links to `scope.md`: `auth` / `in_scope` / `network_profile`
- has no scope → Do not claim task completion

### 0.2 Evidence
 at least 1, fields: `E-id` / `source_ref` / `repro_command` / `content_hash|n/a`

### 0.3 Findings
 each: `F-id` / `severity|n/a_re` / `evidence_ids` / `confidence` / `location` / `status`

### 0.4 Path
 at least 1 `P-id`: `path_type=attack|callflow|solve`, the step can be linked E/F

### 0.5 Timeline Summary
 linked to `timeline.md` or embedded key 3–10 additional records

---

---

## 0.6 Vendor structure overlay (professional vendor reporting structure)

> full text rules: `references/vendor-report-rules.md` (Issue #65)  
> **MUST**is read and selected when generating a formal security report;**only extracts the structure and is prohibited from copying the manufacturer's original text/IOC instance**.

| Flavor / Overlay | Scene | Skeleton sentence |
|------------------|------|------------|
| `malware` | Clear malicious sample/common Trojan/white plus black | Tinder style: Overview → Process → Sample Analysis → Emergency Response → IOC |
| `apt` | APT/campaign/multi-stage chain | Kaspersky style: Summary → infection chain → investigation → interesting findings → technical analysis → detection and mitigation → IOC |
| `flavor = null` | Common reverse/penetration/CTF/JS signature | Task template for this section + applicable Base common elements |
| thin `vuln` | Vulnerability/Patch/CVE Technical Analysis (Explicit) | Overview→Impact/Recurrence→Crash and Patch Analysis→Protection Suggestions |

**Common Elements (G1–G7) Summary**: G1 Executive Summary MUST · G2 Scope MUST · G3 E/F/P MUST · G4 IOC Only `malware`/`apt` MUST · G5 Recommended in `malware`/`apt`/`vuln` MUST · G6 APPENDIX SHOULD · G7 ATT&CK IN `apt` MUST

 selection and chapter order shall be based on `vendor-report-rules.md`; when conflicting with §0.1–0.5,**Evidence contract takes precedence over**.

## 1. Reverse engineering report template

```markdown
# [target name] reverse analysis report

> Analysis date: YYYY-MM-DD
> Analyst: [AI/Human]
> Toolchain: [jadx/IDA/radare2/Frida/…]

## 1. Goal Overview

| Properties | Values ​​|
|------|---|
| file name | |
| File Types | APK/ELF/PE/Mach-O/… |
| Size | |
| MD5 | |
| SHA256 | |
| Package name/entry | |

## 2. Analysis target

<!-- The core question to be answered in this reverse engineering -->

## 3. Static analysis

### 3.1 Basic information
<!-- Architecture, compiler, protection mechanism, string characteristics -->

### 3.1.1 import table/dependency (binary MUST)
<!-- Write E-imports / E-triage-imports summary; if failed, Evidence will be recorded and skipping is prohibited -->

### 3.2 key function/class
<!-- List the key logic located, with code snippets -->

### 3.3 encryption/signature algorithm
<!-- If encryption is involved, describe the algorithm, key source, and parameter construction -->

## 4. Dynamic analysis

### 4.1 Hook records
<!-- Frida / xposed / other hook targets and results -->

### 4.2 Runtime behavior
<!-- Network requests, file operations, process behavior -->

## 5. Core discovery

<!-- List key conclusions with numbers -->

1. ...
2. ...
3. ...

## 6. Reproduction steps

<!-- Allow others to reproduce your analysis results -->

```bash
# Key command
```

## 7. Legacy issues

<!-- Points that are not completely resolved -->

## 8. Attachment

<!-- hook script, decryption code, screenshots, etc. -->
```

---

---

## 1b. Malware/APT Report (vendor flavor)

 When the task is malware analysis, virus reporting, APT/campaign analysis,**instead of**only use the above "reverse engineering" skeleton; for ordinary reverse tasks, keep the original template and do not automatically select vendor flavor:

1. reads `vendor-report-rules.md` and selects `malware` or `apt`
2. outputs  in the order of corresponding chapters
3. still contains**MUST**with §0 Evidence chain; `malware` / `apt` flavor another**MUST**with IOC table
4. Static analysis of binary sample**MUST**with import table Evidence (consistent with radare2/ida/malware hard door)

## 1c. Vulnerability technical analysis report (thin `vuln` overlay)

 When the task is**OS/component vulnerability, patch comparison, CVE technical analysis**, or the user explicitly requests a "vulnerability technical analysis report":

1. reads `vendor-report-rules.md` §3b, using thin `vuln` chapter order (**is not**malware/apt full text flavor)
2. **MUST**includes: scope of impact, recurrence or clarification within authorization n/a, crash/root cause or patch difference Evidence, protection/patch suggestions
3. **MUST**with §0 Evidence→Finding→Path
4. **MUST NOT**Extend PoC on unauthorized targets, or transcribe external exploit weaponization details

## 2. Penetration test report template

```markdown
# [Target] Penetration Test Report

> Test date: YYYY-MM-DD
> Test scope: [URL/IP/Application Name]
> Authorization status: [Authorized / CTF / Learning Environment]

## 1. Executive Summary

<!-- A paragraph summary: what was tested, what was found, risk level -->

## 2. Test range

| Project | Details |
|------|------|
| Target | |
| Test Type | Black Box / Gray Box / White Box |
| Test time | |
| Tools | |

## 3. Discovery summary

| # | Vulnerability name | Risk level | Status |
|---|---------|---------|------|
| 1 | | High/Medium/Low/Information | Verified/To be confirmed |

## 4. Vulnerability details

### 4.1 [Vulnerability name]

**Risk Level**: High / Medium / Low

**describe**:

**Influence**:

**Steps to reproduce**:

1. ...
2. ...
3. ...

**evidence**:

```
<!-- request/response/screenshot/payload -->
```

**Fix suggestions**:

## 5. Attack path

<!-- If there is a complete attack chain, draw the path -->

```
 entrance → information collection → vulnerability exploitation → privilege escalation → goal achieved
```

## 6. Tools and Environment

| Tools | Version | Purpose |
|------|------|------|
| | | |

## 7. Summary of repair suggestions

| Priority | Suggestions |
|--------|------|
| P0 | |
| P1 | |
| P2 | |

## 8. Appendix

<!-- Complete payload, scripts, configuration files, etc. -->
```

---

## 3. CTF Writeup template

```markdown
# [Competition Name] - [Question Name] Writeup

> Category: Web / Reverse / Pwn / Crypto / Misc / Forensics
> Difficulty: Easy / Medium / Hard
> Score: N pts
> Solving time:

## Title Description

<!--Original title description -->

## Problem-solving ideas

### The first step: information collection
<!-- What was observed -->

### Step 2: Vulnerabilities/Breakthroughs
<!-- What key points were found -->

### Step 3: Use
<!-- How to use it -->

## key code/Payload

```python
# exploit code
```

## Flag

```
flag{...}
```

## pit record

<!-- Detours taken -->

## Knowledge points

<!-- The knowledge points involved in this question are convenient for subsequent review -->
```

---

## 4. JS/Web signature reverse report template

```markdown
# [Site/Application] Signature parameter reverse report

> Analysis date: YYYY-MM-DD
> Target interface: [URL]
> Signature field: [field name]

## 1. Target request

```http
POST /api/xxx HTTP/1.1
Host: example.com

param1=xxx&sign=<target field>
```

## 2. Positioning process

### 2.1 Breakpoint/Hook method
<!-- How to find the signature generation location -->

### 2.2 call stack
<!-- Key call chain -->

## 3. Algorithm restore

### 3.1 algorithm type
<!-- HMAC-SHA256 / AES / Custom / ... -->

### 3.2 parameter construction
<!-- Which fields participate in signature, sorting rules, and delimiters -->

### 3.3 Key source
<!-- Hard coding / interface return / timestamp derivation / ... -->

## 4. Local replication code

```javascript
// Node.js reproduces
```

## 5. Verification result

<!-- Comparison of the signature generated with the replica code and the actual request -->

## 6. Anti-climbing/risk control precautions

<!-- Frequency limits, device fingerprints, environment detection, etc. -->
```

---

## 5. Document output specification

### output position

- documents are output to the**user's current project directory**(not the skill package directory)  by default
- file name format: `YYYY-MM-DD_[type]-[target abbreviation]-report.md`
- If the user project has the `docs/` directory, it is first placed under `docs/`

### output timing

AI automatically calls this skill to generate documents at the following times:

1. reverse task completed, core conclusion  has been produced
2. penetration test completed, vulnerability  discovered and verified
3. CTF problem solved, got flag
4. user explicitly requested "Write a report/document"

### Quality requirements

- All code blocks must be directly executable or have an explicit context
- Do not have placeholder/TODO (if a certain part is indeed unfinished, mark "to be added" and explain the reason)
- Key findings must be supported by evidence (command output, screenshot description, code snippets)
- The steps to reproduce must allow a third party to independently reproduce
