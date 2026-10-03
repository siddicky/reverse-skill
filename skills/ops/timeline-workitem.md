# Timeline + WorkItem / Coverage

> Replayable combat records (Z3r0 timeline idea) + overlay check (WorkItem idea).  
> All fall into **`work/<case>/`** (repository gitignore) and are not included in the skill package body.

## Directory convention

```text
work/<case>/
  scope.md           # contract (ops/scope-contract.md）
  timeline.md        # append-only; do not edit historical entries
  workitems.md       # work items and coverage
  evidence/          # raw artifacts (screenshots, pcap、logs)
  notes/
  report/            # final report draft or copy
```

initialization:

```powershell
powershell -File skills\scripts\case-init.ps1 -Hint "full pentest" -CaseName "acme-2026"
```

## timeline.md format

**Append only** to each record:

```markdown
## {ISO-8601} | {role} | {phase}
- action:
- command_or_ref:
- result_summary:
- artifacts: []      # relative paths under this case
- evidence_ids: []   # E-xxx when promoted
- decision_delta: [] # only decisions changed since the previous transition
- carry_forward_refs: [scope.md] # unchanged authoritative state is referenced, not re-serialized
- next:
```

**MUST NOT** Delete or overwrite the existing`##`time block (correct with new entry +`corrects: {timestamp}`).

### Decision delta boundary

`scope.md`,`workitems.md`and existing Evidence are the current authoritative state.`timeline.md`records transition and does not copy the complete snapshot.

- Each real stage/turn transition **MUST** writes`decision_delta`; only the decisions that really change from the previous state to the current state and will affect subsequent actions are listed. Write`[]`when there are no changes.
- Unchanged route, auth, scope, network profile, tool capability, existing hypothesis/Evidence **MUST NOT** Expand again for handover; place in`carry_forward_refs`to reference the authoritative file or entry.
- consumer **MUST** parses`carry_forward_refs`first, and then overwrites`decision_delta`into the working context; delta must not be regarded as a complete state.
- Only when there are two or more materially different, evidence-supported branches, and the user's choice will change the next action, is it a genuine decision boundary; a deterministic transition continues directly without restating the context to create a menu.

Representative transition:`Triage -> Static`If auth/scope/route remains unchanged, only`decision_delta: [phase=triage->static]`is recorded, and the remaining states are inherited as`carry_forward_refs: [scope.md, evidence/E-triage.md]`.

## workitems.md template

```markdown
# Work Items

| ID | title | role | targets | surface | status | evidence | notes |
|----|-------|------|---------|---------|--------|----------|-------|
| WI-001 | Port scan edge | cie | {ip} | network | done | E-001 | |
| WI-002 | Auth bypass check | cpe | /api/login | web | blocked | | need creds |

status: pending | in_progress | blocked | done | cancelled

## Coverage
- [ ] Recon complete for in_scope assets
- [ ] Critical/High candidates triaged
- [ ] Validated findings have Evidence
- [ ] Path documented (attack/call/solve)
- [ ] Timeline continuous (no silent gaps >1 major phase)
- [ ] Report exported via docs-generator
- [ ] field-journal written (anonymized)
```

## attack-chain/pentest hook

| Skill | MUST |
|-------|------|
|`attack-chain/`| Multi-stage tasks create case directories; update workitems + timeline at the end of each stage |
|`pentest-tools/`| At least 1 timeline after each tool run batch; found → Evidence draft |
| Other RE skill | Recommended timeline; at least complete the Evidence chain before issuing the report |

## feature

- Agent friendly plain text, diff/review friendly  
- Cross-referenced with tool-index command path  
- Does not rely on WebSocket live broadcast; just paste the timeline into the report when needed  
