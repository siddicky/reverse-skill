# Agent Skill Supply Chain Security (Features of this package)

> Comprehensive sources: OWASP Agentic Skills Top 10 (AST10), Anthropic Agent Skills security recommendations, public poisoning incidents (such as ClawHavoc, see AST10 timeline)  
> Search date: 2026-07-17  
> Applicable: When installing/writing/merging **any** skill, MCP, bootstrap scripts

This package's **executable script surface** static audit (backdoor/deletion/pipeline execution): [`docs/PACKAGE-SECURITY-AUDIT.md`](../../docs/PACKAGE-SECURITY-AUDIT.md).

## 1. Why does reverse-skill need to manage this separately?

This package will:

- Guidance AI **Execute commands with bootstrap download**
- Access local and network via MCP  
- Write to field-journal/report  

Malicious skills can lead to: credential theft, persistent prompts, and supply chain backdoors.  
We use **Document Latch + Tool Truth Source** instead of building another skill app store.

## 2. Threat comparison (simplified AST10 idea)

| Risk category | Performance | This package controls |
|--------|------|----------|
| Malicious/poisoning skill | Induces exfil, writes memory/backdoor | Only trusts this repository + external sources authorized by the user in writing; external sources first manually read SKILL.md and scripts |
| Excessive permissions | No difference `curl \| bash`, full disk read | bootstrap only manifest capability; scope `network_profile` |
| relies on poisoning | pip/npm malicious package | gives priority to official release; records the version to tool-index |
| MCP blind trust | Unaudited MCP server | tool-index registration status + port detection; remote MCP | is not trusted by default
| MCP/CLI automatically executes poisoned configuration | Changes to the repository `.env` and `CODEX_HOME`, etc., can cause a malicious MCP to execute at startup (HackTricks/CVE case) | Do not trust the MCP configuration in the repository by default; check the environment and MCP list before starting the Agent |
| Prompt injection into skill | SKILL Text hidden instructions | Review diff; prohibit "execution instructions hidden in HTML comments" without user |
| scope drift | skill induces expanded scanning / "automatic penetration of a domain name" | ops/scope-contract: out_of_scope + auth; prohibiting scanning without in_scope |
| Skill stacking is overloaded | Mounting too many skills at the same time results in missed reports (public evaluation observation) | Only loads PRIMARY + necessary secondary (MASTER-ROUTING) |

## 3. MUST list for installing external skills

```text
□ Source: official org / audited list (such as ToB curated) / user-owned
□ Read all SKILL.md + scripts/* + package dependencies
□ No mysterious external connections, no default steps for reading ~/.ssh/browser library
□ When conflicting with the routing of this package: The MASTER-ROUTING + scope of this package shall prevail.
□ Do not copy into monorepo unless CONTRIBUTING and desensitization are used
□ Update skills/references/community-security-skills.md record source date
```

## 4. Boundary to bootstrap/MCP

| Action | Allow | Disable |
|------|------|------|
| `bootstrap-reverse.ps1 -Capability X` | X ∈ bootstrap-manifest.json | Any new name without changing manifest |
| Register MCP | User confirmation + tool-index Refresh | Silently write global MCP points to unknown URL |
| runs community Python one-click pentest | authorized lab + after reading the source code | direct production target + unknown script |

## 5. Author/contributor of this package

- New skill: CONTRIBUTING + ACTION REQUIRED + Complete self-test  
- To cite community content: mark URL + date (this document / community-security-skills.md)  
- Suspicious behavior is found: stop execution, inform the user, and do not automatically "attempt to bypass"

## 6. Quick self-check (before each merger of external materials)

```powershell
# List script extensions that will be imported
Get-ChildItem -Recurse -Include *.ps1,*.sh,*.py,*.js | Select-Object FullName
# Rough search for dangerous patterns (manual review, not complete)
# Execute in the external directory: Select-String -Pattern 'Invoke-WebRequest|curl .\||wget .\||~/.ssh|exfil'
```

## 7. Relevant

- Identity: `IDENTITY.md`  
- External directory: `../references/community-security-skills.md`  
- Authorization: `scope-contract.md` + `field-journal/precedent-auth.md`  
