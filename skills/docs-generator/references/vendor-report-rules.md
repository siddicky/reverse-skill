# Vendor Report Rules (Professional Vendor Reporting Structure Overlay)

> Issue #65 Question 2.  
> **Only the structure and writing rules are extracted. It is prohibited to copy the text, charts, real IOC examples or large paragraphs of any manufacturer report.**  
> This file is an **overlay**: it does not replace the task template of `security-report-templates.md`, nor does it weaken §0 Evidence→Finding→Path.

Structural reference (public example, skeleton only):

| Flavor | Master Reference | Scene |
|--------|--------|------|
| `malware` | Tinder Security Virus/Technical Analysis Report | Clear common Trojans, white plus black, phishing and poisoning, malicious samples |
| `apt` | Kaspersky Securelist / APT campaign reports (e.g. MATA) | APTs, gang campaigns, multi-stage infection chains, industry targeting |

Principle: **Template should be refined, not too many** - only 2 full-text flavors from manufacturers (`malware` / `apt`) + Base common elements + **optional thin overlay** (such as `vuln` vulnerability technical analysis). Normal reverse engineering, penetration, CTF and JS reports maintain task templates and are not disguised as malware reports by default; `vuln` is **not** the 3rd default full-text flavor.

---

## 0. When to enable

**MUST** read this file when `docs-generator` generates **security** reports (reverse / malware / penetration closure / user explicitly requests "professional report" and "vendor style"). Select the vendor flavor only if the task evidence or the user explicitly requires support; otherwise use `flavor = null` to overlay only common professional elements and the original task template.

| Signal | Flavor / Overlay |
|------|------------------|
| APT / gangs / campaigns / multi-stage C2 / industry targeting / ICS / spear-phish campaigns | `apt` |
| Identify malicious samples, Trojans, secret theft, white and black, and counterfeit sites | `malware` |
| User explicitly requests vulnerability/patch/CVE technical analysis, or task evidence is OS/component vulnerability research | `flavor = null` + **thin overlay `vuln`** (see §3b) |
| Ordinary APK/ELF/PE/Mach-O reverse engineering, algorithm analysis, firmware analysis, penetration testing, CTF, JS signature | `flavor = null`; use the original task template and the minimum set of common professional elements |

When the user explicitly specifies "by Kappa/APT", "by Tinder/Virus Report" and "by Vulnerability Technical Analysis", the automatic selection is overridden.  
**Prohibited** Put ordinary malware/APT/ordinary reverse into the `vuln` directory by default.

---

## 1. Common professional elements (Base)

The following Base elements apply by report type. Elements marked **MUST** cannot be omitted; elements related to a specific flavor must not appear in unrelated tasks to fill in the template. When nothing applies, use `n/a` and explain why.

| # | Element | Requirement |
|---|------|------|
| G1 | Executive summary/overview | **MUST**: 3–8 sentences: what was analyzed, most serious conclusion, impact, recommended actions |
| G2 | Scope and Authorization | **MUST**: Link to case `scope.md` (see Template §0.1) |
| G3 | Evidence→Finding→Path | **MUST**: See `security-report-templates.md` §0 and `skills/ops/evidence-finding-path.md` |
| G4 | IOC table | `malware` / `apt` **MUST**; other tasks only appear if relevant indicators exist |
| G5 | Suggestion/Disposal | `malware` / `apt` **MUST**: At least 1 executable suggestion; other tasks follow the original task template |
| G6 | Appendix metadata | **SHOULD**: Tools and versions, sample hashes, complete reproduction commands |
| G7 | ATT&CK mapping | **MUST** (under `apt`; `n/a` + reason when no applicable technology is available); other tasks **SHOULD** |

### 1.1 Minimum column of IOC table

```markdown
| Type | Value | Context | First/Last Found | Source Evidence | Confidence |
|------|----|--------|---------------|----------|--------|
| file_sha256 / file_md5 / domain / ip:port / url / mutex / path / registry | … | where found | YYYY-MM-DD / n/a | E-id | high/med/low |
```

### 1.2 Copyright and security boundaries

- It is not allowed to paste the manufacturer's PDF/webpage text paragraphs or illustrations for your own analysis.
- Use placeholders for real token, intranet URL, and customer ID.
- Unauthorized targets must not output directly exploitable attack step details (follow case scope / RULES).

---

## 2. Flavor: `malware` (tinder style · explicit selection)

**Narrative goal**: Let readers understand within 5 minutes "what it is → how it came about → how the sample was done → how it was disposed of → what IOCs are there".

### 2.1 Recommended chapter order

```markdown
# [Title: Threat in one sentence]

> Analysis date / Analysis method / Sample identification (hash)

## 1. Overview
(G1: Discovery channels, disguise techniques, core technical points, and whether the product side can be checked and killed - if unknown, write n/a)

## 2. Attack/infection process
(Flowchart: Mermaid or step-by-step list; corresponding to Path `path_type=attack`)

## 3. Sample analysis
### 3.1 Sample traceability
### 3.2 Static analysis
(**MUST** Include import table/base identity Evidence: E-imports or equivalent; see radare2/ida/malware hardgate)
### 3.3 Dynamic Analysis/Behavior
(Without dynamic conditions, n/a + reason)
### 3.4 Core discovery (Findings table or number list, linked to evidence_ids)

## 4. Emergency response methods
(Only executed within the scope of authorization: first confirm the scope and preserve evidence such as samples, memory, process trees, network connections and logs, and then isolate the host; after approval by the person in charge, terminate the process, isolate/clear files, check hosts/startup items, perform a full scan and review. Files must not be deleted directly before evidence preservation.)

## 5. Conclusion
(Risk reminder and prevention for ordinary users/operation and maintenance)

## 6. IOC information
(G4 table)

## 7. Evidence chain summary
(§0: E/F/P/Timeline; can be combined with §3.4 but the field is omitted)

## 8. Appendix
(Tool version, reproduction command, script path)
```

### 2.2 Writing style

- Chinese users default to Chinese; conclusions first, details later.
- Static analysis is layered by "component/stage" to avoid unstructured long log pasting.
- Disposal steps must be executed independently, and empty talk about "enhancing safety awareness" is prohibited.

---

## 3. Flavor: `apt` (Kaspersky Securelist style)

**Narrative Objective**: Tell a clear campaign-level story - who hit whom with what chain when, how the investigation progressed, how the components were divided, and what the defender used to inspect.

### 3.1 Recommended chapter order

```markdown
# [Campaign/Cluster Name]: [One Sentence Impact]

> Date / Team / Industry and regional scope (if known)

## 1. Executive summary
(G1: time window, victim portrait, entrance, family/cluster affiliation, duration, and the most important conclusion)

## 2. The infection chain
(Phases: delivery → exploit/loader → main horse → post-infiltration/secret theft; unknown segment clearly “limited visibility”
Corresponding Path; recommended chain diagram)

## 3. Incident investigation
(Investigation narrative: key turning points, intranet proxy/C2 characteristics, how to expand the scope; hanging Timeline)

## 4. Interesting findings
(3-7 non-obvious points, try to put E-id / F-id on each one)

## 5. Technical analysis
### 5.1 Component overview list (loader/trojan/stealer/…)
### 5.2 Sub-component behavior and configuration
### 5.3 Static key points (including import table/packing/persistence Evidence)
### 5.4 Network and C2
(ATT&CK Form G7 can be attached)

## 6. Detection and mitigation
(Detection ideas/hunting clues/mitigation priorities; not empty slogans)

## 7. IOC
(G4; group by type)

## 8. Evidence chain summary
(§0 field)

## 9. Appendix
(Sample list and hash, tool version, reference public number; do not copy the text of the external report)
```

### 3.2 Style of writing

- Timelines and "visibility limits" need to be written honestly.
- Interesting findings ≠ Repeat the summary; write down the really key anomalies in the investigation.
- Component analysis table: Role/Persistence/C2/Dependencies, then expand.

---


## 3b. Thin overlay: `vuln` (vulnerability technical analysis · optional)

> Issue #65 Supplement. The structure refers to the public "Operating System/Component Vulnerability Technical Analysis" report directory. **Only the skeleton of the chapter is extracted**. It is prohibited to copy the PoC message, exploitation details or unauthorized attack steps in the screenshots/text.  
> **Not** The 3rd default vendor full-text flavor; only stacked for vulnerability research tasks or when explicitly requested by the user.

**Narrative Goal**: Readers can quickly see "Who is affected → How to confirm/reproduce (within authorization) → Root cause and patch differences → How to mitigate".

### Suggested chapter order

```markdown
## 1. Vulnerability overview
### 1.1 Scope of impact (version/component/configuration prerequisite)
### 1.2 Vulnerability recurrence (authorized environment; steps can be repeated by third parties; no weaponized tutorial tone)

## 2. Vulnerability analysis
### 2.1 Crash/Exception Analysis (Evidence: Crash Log, Trigger Conditions)
### 2.2 Patch analysis (diff/guard conditions/repair points - hanging E-*)
### 2.3 PoC or trigger analysis (only existing materials within the authorization scope; protocol/input structure level description is enough)

## 3. Protection suggestions
### 3.1 Mitigation measures (configuration/mitigation switches, etc.)
### 3.2 Official patch and verification

## 4. Evidence → Finding → Path (can be merged into each section or independent table)
```

### hard constraints

- **MUST** scope/Authorization: Reproduction and PoC expansion of unauthorized targets are prohibited
- **MUST** E/F/P: Recurrence, crash, and patch conclusion all hang evidence_ids
- **MUST NOT** Treat `vuln` as malware/APT default shell
- **MUST NOT** Transcribe the exploit code or complete attack weaponization steps from external reports/screenshots
- IOC table: only present if a network/file indicator is present; otherwise n/a or omitted

---
## 4. Hookup to existing task templates

| Task template (`security-report-templates.md`) | Overlay method |
|------------------------------------------|----------|
| 1. Reverse engineering report | Default `flavor = null`, retain the original "static/dynamic/recurrence" skeleton and import table and other hard evidence; only use clear malicious samples §2 |
| 2. Penetration test report | `flavor = null`; fill in applicable G1–G3 in Base, attack path aligned to §0 Path, do not force IOC |
| 3. CTF Writeup | `flavor = null`; retain the original question, problem-solving ideas and recurrence structure, and do not force IOC/ATT&CK |
| 4. JS/Web signature reverse engineering | `flavor = null`; use the original overview → positioning → algorithm → reproduce the skeleton without malware |
| Malware/APT specialization | Explicitly select `malware` or `apt` full text skeleton |

**Conflict Resolution**: §0 Evidence chain field and scope access control **Always take priority**; flavor only changes the narrative order and professional shell, and cannot delete E/F/P.

---

## 5. Selection pseudo code

```
if user_requests_kaspersky or apt or threat_campaign:
    flavor = apt
elif user_requests_huorong or vir_report or explicit_malware:
    flavor = malware
else:
    flavor = null  # Original task template + applicable elements in Base
overlay = null
if user_requests_vuln_tech_report or cve_patch_analysis:
    overlay = vuln  # thin only; never a third default full flavor
emit(base_report)
if flavor in (malware, apt):
    emit(report with flavor outline)
elif overlay == vuln:
    emit(report with vuln thin outline)
```

---

## 6. Complete the checklist (self-inspection at the end of writing the report)

- [ ] Selected flavor or explicit "task template + minimum set"
- [ ] G1 overview exists and is not empty talk
- [ ] §0 E/F/P fields are complete
- [ ] `malware` / `apt` reported with IOC table (or n/a+ reason)
- [ ] `malware` / `apt` reports with executable recommendations/dispositions
- [ ] Tasks without flavor are not included in malware/APT exclusive chapters
- [ ] uln Enabled in vulnerability tasks only; includes Overview/Analysis/Protection Skeletons and E/F/P; no unauthorized PoC weaponization
- [ ] No original manufacturer text pasted, no placeholder/TODO
- [ ] Import tables and other mandatory gates Evidence has entered static/technical analysis (if binary analysis has been done in this task)

---

## 7. Source registration

- Kaspersky Securelist, “Updated MATA attacks industrial companies in Eastern Europe”: <https://securelist.com/updated-mata-attacks-industrial-companies-in-eastern-europe/110829> (structure reference; accessed on 2026-08-11)
- Huorong security public technical article entrance: <https://www.huorong.cn/> (site entrance; access date: 2026-08-11. The specific article URL, title and access date should be registered at the time of actual citation)
- The ATT&CK technical number is only used as a standardized mapping and must be supported by this Evidence; the IOC in the external report cannot be automatically brought into the current report.

---

## 8. non-target

- Additional full-text templates such as Mandiant/CrowdStrike/Qi'anxin are not maintained (the structure has been covered by dual flavor + optional thin overlay to cover common needs).
- Do not upgrade `vuln` to the default full-text flavor alongside malware/apt.
- Do not automatically crawl manufacturer sites to fill in reports.
- Does not reduce Evidence contract or authorization scope due to flavor.
