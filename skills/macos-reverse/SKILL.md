---
name: macos-reverse
description: Use for authorized macOS and Mach-O reverse engineering including codesign, Objective-C/Swift recovery, endpoint security surfaces, and Apple platform malware analysis.
---

# macOS / Mach-O Reverse Engineering

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read`../field-journal/precedent-reverse.md`
2. `NOW`: Confirm that the target is macOS/Mach-O/App bundle (iOS IPA →`mobile-reverse/`)
3. `NEXT`: tool-index; jtool2/lldb, etc.
4. `ACT`: Signature and loading information → static → dynamic (lldb/Frida)

## Applicable scenarios

- Mach-O executable/dylib/framework
- .app bundle、LaunchAgent/Daemon
- Objective-C/Swift symbols and runtime
- Notarization/signature, Hardened Runtime, TCC related behavior analysis
- macOS malware static/dynamic analysis (joint malware-analysis)

## Workflow

### 1. Bundle and signature

```bash
file target
codesign -dv --verbose=4 target
spctl -a -vv target 2>&1
otool -L target
```

### 2. Static analysis

```text
□ class-dump / swift-demangle / Hopper / Ghidra / IDA
□ Strings, XPC service names, and sensitive TCC APIs
□ LC_LOAD_dylib dependencies and rpath
```

### 3. Dynamic analysis

```text
□ lldb / Frida
□ Observe with fs_usage / log stream
□ Networking: combine with protocol-reverse or a proxy
```

## tool chain

| Tool | Purpose |
|------|------|
| otool / nm / codesign | comes with the system |
| Hopper / Ghidra / IDA | Decompile |
| class-dump / dsdump | ObjC |
| Frida / lldb | Dynamic |
| jtool2 | Mach-O |

## refer to

- `references/macho-triage.md`
- `../mobile-reverse/`（iOS） `../ghidra-reverse/` `../malware-analysis/`

## routing context

**Upstream**: MASTER R31  
**Downstream**: iOS → mobile-reverse; universal sample → malware-analysis

## Task completion self-check

- [ ] Do you want to log signature/Hardened Runtime status?
- [ ] Are there any address-level/symbol-level conclusions?
- [ ] Checklist？