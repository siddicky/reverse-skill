# [Seed] iOS Jailbreak Detection Bypass + Packet Capture

## Scene classification
iOS reverse engineering/mobile security testing

## Goal overview
An iOS application crashes or displays an "environmental exception" when launched on a jailbroken device. It needs to bypass jailbreak detection to further analyze its HTTP requests.

## Complete execution link

1. Jailbreak machine preparation (Dopamine / palera1n / unc0ver) → Install frida-server (Cydia source `build.frida.re`)
2. Drag the IPA to the machine and install the signature with AppSync Unified → Start to confirm `frida-ps -U`
3. Start the App → Crash or "Environment Abnormality" pops up
4. Use `frida-trace -U -i 'open' -i 'stat' -i 'access' -i 'fork' com.target.app` to see the detection calls
5. Common hits: Detect `/Applications/Cydia.app`, `/private/var/lib/apt`, `/usr/sbin/sshd`, `fork()` whether successful, `/etc/apt`
6. Use objection to bypass with one click: `objection --gadget com.target.app explore -s "ios jailbreak disable"`
7. After successful startup, use frida hook NSURLSession to capture packets, or configure mitmproxy to install the system certificate.

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| Objection Still crashes after bypassing | App uses SSL Pinning + double jailbreak detection | Enable `ios sslpinning disable` and `ios jailbreak disable` at the same time | 15min |
| App detects before starting, hook is too late | Jailbreak detection is in `+load` or `__attribute__((constructor))` | Use `-f` spawn mode + `frida-trace --aux 'spawn=1'` | 20min |
| App gets stuck after Hook stat | Some system calls after stat is hooked are also affected | Only hook stat triggered by code in the application bundle (filtered by caller) | 30min |
| App can still detect Frida-server after starting | App detects port 27042 and frida string | Use `frida-server` to change the name + change the default port (`-l 0.0.0.0:1234`), the client uses `-H ip:1234` | 25min |
| SSL error still occurs after mitmproxy installs the certificate | The iOS 14+ system certificate needs to be turned on again in "General → About This Mac → Certificate Trust Settings" | After installing the certificate, uncheck the trust settings | 10min |

## Toolchain discovery

- **objection** is the Swiss Army Knife of iOS security testing, with built-in jailbreak / sslpin / clipboard / keychain dump and other modules
- **r2frida** Connect radare2 to frida, which can disassemble + modify registers at runtime, which is much better than pure frida.
- **Hopper / IDA** Decompile iOS binary (either IDA 7+ or Ghidra for iOS Mach-O)
- **dumpdecrypted** is obsolete, now use **frida-ios-dump** to unpack it

## Key code/command

Universal jailbreak detection hook template:

```javascript
// Intercept NSFileManager fileExistsAtPath to detect jailbreak directories
var NSFileManager = ObjC.classes.NSFileManager;
Interceptor.attach(NSFileManager['- fileExistsAtPath:'].implementation, {
    onEnter: function (args) {
        var path = ObjC.Object(args[2]).toString();
        var jbPaths = [
            '/Applications/Cydia.app',
            '/Library/MobileSubstrate/MobileSubstrate.dylib',
            '/bin/bash', '/usr/sbin/sshd',
            '/etc/apt', '/private/var/lib/apt/'
        ];
        if (jbPaths.indexOf(path) !== -1) {
            this.shouldFake = true;
            console.log('[+] Hide JB path: ' + path);
        }
    },
    onLeave: function (retval) {
        if (this.shouldFake) retval.replace(0);
    }
});

// Interception fork() - jailbroken machine fork, non-jailbroken machine returns -1
var fork = Module.findExportByName(null, 'fork');
Interceptor.replace(fork, new NativeCallback(function () {
    return -1;
}, 'int', []));
```

One-click unpacking (for uploading decompilation of jadx, etc.):

```bash
frida-ios-dump -l com.target.app
# Output Payload/TargetApp.app + unpacked Mach-O
```

## Suggestions for improvements to this package

- Added new sub-skill `ios-reverse/` (parallel to `apk-reverse/`), covering: unpacking, jailbreak detection bypass, SSL Pin, Keychain dump, frida-ios-dump, `+load` timing
- Existing `apk-reverse/` should not assume iOS content to avoid confusion

## Reusable patterns/script snippets

**iOS Security Testing Quick Check**:

```text
1. Jailbreak environment preparation (Dopamine 16.x / palera1n old version)
2. frida-ios-dump unpacking
3. otool/class-dump to see the class hierarchy
4. objection from console
5. ios jailbreak disable
6. ios sslpinning disable
7. mitmproxy packet capture (system certificate + trust settings dual-open)
8. After finding the key logic, use IDA / Hopper to dig deeper statically
```

## evolution action
- [ ] **It is recommended to add ios-reverse skill** (the current routing matrix for iOS is reverse-engineering/platforms.md, which is not detailed enough)
- [ ] bootstrap manifest added frida-ios-dump
- [ ] Add "iOS Security Testing Checklist" to references/

## environmental information
- Jailbroken device: iPhone X (iOS 16.5) + Dopamine 1.1.7
- Host: macOS 13+/Kali (mitmproxy + frida-tools)
- frida-server-ios: 16.x

## redaction requirements
This article is seed data, written based on public technical models, and does not involve real goals. Bundle ID `com.target.app` is a placeholder.
