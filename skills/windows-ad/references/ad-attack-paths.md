# AD attack path quick check

| Path | Prerequisites | Tool Clues |
|------|------|----------|
| Kerberoast | SPN Account | GetUserSPNs / Rubeus |
| AS-REP Roast | No pre-authentication required | GetNPUsers |
| ESC1 | Registrable Template + Forgeable SAN | Certipy |
| ESC8 | HTTP enrollment + relay | ntlmrelayx |
| ACL → DA | GenericAll on user/group | BloodHound |
| NTLM Relay | Signature not enforced | Responder + relay |

Always: Authorization → Enumeration → Path Scoring → Minimal Validation → Cleanup.
