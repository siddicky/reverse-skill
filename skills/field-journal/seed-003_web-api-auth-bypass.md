# [Seed] Web API Unauthorized Access + IDOR

## Scene classification
Penetration testing

## Goal overview
Black-box testing of a web application's REST API revealed unauthorized access and IDOR vulnerabilities.

## Complete execution link

1. Information collection: Nmap scan → Found that port 443 is running Nginx + backend API
2. Directory discovery: FFUF blast → found `/api/v1/` path
3. API enumeration: access `/api/v1/docs` → found Swagger documentation exposed
4. Certification analysis: Register two test accounts A and B
5. Test IDOR: Use the token of account A to access the resources of account B → Success (horizontal override)
6. Test for unauthorized access: remove the Authorization header → some interfaces still return data (unauthorized access)
7. Verification impact: Confirm that any user’s personal information (name, email, mobile phone number) can be read
8. Evidence collection: Save request/response screenshots and compile reports after redaction

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| FFUF is intercepted by WAF | The request frequency is too high and triggers current limiting | Reduce the rate to `-rate 10`, add `-H "User-Agent: Mozilla/5.0..."` | 10min |
| Swagger Documentation 404 | Path is not standard /swagger | Try `/api/v1/docs`, `/api-docs`, `/openapi.json` | 5min |
| The IDOR test is not sure whether it is successful | The returned data does not have obvious user identification | Compare the responses of the two accounts and find the difference in the user_id field | 15min |
| Report rejected by SRC | Only screenshots submitted without complete reproduction steps | Supplementary curl command + complete request/response | 20min |

## Toolchain discovery

- FFUF is faster than Gobuster, but needs to control the rate to avoid being blocked
- Swagger/OpenAPI document exposure is the fastest way to enumerate APIs
- IDOR testing must use two of your own accounts to test each other, and do not touch other people's data.
- SRC reports must have reproducible curl commands, not just screenshots

## Key code/command

```bash
# directory discovery
ffuf -u https://target.example.com/api/v1/FUZZ -w /path/to/SecLists/Discovery/Web-Content/api/api-endpoints.txt -rate 10

# IDOR test
# Use the token of account A to access the resources of account B
curl -H "Authorization: Bearer <token_A>" https://target.example.com/api/v1/users/USER_B_ID

# Unauthorized testing
curl https://target.example.com/api/v1/users/USER_B_ID
# If returns 200 + data → Unauthorized access
```

## Suggestions for improvements to this package

- pentest-tools should add a special checklist for "API penetration testing"
- The IDOR playbook of src-hunter is very useful, but it lacks guidance on "how to determine the scope of IDOR influence"

## Reusable patterns/script snippets

**API unauthorized testing three-step method**:
```text
1. Normal request (with token) → record normal response
2. Remove token → see if data is still returned (unauthorized)
3. Change the token of another user → see if access is available (override of authority)
```

**IDOR Quick Verification**:
```text
1. Register two accounts A and B
2. Get the resource ID of A and the resource ID of B
3. Use A's token to request B's resource ID
4. If the data of B is returned → IDOR confirmation
```

## evolution action
- [ ] No need to update routing matrix
- [ ] No need to update bootstrap-manifest
- [ ] No need to update child skill documents

## environmental information
- OS: Windows (native) → Target Linux server
- Tool version: FFUF 2.x, curl, Burp Suite
- Target platform: Web API (REST, JSON)

## redaction requirements
This article is seed data, written based on public technical models, and does not involve real goals.

---
<!-- [Community Contribution] Seed data, no PR required -->
