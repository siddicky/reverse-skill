---
name: identity-federation
description: Use for authorized assessment of federated identity systems including SAML, OIDC, OAuth2 flows, SSO misconfiguration, and token confusion issues.
---

# Identity Federation (SAML / OIDC / OAuth)

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read precedent-pentest; SSO test account and IdP/SP scope into scope
2. `NOW`: Disable brute force attempts to lock real user accounts
3. `NEXT`: Packet capture tool and documentation (metadata URL)
4. `ACT`: Protocol Flow Mapping → Common Mismatches → Verification

## Applicable scenarios

- SAML Response signature/assertion tampering surface (classic flaw pattern)
- OIDC implicit/authorization code + PKCE missing
- redirect_uri/state/nonce issue
- IdP and SP metadata, multi-tenant issuer confusion
- Complementary with `api-security` JWT attack (this skill focuses on federation and SSO flow)

## Workflow

```text
□ Clear picture: User → SP → IdP → Token → SP
□ Collection:/.well-known/openid-configuration, SAML metadata
□ Check: redirect_uri exact match, state binding, PKCE
□ Check: SAML signature coverage, algorithm downgrade
□ Session fixation and logout invalidation
```

## tool chain

| Tools | Purpose |
|------|------|
| Burp + SAML Raider and more | Assertion editing (authorization) |
| jwt_tool | JWT segment |
| Browser DevTools | Redirect Chain |
| IdP Management Log | Audit |

## refer to

- `references/sso-flow-checklist.md`
- `../api-security/` `../windows-ad/` (Enterprise IdP)

## routing context

**Upstream**: MASTER R37  
**Downstream**: Pure API JWT → api-security; Cloud IdP → cloud-k8s

## Task completion self-check

- [ ] Map full SSO flow?
- [ ] Does each Finding have recurrence and impact?
- [ ] Checklist？