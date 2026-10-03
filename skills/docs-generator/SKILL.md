---
name: docs-generator
description: |
  Creates task-oriented technical documentation with progressive disclosure. Use when writing READMEs, API docs, architecture docs, or markdown documentation.
  Also use this skill at the END of any completed reverse engineering, penetration testing, CTF, or security analysis task to generate a formal report in the user's project directory.
  Trigger keywords: write report, write document, issue report, writeup, technical document, report, documentation.
---

# Technical Documentation

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Confirm whether the current task hits the applicable scope of this skill
2. `NOW`: Read `../tool-index.md`, verify tool availability and actual path
3. `NEXT`: Call bootstrap when tools are missing, do not guess the path
4. `ACT`: Enter the first step of "workflow" and execute it, do not stop in the confirmation state

For writing style, tone, and voice guidance, use `Skill(ce:writer)` with**The Engineer**persona.

## Security/reverse task document output

After the reverse/penetration/CTF/security analysis tasks are completed, this skill is responsible for generating formal technical documents in the**user project directory**.

### trigger timing

1. The reverse task has been completed, and core conclusions have been produced (algorithm restoration, signature cracking, bypass solutions, etc.)
2. penetration test completed, vulnerability  discovered and verified
3. CTF problem solved, got flag
4. user explicitly requested "write a report/document/writeup"

### template select

| Task type | Using template |
|---------|---------|
| APK/binary/so Reverse | `references/security-report-templates.md` → Reverse Engineering Report |
| Penetration testing/vulnerability mining | `references/security-report-templates.md` → Penetration testing report |
| CTF Problem Solving | `references/security-report-templates.md` → CTF Writeup |
| JS/Web Signature Reverse | `references/security-report-templates.md` → Signature Reverse Report |
| Malware / APT / Virus Analysis Report | `references/security-report-templates.md` +**`references/vendor-report-rules.md`**|
| General technical documentation | `references/templates.md` → README / API documentation |

### Vendor Reporting Structure (Issue #65)

 Security Class Official Report**MUST**Read `references/vendor-report-rules.md` (only get the structure, do not copy the original text of the manufacturer). Select the vendor flavor only if the task evidences it or if the user explicitly requests it; use `flavor = null` for general reverse engineering and other tasks.

| Flavor / Overlay | When to use | Main reference skeleton |
|------------------|--------|------------|
| `malware` | Clear malicious samples, Trojans, Baijiahei, phishing and poisoning | Tinder style: Overview → Process → Sample Analysis → Emergency Response → IOC |
| `apt` | APT/campaign/gang/multi-stage infection chain/industry-targeted | Kaspersky Securelist format: Summary→Infection chain→Investigation narrative→Interesting findings→Technical analysis→Detection mitigation→IOC |
| `flavor = null` | Common APK/ELF/PE/Mach-O reverse engineering, algorithm/firmware analysis, penetration/CTF/JS signature | original task template + Base common elements; does not apply malware/APT exclusive chapter |
| thin `vuln` | Users explicitly request vulnerability/patch/CVE technical analysis | Overview→Impact/Recurrence→Crash and patch analysis→Protection recommendations (overlaid on null, not the 3rd default full-text flavor) |

 principle:**template is more sophisticated than multiple.**- only 2 full-text flavors from manufacturers; `vuln` is only an optional thin overlay and does not create a third set of default full-text templates.
 and §0 Evidence→Finding→Path**take effect simultaneously with**; in case of conflict, the Evidence contract takes precedence.

### output specification

- **output location**: user’s current project directory (not the skill package directory)
- **file name format**: `YYYY-MM-DD_[type]-[target abbreviation]-report.md`
- **If the project has `docs/` directory**: priority is placed under `docs/`
- **encoding**: UTF-8
- **Language**: Follow the user's conversation language (Chinese conversation produces a Chinese report, English conversation produces an English report)

### Quality requirements

- All code blocks must be directly executable or have an explicit context
- does not have placeholder/TODO
- Key findings must be supported by evidence
- The steps to reproduce must allow a third party to independently reproduce
- sensitive information (real token, password, internal URL) replaced with placeholders
- **MUST**contains the Evidence → Finding → Path chain (see `../ops/evidence-finding-path.md` with templates §0)
- **MUST**reads `references/vendor-report-rules.md`: select `malware` / `apt` or `flavor = null` (vulnerability tasks can be superimposed on thin `vuln`); without flavor, only the original task template and applicable Base elements are output, and IOC/ATT&CK is not forced.
- **SHOULD**reference case `scope.md` / `timeline.md` (`../scripts/case-init.ps1`)

### chart integration

When  generates a report, the `diagram-generator` skill should be called at the appropriate location to generate visual charts:

| Report type | Suggested chart | Chart type |
|---------|---------|---------|
| Reverse engineering report | Function call diagram, data flow diagram | Mermaid flowchart / sequenceDiagram |
| Penetration test report | attack path diagram, network topology diagram | Mermaid flowchart / Graphviz |
| CTF Writeup | Problem-solving idea flowchart | Mermaid flowchart |
| JS signature reverse report | Request link sequence diagram, algorithm flow chart | Mermaid sequenceDiagram / flowchart |

 charts are embedded in report markdown in the form of Mermaid code blocks, ensuring that they can be rendered directly in GitHub/GitLab.

---

## Core Principles

### 1. Progressive Disclosure

Reveal information in layers:

| Layer | Content | User Question |
|-------|---------|---------------|
| 1 | One-sentence description | What is it? |
| 2 | Quick start code block | How do I use it? |
| 3 | Full API reference | What are my options? |
| 4 | Architecture deep dive | How does it work? |

**Warnings, breaking changes, and prerequisites go at the TOP.**

### 2. Task-Oriented Writing

```markdown
<!-- Bad: Feature-oriented -->
## AuthService Class
The AuthService class provides authentication methods...

<!-- Good: Task-oriented -->
## Authenticating Users
To authenticate a user, call login() with credentials:
```

### 3. Show, Don't Tell

Every concept needs a concrete example.

## Formatting Standards

- **Sentence case headings**: "Getting started" not "Getting Started"
- **Max 3 heading levels**: Deeper means split the doc
- **Always specify language**in code blocks
- **Relative paths**for internal links
- **Tables**for structured data with 3+ attributes

## Quality Checklist

- [ ] Code examples tested and runnable
- [ ] No placeholder text or TODOs
- [ ] Matches actual code behavior
- [ ] Scannable without reading everything
- [ ] Reader knows what to do next

## Anti-Patterns

| Problem | Fix |
|---------|-----|
| Wall of text | Break up with headings, bullets, code, tables |
| Buried critical info | Warnings/breaking changes at TOP |
| Missing error docs | Always document what can go wrong |

## Templates

For README, API endpoint, and file organization templates, see [references/templates.md](references/templates.md).

## Related Skills

- `Skill(ce:writer)` - Writing style, tone, and voice (load The Engineer persona)
- `Skill(ce:visualizing-with-mermaid)` - Architecture and flow diagrams


---

## On-Demand Bootstrap

This skill does not rely on external tools and generates pure text. No bootstrap required.

 will call the `diagram-generator/` skill if it needs to render a chart embedded report.

---

## routing context

**upstream entrance**: All security/reverse skills automatically call this skill after the task is completed.
**trigger mode**:
- automatically: After the task is completed,  is executed as step 9 of the behavior chain
- Manual: User says "write report", "output document", "writeup"

**Same level association module**:
- `apk-reverse/` — Generate reverse engineering report  after APK reverse engineering is completed
- `ida-reverse/` — generate reverse engineering report  after binary analysis is completed
- `radare2/` — Generate reverse engineering report  after CLI analysis is completed
- `js-reverse/` — Generate signature report  after JS signature reverse engineering is completed
- `reverse-engineering/` — Generate reverse engineering report  after universal reverse engineering is completed
- `field-journal/` — The report content also serves as the data source of the evolution log

**Security Report Template**: `references/security-report-templates.md`
**Vendor reporting rules**: `references/vendor-report-rules.md` (flavor: malware | apt | null; optional overlay: vuln)
**Universal document template**: `references/templates.md`


## task completion self-test (MUST passed before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Am I using real toolpaths based on `tool-index`?
- [ ] Did I produce reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Does the report contain Evidence / Finding / Path (ops contract)?
- [ ] Have you completed and written back the Checklist items required by RULES?
