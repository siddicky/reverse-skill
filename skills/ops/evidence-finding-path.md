# Evidence → Finding → Path evidence chain

> Inspired by Z3r0 Evidence Plane, implemented as **Markdown field contract**.  
> Reverse-skill features: Bind with `docs-generator` report template, `field-journal` redacted writeback, and reproducible commands.

## 1. Evidence (immutable observation)

Each piece of evidence has its own paragraph or table line:

```markdown
### E-{nnn}
- title:
- observed_at:
- source_type: command | screenshot | file | log | memory | network | manual
- source_ref: {path or command id}
- content_hash: {sha256 of artifact if file, else n/a}
- artifact_path: {relative path under case root when content_hash is recorded, else n/a}
- repro_command: |
    {exact command}
- raw_excerpt: |
{Desensitization excerpt}
- linked_workitem: WI-{nnn} | n/a
- supersedes: E-{nnn} | none
```

**MUST**: Finding must reference at least 1 piece of Evidence; `repro_command` can be run by a third party or marked with offline restrictions.

**CLI helper** (write `work/<case>/evidence/E-*.md`):

```powershell
powershell -File skills/scripts/append-evidence.ps1 -CaseRoot work/<case> `
  -Id E-001 -Title "..." -ReproCommand "..." -Severity info -Status observed
```

When the evidence is a case-local file, pass `-ArtifactPath` to record a SHA-256 fixity value and a relative artifact path. Review the complete case graph before handoff:

```bash
python3 skills/case-review/scripts/review_case.py work/<case> --verify-hashes --strict
```

The review is read-only and checks scope fields, Evidence records, work item and timeline references, structured Findings, Paths, and artifact hash matches.

## 2. Finding (safe/converse conclusion)

```markdown
### F-{nnn}
- title:
- severity: critical | high | medium | low | info | n/a_re
- category: vuln | misconfig | design | reverse_algo | bypass | other
- status: candidate | validated | false_positive | accepted_risk
- evidence_ids: [E-001, E-002]
- location: {file:line | addr | url | class.method}
- impact:
- confidence: high | medium | low
- repro_steps:
  1.
  2.
- remediation: {or n/a for pure RE}
- optional_attack: {ATT&CK ID or empty}
```

**MUST**: `evidence_ids` is not empty; when `status=validated`, confidence must not be low (unless residual risk is marked).

## 3. Path (attack path/call path/problem-solving path)

It is uniformly called **Path** and explained by task type:

| Task | Path Meaning |
|------|-----------|
| Penetration / Attack Chain | Attack Path Steps |
| Reverse | Key calls/data flow steps |
| CTF | Problem solving steps |

```markdown
### P-{nnn}
- title:
- path_type: attack | callflow | solve
- start:
- goal:
- steps:
  1. action: — evidence: E-xxx — finding: F-xxx | none
  2. action: — evidence: E-xxx — finding: F-yyy | none
- residual_risks:
```

**MUST**: Each step can be associated with Evidence; if the end of the attack path Finding declares "Permissions/data has been obtained", there must be validated evidence.

## 4. Location in report

The `docs-generator` security report **MUST** contains:

1. Scope summary (linked to case `scope.md`)  
2. Evidence table or chapter  
3. Findings list (including evidence_ids)  
4. At least 1 Path (attack/call/solve)  
5. Timeline summary (optional full text link to `timeline.md`)

See the **Evidence Chain** section in `docs-generator/references/security-report-templates.md` for details.

## 5. field-journal hook

**SHOULD** excerpt when writing back to journal:

- Key Evidence id + command within 3 items  
- 1 core Finding  
- Reusable Path mode in one sentence  

Full sensitive content in user project reports only; journal **MUST** anonymized (`anonymization.md`).

## 6. Differences from Z3r0 (Features)

| Z3r0 | reverse-skill |
|------|----------------|
| PG immutable lines + API | Markdown file + hash field |
| UI review queue | report + next-step menu + journal |
| ATT&CK deep binding | Optional tags, not mandatory UI |


## Validated sufficiency (Issue #77 / R4*)

Global bind rule remains: every Finding references **>=1** Evidence.

Promotion to status=validated is stricter (decision cookbook):

| status | Evidence bar |
|--------|----------------|
| preliminary / candidate | >=1 (unchanged) |
| **validated** | **SHOULD >=2 independent** Evidence (best: 1 static + 1 dynamic). A single Evidence item alone MUST NOT silently promote to validated — keep candidate/preliminary, or record residual_risk + human confirm. |
| blocked promotion | record Evidence E-insufficient-evidence |

Full recipes: [nalysis-decision-framework.md](analysis-decision-framework.md) (R4*, R1, R41, R44).
