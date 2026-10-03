# 2026-07-22 Electron Bytenode Privilege Update Chain Analysis

## Scene classification

Binary analysis / Electron / Bytenode / Update chain security audit

## Goal overview

Completed cross-layer reverse engineering of a Windows x86 Electron desktop application from NSIS installer, ASAR, Bytenode JSC to native game SDK and remote rendering page, confirming permission boundaries, IPC capabilities and update package trust model.

## Complete execution link

1. Perform SHA-256, Authenticode, manifest, section, overlay and mitigation checks on the `{electron_app}` outer PE to confirm the installer type and privilege escalation level.
2. Expand NSIS read-only with 7-Zip, locate the inner archive and rebuild the file manifest; continue extracting the original `app.asar`, preserving logical offsets, sizes and per-file hashes.
3. Identify Electron 22.0.0, Node 16.17.1 and Bytenode 1.5.7 from `package.json`, runtime resources and JSC strings; differentiate between original extracted directory and existing modified directory.
4. Use the `ELECTRON_RUN_AS_NODE=1` mode of Electron that comes with the sample to load `main.jsc` and `preload.jsc` to solve the host Node/V8 ABI incompatibility.
5. Mock Electron, network, file writing, archiving, FFI, subprocess and exit in the probe; log window options, 21 main process IPC handlers, 29 preload bridge members and life cycle callbacks.
6. Freeze the static resource snapshot of `{remote_ui_domain}` and track how the `updateUrl` returned by `https://{update_api_domain}/api/user/v1/check_ver` enters the local `checkUpdates`.
7. Update the handler with the loopback HTTP fixture driver, confirm the URL reception, download, decompression and detached updater startup sequence; record the non-appearance of whitelist, hash, package signature and Authenticode verification as "not observed in the controlled path" respectively.
8. Perform static review of export, import, string, PE protection, signature and key address of `{native_game_sdk}`, distinguish ABI forwarding, callback FIFO, status watchdog and third-party platform installation branches.
9. Use "conditional capabilities" wording for services, drivers, hosts, root certificates, agents, and platform registry operations; capabilities are only described when there is evidence of the call chain, and it is not inferred that this run has been executed.
10. Output a formal report, three data flow diagrams, structured IOC, recurrence command and evidence index, and separate high-confidence static facts, controlled dynamic facts and remote snapshot aging boundaries in the conclusion.

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|---|---|---|---|
| Host Node fails to load JSC directly | Bytenode bytecode binding specific V8/Node ABI | Execute using RunAsNode mode of sample Electron | Medium |
| The timer and exit logic interfere with the results after starting the probe | The main process includes life cycle callbacks, watchdogs and `process.exit` | Add `--run-timeouts`, mock timer, exit and four types of app callbacks | Medium |
| Updating handlers needs to trigger the network, disk writing and sub-process paths at the same time | Simply enumerating handlers can only prove registration, not data flow | Add `--update-url` fixture to record parameters and side effects throughout the chain | Medium |
| There are existing modification products in the analysis directory | The modified ASAR/JSC will contaminate the original conclusion | Only use `{sample_dir}`, `{extracted_original_dir}` as the original evidence source | Low |
| The status of a dual-signed DLL is easily misjudged | The certificate, timestamp and current verification status of each signature may be different | Use `signtool verify /pa /all /v` to check signature by signature | Low |
| Native strings display high-privilege system capabilities | Strings and imports do not mean that the current path has been executed | Combined with xref/call chain, and marked "conditional capabilities" | Medium |
| Remote UI changes continuously | Current chunk and API behavior are not permanent assets | Save dated resource snapshots, hashes, and fetch times | Low |

## Toolchain discovery

- The sample comes with Electron, which is the most stable ABI container for executing Bytenode JSC; `ELECTRON_RUN_AS_NODE=1` can run the probe without starting the business GUI.
- Electron module mock needs to cover `app.whenReady/on/quit`, `BrowserWindow`, `ipcMain.handle/on`, `shell`, `session` and `webContents`, otherwise you will only get an incomplete registration interface.
- Update chain verification should simultaneously record the input URL, request library, target file, decompression directory and final `spawn` parameters to establish a closed loop of evidence from renderer to updater.
- PE signature audit should separately describe "certificate exists", "certificate is within the validity period", "has a trusted timestamp" and "current chain verification is successful".
- For large third-party DLLs, it is recommended to first use import/export and strings for capability partitioning, and then perform address-level reviews on high-risk branches such as services, networks, certificates, and process creation.

## Key code/command

```powershell
$env:ELECTRON_RUN_AS_NODE = '1'
$env:__COMPAT_LAYER = 'RunAsInvoker'

& '{electron_exe}' '{probe_script}' '{main_jsc}' `
  --execute --exercise=all --run-timeouts --quiet `
  --out='{main_probe_json}'

& '{electron_exe}' '{probe_script}' '{main_jsc}' `
  --execute --exercise=all --run-timeouts `
  --update-url='http://127.0.0.1:{port}/update.zip' --quiet `
  --out='{update_probe_json}'

& '{electron_exe}' '{probe_script}' '{preload_jsc}' `
  --execute --exercise=bridge --quiet `
  --out='{preload_probe_json}'

signtool verify /pa /all /v '{native_game_sdk}'
```

## Suggestions for improvements to this package

1. Add the Bytenode ABI decision tree in the Electron/JS reverse route: after the host Node fails, the RunAsNode mode of the target Electron will be used first.
2. Added generic Electron mock coverage matrix and IPC registration/call consistency check script.
3. Fixed checking of URL constraints, transport protocols, manifest signatures, package hashes, signature chains, decompression traversal and final execution parameters in updater audit templates.
4. Report templates add mandatory columns for "conditional capabilities" and "observed behavior" to reduce the risk of over-inference from imports/strings.

## Reusable patterns/script snippets

1. **Three layers of trust boundary**: original installer -> original ASAR/JSC -> remote page snapshot, hashing and timestamps are established separately for each layer.
2. **Separation of registration surface and execution surface**: First enumerate the IPC/preload API, then use mock fixtures to call high-risk handlers and capture side effects.
3. **Update chain quintuple**: `source URL -> downloader -> archive path -> extractor -> executable`, each node saves evidence.
4. **Native capability classification**: Import/string is a clue, xref/call chain is capability evidence, and real dynamic events are regarded as executed facts.
5. **Signature four-state model**: Signature existence, certificate validity period, timestamp, and current trust verification are reported separately.

## evolution action

- [x] Added pitfalls record
- [x] Updated experience index
- [ ] Updated routing matrix
- [ ] updated tool-index
- [ ] updated bootstrap-manifest
- [ ] Updated sub-skill documentation

## environmental information

- OS: Windows 11 x64
- Tool version: Electron 22.0.0, Node 16.17.1, Bytenode 1.5.7, Python 3.12
- Target platform/version: Windows x86 / Electron desktop app

## redaction requirements

This article only retains the general version, API path structure, order of magnitude, and analysis methods. Sample name, publisher, real domain name, case directory, hash, configuration key, token and user ID have been replaced or omitted; no sample files are included.

---
<!-- [Community Contribution] After completion, ask the user whether to PR to the main repository. See CONTRIBUTE-BACK.md for the process -->
