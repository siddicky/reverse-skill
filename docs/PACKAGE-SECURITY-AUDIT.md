# reverse-skill package security audit (executable side)

> 2026-09-03 Review: Expanded to Git objects, payload identities, symbolic links, binary allowlist, GitHub Action pinning and Gradle Wrapper verification. See [Repository security review — 2026-09-03](SECURITY-REVIEW-2026-09-03.md)for details.

> Date: 2026-08-02
> Scope:`skills/**/scripts`,`skills/scripts`,`kali/scripts`,`burp-mcp-full`executable scripts and bootstrap manifests  
> **Excludes**:`src-hunter`/payloader and other **teaching payload documents** (its DROP/injection samples belong to the methodology and are not automatically executed)

## Conclusion (overall review)

| level | judgment |
|------|------|
| **Backdoor/Active deletion/Format disk** | **Not found** |
| **Pipeline download execution (curl\| sh/IEX DownloadString)** | **Not found** |
| **Hardcoded cloud key/private key** | **Not found** (`sk-`/`BEGIN RSA`in the document are detection examples) |
| **Supply chain residual risk** | **Partially hardened (medium-low → low)**: Crucified`@latest`; GitHub download support **manifest SHA256 + API digest** |

**General comments: No embedded backdoor or "one-click library deletion" logic has been found in the executable skill script interface; dangerous deletions are limited to the tool reinstall temporary directory/case output directory.**

### 2026-07-18 Reinforcement (this submission)

| item | action |
|----|------|
| jshookmcp | `@latest` → `@0.3.4` |
| pentestswarm | `@latest` / docker `:latest` → `@v0.1.0` / `:v0.1.0` |
| jadx | pin `v1.5.6` + `assetSha256` |
| apktool | pin `v3.0.2` + `assetSha256` |
| bootstrap PS/sh | After downloading`Assert-DownloadedFileIntegrity`/`verify_sha256`; give priority to manifest hash, followed by GitHub`digest`; if failed, delete the file and abort |
| release without pinned hash | still installs, but **WARN** and prints the actual sha256 |

### 2026-08-02 Security fixes

| item | repair |
|----|------|
| Kali quick setup | Use`getent`to parse sudo user home, remove`eval`|
| Frida process listing | uses`frida-ps`parameter array, removes inline Python code splicing |
| Burp MCP token | uses restricted temporary file atomic replacement, POSIX file permissions are fixed to`0600`|
| Burp MCP bridge | Parse newline messages according to MCP, and reconnect | as needed after Burp starts
| Anything Analyzer MCP | bootstrap enables bearer auth by default and registers credentials via optional host adapter |
| IDA MCP startup | End old processes one by one to avoid multi-PID parameter expansion errors |

## Scan method

Retrieve executable extensions (`.ps1`/`.sh`/`.py`/`.js`/`.java`):

- `Invoke-Expression` / `IEX` / `FromBase64String` / `DownloadString`
- `curl|bash`/`wget|sh`pipeline execution
- `DROP DATABASE|TABLE`、`rm -rf /`、`Remove-Item ... C:\Windows`
- Rebound shell form (`/dev/tcp`abuse,`TcpClient`backlink)
- Hidden window startup (for review purposes)

Round 2: Manual reading of`bootstrap-reverse.ps1/.sh`download and deletion paths,`mcp-bridge.js`, chart/cryptography Python scripts.

## Discovery details

### 1. Deletion operations (all are expected cleaning, not deletion of the database)

| Location | Behavior | Risk |
|------|------|------|
|`bootstrap-reverse.ps1``Expand-ArchiveIntoDirectory`| Delete the target installation directory and reinstall; delete`%TEMP%\reverse-bootstrap-*`| Only the tool installation path, not the user business library |
|`bootstrap-reverse.ps1`anything-analyzer | on failure`Remove-Item node_modules`after`pnpm install`| toolbox for restricted cloning |
|`apk-reverse/scripts/decode.*`| Clean task output directory jadx/apktool out | Limit task root |
|`case-init.ps1`| Clean up the temporary directory | Temporary |
|`bootstrap-reverse.sh`| Similar temp / installation target cleanup | Same as left |

**Not found**`DROP`/`TRUNCATE`executable logic for`C:\`, system directory, any database connection string.

### 2. Network behavior (tool bootstrapping, not C2)

| Location | Behavior | Description |
|------|------|------|
|`bootstrap-reverse.ps1`|`api.github.com`pull release;`Invoke-WebRequest`download zip/jar | repository name comes from **manifest whitelist** |
|`bootstrap-reverse.sh`|`curl`/`git clone`/`pipx`/`npm`| Same as above |
|`mcp-bridge.js`| Only`127.0.0.1:9876`HTTP → Burp | Local Loopback |
|`ToolDiscovery.ps1`| Detection`http://host:port/mcp`| Health Check |
|`kali/.../tool-discovery.sh`|`(echo >/dev/tcp/$host/$port)`| **Port detection**, non-rebound shell |

### 3. Hide window

| location | purpose |
|------|------|
|`bootstrap-reverse.ps1``Start-Process ... -WindowStyle Hidden`| Background startup`pnpm dev`(anything-analyzer) |
|`ida-reverse/scripts/start.ps1`| Start IDA related processes (need to remain in the background) |

It is a service startup state, and no hidden malicious payloads were found.

### 4. "Danger words" in documents/payload (not automatically executed)

`pentest-tools/src-hunter`,`attack-chain`, etc. **Markdown/JSON teaching materials** including SQL injection,`DROP`examples, log cleaning **Red Team Methodology**.  
These **will not be automatically executed** by bootstrap or master-route; execution relies on AI/human selection under **authorized scope**.

For related constraints, see:`ops/scope-contract.md`,`ops/skill-supply-chain.md`,`field-journal/precedent-*.md`.

### 5. Residual risks in the supply chain (recommend subsequent reinforcement, not confirmed backdoor)

| Items | Risks | Recommendations |
|----|------|------|
|`bootstrap-manifest.json`medium`@jshookmcp/jshook@0.3.4`,`pentestswarm@v0.1.0`| tag drift/supply chain poisoning surface | nailed version number + checksum |
| GitHub release zip **No SHA256 validation** | replacement release may be difficult to detect promptly | manifest add `assetSha256` and verify it during bootstrap validation |
|`npm install -g`/`pip`Default source | Dependence on the inherent risk of the ecology | only has manifest capability; use private source/lock for production environment |

## Executable script inventory (audit baseline)

```
skills/scripts/*.ps1|*.sh + lib/ToolDiscovery.ps1
skills/apk-reverse/scripts/*
skills/radare2/scripts/*
skills/ida-reverse/scripts/*
skills/browser-automation/scripts/*
skills/diagram-generator/scripts/*.py
skills/case-review/scripts/*.py
kali/scripts/*
burp-mcp-full/mcp-bridge.js (+ Java bootstrap)
```

## Recommended ongoing checks

```powershell
# Executable quick physical examination (example)
rg -n "Invoke-Expression|FromBase64String|DownloadString|rm -rf /|DROP DATABASE" skills/scripts skills/*/scripts kali/scripts burp-mcp-full -g "*.ps1" -g "*.sh" -g "*.py" -g "*.js"
```

You should run this list again before merging the **executable script** of the newly added skill; it is not mandatory to change only the Markdown methodology.

## sign

- Audit execution: local static scan of repository + manual review of critical path  
- Result: No backdoor/no automatic deletion; supply chain reinforcement is listed as a follow-up improvement item  
