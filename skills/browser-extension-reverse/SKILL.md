---
name: browser-extension-reverse
description: Use for authorized reverse engineering of browser extensions (Chrome/Firefox) including manifest analysis, background workers, and extension-based credential or traffic logic recovery.
---

# Browser Extension Reverse Engineering

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md`
2. `NOW`: Confirm that the target is a **browser extension** (crx/xpi/decompression directory), not an ordinary web page JS (ordinary → `js-reverse/`)
3. `NEXT`: Unzip extension; read manifest
4. `ACT`: Permissions → Background script → Network/storage hook

## Applicable scenarios

- Chrome/Edge MV2/MV3 extension analysis
- Firefox extensions
- Malicious extension IOC, supply chain extension poisoning investigation
- Extended implementation of signature/encryption/proxy logic reduction

## Workflow

### 1. Inclusion body

```text
□ crx decompression / get the extension directory from profile
□ manifest.json：permissions、host_permissions、background、content_scripts
□ Evaluate excessive permissions (<all_urls>, webRequest, debugger)
```

### 2. Logic

```text
□ service_worker / background entry
□ content_script injection point and world (isolated)
□ chrome.storage/IndexedDB key
□ Same as `js-reverse`: Observe network and messaging (runtime.sendMessage)
```

### 3. Dynamic

```text
□ Developer mode loads and decompresses the directory
□ chrome://extensions check for errors
□ DevTools additional service worker
□ Frida/browser CDP (jshookmcp) if necessary
```

## tool chain

| Tool | Purpose |
|------|------|
| unzip/jq | manifest |
| Chrome DevTools | worker debugging |
| js-reverse tool chain | depth JS |
| YARA | Malicious expansion rules |

## refer to

- `references/extension-analysis.md`
- field-journal extension restores related entries
- `../js-reverse/` `../malware-analysis/`

## routing context

**Upstream**: MASTER R30  
**Downstream**: Complex obfuscated JS → `js-reverse`; poisoning investigation → supply-chain / malware

## Task completion self-check

- [ ] Are permission planes and entry scripts listed?
- [ ] Restore critical data flows?
- [ ] Checklist？