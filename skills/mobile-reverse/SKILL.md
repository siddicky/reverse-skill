---
name: mobile-reverse
description: Use for authorized Android or iOS application reverse engineering and security testing, including APK or IPA analysis, runtime instrumentation, SSL pinning, and platform protection checks.
---
# Mobile Reverse Engineering

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md` — Confirm that the operation of this skill is an authorized normal operation
2. `NOW`: Confirm whether the current task hits the scope of application of this skill
3. `NEXT`: Read `../tool-index.md` to verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, do not guess the path
5. `ACT`: Enter the first step of the "workflow" and execute it, do not stop in the confirmation state

> Android + iOS unified reverse methodology
> Frida / Objection / OWASP MSTG / SSL Pinning Bypass

## Applicable scenarios

- Android APK reverse engineering and security testing
- iOS IPA reverse engineering and security testing
- Dynamic instrumentation during mobile application runtime
- SSL Pinning/Root detection/Jailbreak detection bypass
- Mobile encryption algorithm extraction (AES/RSA/HMAC key)
- Mobile Application Penetration Testing (OWASP MASTG)
- Application testing in non-rooted/jailbroken environment

## Four-stage workflow

### Phase 1: Information Collection

```text
Android：
□ APK acquisition (Google Play / APKMirror / adb pull)
□ Manifest analysis: permissions, exported components, Intent Filter, backup flag
□ androguard: androguard analyze APK → Components/Permissions/Signature
□ APKLeaks: Hardcoded API Key / Token / Secret scan
□ Reinforcement detection: whether to add shell (360/Tencent/Bangbang/Ai Encryption)

iOS：
□ IPA acquisition (App Store / ipatool / Apple Configurator)
□ Decrypt App Store binaries: frida-ios-dump / Clutch
□ Info.plist analysis: ATS configuration, URL Scheme, Queries Schemes
□ class-dump: export ObjC class structure
□ Hardening detection: whether to use Swift/ObjC obfuscation
```

### Phase 2: Static Analysis

```text
Cross-platform:
□ JADX-GUI: APK → Java source code (Android)
□ Ghidra / Hopper: .so / Mach-O decompilation
□ radare2 / Cutter: CLI fast reconnaissance

Android specialization:
□ apktool d app.apk → smali code + resources
□ dex2jar: DEX → JAR → JD-GUI
□ smali/baksmali: Dalvik bytecode modification

iOS Specialty:
□ class-dump: Export ObjC header files
□ Swift symbol recovery: swift-demangle
□ dsymutil: debugging symbol extraction
□ otool -L: View dynamic library dependencies
□ jtool2: Mach-O analysis
```

### Phase 3: Dynamic Analysis

```text
Frida — Universal dynamic instrumentation:
□ frida-ps -U: List device processes
□ frida-trace -U -i "open*" com.app: Trace function calls
□ Custom Hook script: modify parameters/return values, call private methods

Objection — Frida enhancement layer (no scripting required):
□ objection -g "com.app" explore
□ android root disable / ios jailbreak disable
□ android sslpinning disable / ios sslpinning disable
□ android keystore list / ios keychain dump
□ env / ls / sqlite connect

Frida Gadget (no root/jailbreak):
□ Inject frida-gadget.so / FridaGadget.dylib into APK/IPA
□ Re-sign → Install → Hook without device permissions
□ objection patchapk --source app.apk (fully automatic)
```

### Phase 4: Network Analysis

```text
□ Burp Suite: intercept HTTP/HTTPS, modify request/response
□ mitmproxy: Scriptable proxy (Python API)
□ Wireshark: PCAP packet capture analysis
□ Certificate installation: Android user certificate → system certificate (Magisk + MoveCert)
□ SSL Pinning Bypass: Frida/Objection/Xposed/SSL Kill Switch 2
□ WebSocket / gRPC traffic analysis
```

## Common bypass quick checks

### SSL Pinning

```bash
# Objection (simplest)
objection -g "com.app" explore
android sslpinning disable

# Frida universal script
frida -U -l ssl_pinning_bypass.js -f com.app

# Xposed（Android）
TrustMeAlready module → globally disables certificate verification
```

### Root/Jailbreak Detection

```bash
# Objection
android root disable
ios jailbreak disable

# Frida customization (multi-layer detection)
Java.perform(function() {
    var RootBeer = Java.use("com.scottyab.rootbeer.RootBeer");
    RootBeer.isRooted.implementation = function() { return false; };
    // Additional bypasses: Magisk su detection, frida-server detection, /proc/self/maps detection
});
```

### Anti-debugging

```bash
# Android
frida -U -l anti_debug_bypass.js -f com.app
# Bypass: ptrace(TracerPid), /proc/self/status, isDebuggerConnected()

# iOS
# Bypass: PT_DENY_ATTACH, sysctl CTL_KERN/KERN_PROC/KERN_PROC_PID
frida -U -l ios_anti_debug.js -f com.app
```

## Mobile terminal encrypted extraction

```javascript
// Android — Hook Cipher.getInstance to get the key + algorithm
Java.perform(function() {
    var Cipher = Java.use("javax.crypto.Cipher");
    Cipher.getInstance.overload('java.lang.String').implementation = function(algo) {
        console.log("[Cipher] Algorithm: " + algo);
        return this.getInstance(algo);
    };
    Cipher.init.overload('int', 'java.security.Key').implementation = function(mode, key) {
        console.log("[Cipher] Key: " + bytesToHex(key.getEncoded()));
        return this.init(mode, key);
    };
});

// iOS — Hook CCCrypt
Interceptor.attach(Module.findExportByName("libcommonCrypto.dylib", "CCCrypt"), {
    onEnter: function(args) {
        console.log("CCCrypt op: " + args[0] + " alg: " + args[1]);
        console.log("Key: " + hexdump(args[3], { length: args[4].toInt32() }));
    }
});
```

## Toolchain

| Tools | Platform | Purpose |
|------|:--:|------|
| JADX-GUI | A | Java decompilation |
| apktool | A | APK Unpack/Rebuild |
| Ghidra | A+I | Multi-architecture decompilation |
| Hopper | I | iOS-specific disassembly |
| Frida | A+I | Dynamic instrumentation |
| Objection | A+I | Frida REPL Enhancements |
| MobSF | A+I | Automation SAST+DAST |
| class-dump | I | ObjC class export |
| frida-ios-dump | I | IPA decryption |
| jtool2 | I | Mach-O Analysis |
| Burp Suite | A+I | HTTP Interception |
| mitmproxy | A+I | Scriptable proxy |

> A=Android, I=iOS

## refer to

- `references/frida-objection-deep.md` — Frida + Objection deep usage
- `references/ios-reverse-guide.md` — iOS reverse engineering project
- `references/anti-detection-bypass.md` — Root/jailbreak/anti-debugging/SSL Pinning bypass


## Task completion self-test (MUST pass before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Am I using real tool paths based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and written back the Checklist items required by RULES?
