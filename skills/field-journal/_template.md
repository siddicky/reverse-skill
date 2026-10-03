# [date] [project name]

## Scene classification
<!-- APK reverse engineering / JS signature / binary analysis / penetration testing / CTF / packet capture analysis / others -->

## Goal overview
<!-- Explain what you are doing in one sentence -->

## Scope Summary (redaction)
<!-- auth.basis / network_profile.mode / in_scope type (do not write the real domain name/IP) -->
- auth_basis:
- network_profile:
- asset_types: []

## Role
<!-- lead / cie / cpe / cre / … see skills/ops/role-map.md -->
- lead_role: lead
- specialists: []

## Complete execution link
<!-- The complete steps from getting the goal to producing the results, including the detours taken -->

1. ...
2. ...
3. ...

## Evidence chain summary (redaction)
<!-- Up to 3 items: E-id + command mode + conclusion type; complete evidence is in the user project -->
<!-- Field alignment skills/case-review/scripts/review_case.py contract (see description below) -->
| E-id | severity | status | source_type | Reusable command mode | Association Finding |
|------|----------|--------|-------------|----------------|--------------|
| E-001 | info | observed | command | `checksec --file=./pwn1` | F-001 |
| E-002 | high | validated | command | `python3 exploit.py REMOTE` | F-001 |

> **Contract alignment (review_case.py)**: If this case produces an independent evidence directory (`evidence/E-xxx.md`),
> Each piece of evidence must satisfy the field contract of `skills/case-review/scripts/review_case.py`, otherwise the `--strict` verification will FAIL:
>
> - Title: `### E-xxx` (must be consistent with the file name, such as `E-001.md` → `### E-001`)
> - `- severity:` ∈ critical / high / medium / low / info / n/a
> - `- status:` ∈ observed / candidate / validated / false_positive / accepted_risk
> - `- repro_command:` required (for offline scenarios, please indicate offline/offline in notes and can be exempted)
> - `- content_hash:` sha256 or n/a; when filling in sha256, match `- artifact_path:` (relative path within case)
> - `- linked_workitem:` is optional, WI-xxx must really exist
>
> Self-test: `python skills/case-review/scripts/review_case.py <case_root> --verify-hashes --strict`

## Finding/Path Summary
- top_finding:
- path_type: attack | callflow | solve
- path_one_liner:

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| ... | ... | ... | ... |

## Toolchain discovery
<!-- Which tools are used, which ones are easy to use, which ones have pitfalls, and version compatibility issues -->

## Key code/command

```
<!-- Post the actual key commands, hook scripts, and decryption logic -->
```

## Suggestions for improvements to this package
<!-- Is the routing accurate? Is bootstrap missing? Does the documentation need to be supplemented? Do new tools need to be added to the manifest? -->

## Reusable patterns/script snippets
<!-- If you produce reusable hook scripts, decryption logic, and bypass solutions, post them here -->

## evolution action
<!-- What updates were actually performed after this writeback -->
- [ ] Updated routing matrix
- [ ] updated tool-index
- [ ] updated bootstrap-manifest
- [ ] Updated sub-skill documentation
- [ ] Added pitfalls record
- [ ] No update required

## environmental information
<!-- Record the key environment at that time -->
- OS:
- Tool version:
- Target platform/version:

## redaction requirements

> **This file may be synchronized to the remote location with the repository and must be redacted. For the complete specification, see [`anonymization.md`](anonymization.md) (placeholder list + automatic detection script).**

- Target domain name/IP: Replace with `{target_domain}` / `{target_ip}` (see `anonymization.md` for details)
- Real URL path: keep structure, replace domain name
- Token/Cookie/Password/JWT/API key: Use `{token}` / `{password}` / `{api_key}` placeholder
- Username/mobile phone number/email: use `{username}` / `{phone}` / `{user_email}`
- Internal IP/Port: Keep the first two segments of the internal IP segment (`10.0.x.x`)
- Vulnerability payload: The technical content can be retained, but the target characteristic parameters are replaced (such as `?id={user_id}`)

Before submitting, run a regular scan against the **Field-Journal mandatory checklist** at the end of `anonymization.md`.

If it is a private repository and it is confirmed that it will not be made public, the above restrictions can be relaxed, but redaction is still recommended.

## Index synchronization (last step before commit)

After writing this log, `_index.md` must be updated simultaneously:

1. Add a new line (including date, keywords) in the corresponding section of "Classification by Scenario"
2. Add this file name under the corresponding technology of "High Frequency Success Model (by Technology)"
3. Add this file name under the corresponding entity of "Entity inversion (according to target characteristics)"
4. Update "Cumulative Statistics" totals and "Last Updated" date

---
<!-- [Evolution Statistics] The total number of completed projects in this package: N | This new mode: X | This time the tool chain problem is fixed: Y -->
<!-- [Community Contribution] After completion, ask the user whether to PR to the main repository. See CONTRIBUTE-BACK.md for the process -->
