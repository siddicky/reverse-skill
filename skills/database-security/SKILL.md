---
name: database-security
description: Use for authorized database security assessment covering PostgreSQL/MySQL/MSSQL/Mongo/Redis exposure, authz, UDF/command paths, and misconfiguration review.
---

# Database Security Assessment

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: read precedent-pentest;**production library prohibits destructive statements**unless explicitly allowed
2. `NOW`: scope Write down the instance, account permissions, and whether writing/deleting  is allowed
3. `NEXT`: Client tool path
4. `ACT`: Exposure → Authentication → Authorization → Configuration → Utilization chain verification (security)

## applicable scenarios

- database is not authorized/weak password/wrong binding 0.0.0.0
- Excessive permissions, dangerous functions (xp_cmdshell, COPY PROGRAM, UDF)
- horizontal: from application account to DBA
- NoSQL injection and Redis writing files, etc. (authorization environment)

## workflow

```text
□ Network exposure and TLS
□ Account role and grantee
□ Sensitive table access control
□ Dangerous configurations: file_priv, xp_cmdshell, load_file
□ Is the audit log enabled?
□ Backup and snapshot permissions
```

## tool chain

| Tool | Purpose |
|------|------|
| Official CLI | Connection and Enumeration |
| sqlmap | injection verification (authorization) |
| nuclei | Known exposure template |
| Cloud RDS Console Audit | Configuration |

## refers to

- `references/db-misconfig-checklist.md`
- `../pentest-tools/` `../cloud-k8s/`

## routing context

**upstream**: MASTER R35  
**downstream**: obtain OS command → attack-chain; cloud hosting → cloud-k8s

## task completed self-test

- [ ] Does it prevent unauthorized writing and deletion?
- [ ] Does it differentiate between configuration issues and exploitable chains?
- [ ] Checklist？