---
name: windows-ad
description: Use for authorized Active Directory and Windows identity attacks including Kerberos, AD CS, BloodHound paths, NTLM relay, and domain privilege escalation research.
---

# Windows / Active Directory Security

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md`
2. `NOW`: **Domain/AD testing must clearly specify the authorization scope** (including DC, whether poisoning/relaying is allowed)
3. `NOW`: case-init; clear network_profile and prohibited actions
4. `NEXT`: tool-index (impacket/certipy/bloodhound, etc. often manually)
5. `ACT`: Start with identity enumeration and BloodHound graph, not destructive exploitation first

## Applicable scenarios

- Domain penetration, Kerberoasting, AS-REP, delegation
- AD CS (ESC1–ESC8, etc.) certificate attack
- BloodHound / SharpHound attack path
- NTLM Relay/Coercer mandatory authentication
- Local privilege escalation to domain path (Potato, etc. as a springboard)

## Relationship with attack-chain

- **Multi-stage from external network to domain control** → PRIMARY can still be `attack-chain/`, this skill is **AD Specialist**
- **Already focused on identity in the domain** → PRIMARY = this skill

## Workflow

### 1. Enumeration

```bash
# Example Impacket / built-in (requires credentials and authorization)
nxc smb <range> -u user -p pass
bloodhound-python -d domain.local -u user -p pass -c All -ns <DC>
```

### 2. Common paths (picture first, then shooting)

```text
□ Kerberoast / AS-REP → Offline cracking
□ ACL abuse (GenericAll/WriteDacl)
□ Delegation (unconstrained/constrained/resource-based)
□ AD CS template error → Certipy
□ Relay: LLMNR/NBT-NS + ntlmrelayx (confirm authorization)
```

### 3. Credentials and Horizontal

```text
□ secretsdump / lsassy / mimikatz (strict authorization and cleaning)
□ PtH / PtT / Golden Ticket is only available to authorized red team
□ Write Evidence for each step; wait for user confirmation of high risk
```

## Toolchain

| Tools | Purpose |
|------|------|
| BloodHound / SharpHound | Path Map |
| Certipy | AD CS |
| Impacket/NetExec | Horizontal vs. Enumeration |
| Rubeus / Mimikatz | Notes and Vouchers (Authorization) |
| Coercer / Responder | Forced authentication / Poisoning |

## refer to

- `references/ad-attack-paths.md`
- `../pentest-tools/references/network-attack-defense.md`
- `../attack-chain/`
- seeds: `field-journal/seed-005_ad-certipy-esc1.md` `seed-007_ntlm-relay-coercer.md` `seed-013_kerberoasting-spn.md`

## Routing context

**Upstream**: MASTER R24  
**Downstream**: reports `docs-generator`; requires EDR research `edr-bypass-re`  
**MUST NOT**: Unlicensed DCSync / Golden Ticket Production

## Task completion self-check

- [ ] Is the graph/enumeration first and then exploited?
- [ ] Whether to record reproducible commands and redact them?
- [ ] Are scope prohibitions respected?
- [ ] Checklist？
