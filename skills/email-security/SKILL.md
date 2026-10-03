---
name: email-security
description: Use for authorized email security review including phishing analysis, header authentication (SPF/DKIM/DMARC), BEC patterns, and mailbox token abuse research.
---

# Email Security & Phishing Analysis

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Confirm authorization (analyze sample emails/tenant configuration review)
2. `NOW`: Do not re-deliver malicious samples to real users
3. `ACT`: Header Authentication → Content/URL → Attachment Sandbox → Tenant Control Plane Recommendations

## Applicable scenarios

- Phishing email disassembly and IOC
- SPF/DKIM/DMARC Configuration Assessment
- BEC Business Email Fraud Pattern
- OAuth app phishing / email token abuse (federated llm/cloud identities)
- Security Awareness Exercise Design (Authorization)

## Workflow

```text
□ Complete original header: Received chain, From/Return-Path consistency
□ SPF/DKIM/DMARC alignment results
□ URL sandbox and attachment static (joint malware-analysis)
□ Differences in counterfeit brands and reply addresses
□ Tenant: Anti-phishing policy, external tagging, MFA, OAuth app consent
```

## tool chain

| Tools | Purpose |
|------|------|
| Email client "View Source" | Header |
| dig/nslookup | SPF/DMARC records |
| urlscan / sandbox | links and attachments |
| Tenant Management Center | Strategy |

## refer to

- `references/email-auth-checklist.md`
- `../malware-analysis/` `../attack-chain/` (phishing stage) `../windows-ad/` (token)

## routing context

**Upstream**: MASTER R36  
**MUST NOT**: Unauthorized mass testing of phishing for third-party domains

## Task completion self-check

- [ ] Is the conclusion of the header certification complete?
- [ ] Is the IOC detectable (in conjunction with threat-hunting)?
- [ ] Checklist？