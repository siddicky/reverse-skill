---
name: code-audit
description: Use for authorized source-code security review and SAST workflows including Semgrep, CodeQL patterns, dangerous API hunting, and fix verification.
---

# Source Code Security Audit

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read`../field-journal/precedent-pentest.md`or code audit authorization
2. `NOW`: Confirm that there is **source code/repository access** (no source code binary → transfer to RE skill)
3. `NOW`: Clarify the language stack and scope (Directory/Services/PR diff)
4. `NEXT`: tool-index; semgrep, etc.
5. `ACT`: Threat modeling sketch → automatic scanning → manual verification

## Applicable scenarios

- White box audit, PR/differential security review
- Semgrep/CodeQL/Bandit/gosec etc. SAST
- Dangerous APIs, injection points, lack of authentication, misuse of encryption
- Division of labor with`supply-chain-security/`: This skill focuses on its own code logic, and the supply chain relies more on pipelines

## Workflow

### 1. Scope and Threat Model

```text
□ Trust boundaries: user input, files, deserialization, SSRF、and authorization middleware
□ High-value assets: authorization, payments, admin functions, and key handling
```

### 2. Automatic scanning

```bash
semgrep --config auto .
# or project rules package
semgrep --config p/owasp-top-ten .
```

### 3. Manual verification (MUST)

```text
□ Each SAST finding: reachable? exploitable? false positive?
□ Authorization: IDOR/IDOR, missing checks, incorrect tenant isolation
□ Injection: SQL/command/template/LDAP
□ Cryptography: hard-coded keys, ECB、custom crypto
```

### 4. Output

```text
Finding: Location + Data Flow + PoC + Fix Suggestions
Optional ATT&CK / CWE number
```

## tool chain

| Tools | Language/Scenario |
|------|-----------|
| Semgrep | Multilingual Quick Rules |
| CodeQL | Deep Data Streaming (GitHub) |
| Bandit | Python |
| gosec / staticcheck | Go |
| SpotBugs / FindSecBugs | Java |

## refer to

- `references/sast-review-checklist.md`
- `../supply-chain-security/``../api-security/``../llm-security/`(Agent code)

## routing context

**Upstream**: MASTER R26  
**Character**:`ops/role-map.md`cae  
**Downstream**: dependency vulnerability → supply-chain; runtime verification → pentest-tools

## Task completion self-check

- [ ] Is it manually verified instead of just posting the scanner output?
- [ ] Does it contain fix suggestions?
- [ ] Is it limited to authorized repositories?
- [ ] Checklist？