---
name: threat-hunting
description: Use for blue-team threat hunting, detection engineering with Sigma/YARA, SIEM query design, and incident detection validation.
---

# Threat Hunting & Detection Engineering

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Confirm blue team/hunting authorization and data source scope (SIEM, EDR export)
2. `NOW`: Clarify the hypothesis and then check the numbers to avoid mindless alarms.
3. `NEXT`: Tools and data access methods
4. `ACT`: Hypothesis → Query → Verification → Regularization

## Applicable scenarios

- Threat hunting (hypothesis-driven)
- Sigma/YARA testing engineering
- Alarm tuning and false alarm analysis
- With `malware-analysis/`: sample side IOC → this skill landing detection
- with `digital-forensics/`: case artifacts → lateral hunting

## Workflow

### 1. Construct a hypothesis

```text
Example: The attacker uses living-off-the-land to do horizontal
→ Data source: Sysmon 1/3/10, Windows Security 4624/4648
→ Success criteria: Abnormal parent process or rare account log source found
```

### 2. Query and stacking

```text
□ Baseline: normal administrator behavior period and host
□ Exceptions: New Services, Encoded PowerShell, Exceptions Outbound
□ Association: short-term login to multiple hosts with the same account
```

### 3. Regularization

```yaml
# See malware-analysis for the skeleton of Sigma; this skill emphasizes:
# - False positive surface
# - Data source field mapping
# - Respond to playbook links
```

### 4. Verification

```text
□ Atomic testing (Atomic Red Team) only in authorized laboratories
□ Play back historical logs to verify recall
```

## Toolchain

| Tools | Purpose |
|------|------|
| Sigma CLI/sigmac | Rule conversion |
| YARA | File/Memory |
| SIEM (ELK/Splunk, etc.) | Query |
| osquery | endpoint hunting |
| Atomic Red Team | Testing and Validation (Laboratory) |

## refer to

- `references/hunting-loop.md`
- `../malware-analysis/references/yara-sigma-rules.md`
- `../digital-forensics/`

## Routing context

**Upstream**: MASTER R27  
**Downstream**: confirmed intrusion → forensics; malicious samples → malware-analysis  
**MUST NOT**: Run attack simulation in unlicensed production environment

## Task completion self-check

- [ ] Are there clear hypotheses and conclusions?
- [ ] Do the rules indicate false positives and data sources?
- [ ] Checklist？
