---
name: thick-client
description: Use for authorized security testing of desktop thick clients including local storage, update channels, IPC, traffic, and client-side trust boundaries.
---

# Thick Client Security Testing

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md`
2. `NOW`: Confirmed that the target is**desktop thick client**(Win/macOS/Linux GUI or service companion), not pure Web
3. `NOW`: case-init; the installation package source and test account are written to scope
4. `NEXT`: Tools (Burp upstream agent, process monitoring, reverse tool)
5. `ACT`: Trust Boundary Map → Local Side → Network Side → Update/Supply Chain

## applicable scenarios

- C/S architecture client, Electron/Qt/.NET WinForms/WPF
- Local configuration/credential storage, IPC, named pipes
- Client Forced Verification Bypass Research (Authorization)
- automatic update channel and code signature verification

## workflow

### 1. Create boundary

```text
□ Process tree, sub-process, driver/service
□ Listening port and outbound domain name
□ Local sensitive paths: %APPDATA%, Keychain, registry
```

### 2. Local attack surface

```text
□ Clear text configuration, hardcoded keys, debugging switches
□ DLL Hijacking/Search Order (Windows)
□ Database file (SQLite) permissions and encryption
□ IPC: Who can connect? Is it authenticated?
```

### 3. Network side

```text
□ System proxy/application custom TLS
□ Certificate pinning → combined mobile/js methodology or Frida
□ API override: hidden management interface on the client side
```

### 4. Reverse verification

```text
□ .NET → dotnet-reverse; native → ida/ghidra; Electron → asar + js-reverse
```

## tool chain

| Tool | Purpose |
|------|------|
| Process Monitor / API Monitor | Behavior |
| Burp / mitmproxy | flow |
| dnSpy / IDA / Ghidra | Reverse |
| Sysinternals | Windows side |
| asar / nexe detection | Electron |

## refers to

- `references/thick-client-checklist.md`
- `../dotnet-reverse/` `../ida-reverse/` `../js-reverse/` `../api-security/`

## routing context

**upstream**: MASTER R32  
**downstream**: pure protocol `protocol-reverse`; supply chain update `supply-chain-security`

## task completed self-test

- [ ] Do you draw trust boundaries?
- [ ] Are both local and network covered?
- [ ] Checklist？