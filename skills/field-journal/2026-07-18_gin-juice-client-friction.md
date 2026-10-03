# Modern Web Range Friction → Skill Reinforcement

> Date: 2026-07-18  
> Scenario: Legal public shooting range (PortSwigger class scanner-eval / OWASP Juice Shop demo)  
> redaction: No real business domain name usage details

## Conclusion (for next time Agent)

**Not penetrated ≠ The package is invalid.** Must deliver: surface map, sink list, latch reason, Evidence(observed|validated).  
Failures should be written into the timeline and fed back into the playbook.

## Step on the trap

| Pit | Phenomenon | Repair/Discipline |
|----|------|-----------|
| case-init authorization is contaminated | `-AuthGranted` status becomes a strange string | only allows pending/granted/denied/unknown; `PSBoundParameters` determines AuthStatus |
| lab_only not ready | network=lab_only ready_for_act false | lab_only + granted + assets → ready |
| Windows curl `[]` | `bad range in position` | **Required** `curl.exe --globoff` |
| append-evidence special characters | RawExcerpt contains quotes/XML error | block indent + remove control characters |
| public network demo 503 | Juice Shop Heroku Hang | Change to local Docker or other legal targets; do not kill |
| DOM XSS false positive | will be reported validated if it has innerHTML sink. | requires 200 non-numeric body to exploit; otherwise observed |
| agent-browser ref expired | click failed | Re-snapshot after page changes |

## Reusable mode

1. Surface → Sink → Chain (see `pentest-tools/references/client-side-lab-playbook.md`)  
2. Inventory class `innerHTML = fetchBody`: first verify the sink, then find 200 non-digits  
3. Static rg sink + agent-browser eval dual certificate  

## tool chain

- case-init / case-guard / append-evidence / smoke  
- agent-browser（CDP）  
- curl --globoff  

## environment

- Windows + PowerShell 5.1  
- Docker Desktop may daemon not ready  
