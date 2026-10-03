# Penetration/Attack Chain Life Cycle Checklist

> Compare community pentest skill packages (such as Orizon claude-code-pentest six stages) and integrate with this package `attack-chain` + `ops`.  
> Source inspiration: Public Claude pentest lifecycle skills (retrieved in 2026-07); **Commands and authorizations are subject to the scope of this package**.  
> Date: 2026-07-17

## Before use

- [ ] `case-init` completed, `auth.status=granted`
- [ ] `network_profile` ≠ misuse unrestricted for production
- [ ] `lead` has specified specialist_roles (`ops/role-map.md`)

## stage latch

| Stage | Role | This package skill | Completion criteria |
|------|------|------------|----------|
| 0 Scope | lead | ops/scope-contract | ready_for_act |
| 1 Recon | cie | pentest-tools | assets list + timeline |
| 2 Enum/Vuln | cpe | pentest-tools/api-security | candidate F-* draft |
| 3 Validate | cpe | pentest-tools | E-* + validated Finding |
| 4 Post-ex (if authorized) | cpe/lead | attack-chain second half | not beyond out_of_scope |
| 5 RE Auxiliary | cre | ida/apk/js/… | Only if client/binary is required |
| 6 Report | doc | docs-generator | Evidence→Finding→Path |
| 7 Journal | lead | field-journal | redaction |

## Differences (features) from the "automatically penetrate a domain name" type of skill

| Common external automation packages | reverse-skill |
|------------------|---------------|
| Scan domain names by default | Required scope asset list |
| Write a report directly with weak evidence | Mandatory E/F/P chain |
| Single session without role | role-map handover |
| tool-index + bootstrap | tool-index + bootstrap |

## At least one timeline per stage

See `ops/timeline-workitem.md` for the format.
