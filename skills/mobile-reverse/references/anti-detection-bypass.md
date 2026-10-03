# Root/Jailbreak/Anti-Debugging/SSL Pinning Bypass

## Detect Hierarchy Model

```
Layer 1: Static detection (at install/launch)
  ├─ Package manager detection（Cydia, apt, Magisk）
  ├─ File detection（su, busybox, frida-server）
  └─ Permission detection（ro.debuggable, ro.secure）

Layer 2: Runtime detection (continuous)
  ├─ Process detection（frida-server, magiskd）
  ├─ Port detection（27042 frida default）
  ├─ Memory detection（/proc/self/maps injection traces）
  └─ Stack detection（Frida call frames）

Layer 3: Environment detection (on demand)
  ├─ ptrace detection（TracerPid）
  ├─ /proc/self/status detection
  ├─ build.prop detection（test-keys）
  └─ direct syscall detection（bypassing libc）
```

## Android Root Detection Bypass

### Common detection libraries and bypasses

| detection library | detection method | bypass method |
|--------|---------|---------|
| RootBeer | 8 detection combinations | Hook Each detection method returns false |
| SafetyNet | Google Play Services Remote Authentication | Using Magisk Hide / Shamiko / Play Integrity Fix |
| Google Play Integrity | Replaces SafetyNet | Trickystore + PIF |
| Custom native detection | syscall Read /proc/self/status | Hook syscall or modify /proc mount |

### Frida comprehensive bypass

```javascript
Java.perform(function() {
    // RootBeer
    var RootBeer = Java.use("com.scottyab.rootbeer.RootBeer");
    var methods = ["isRooted", "isRootedWithBusyBox", "checkSuExists",
        "detectRootManagementApps", "detectPotentiallyDangerousApps",
        "detectTestKeys", "checkForDangerousProps", "checkForRWPaths"];
    methods.forEach(function(m) {
        RootBeer[m].implementation = function() { return false; };
    });

    // Generic Build.TAGS detection
    var Build = Java.use("android.os.Build");
    var original = Build.TAGS.value;
    Build.TAGS.value = "release-keys";

    // PackageManager → Hide package name
    var PackageManager = Java.use("android.content.pm.PackageManager");
    PackageManager.getPackageInfo.overload('java.lang.String', 'int').implementation = function(pkg, flags) {
        if (pkg == "de.robv.android.xposed.installer" || 
            pkg.includes("magisk") || pkg.includes("frida")) {
            throw Java.use("android.content.pm.PackageManager$NameNotFoundException").$new();
        }
        return this.getPackageInfo(pkg, flags);
    };
});
```

## iOS Jailbreak Detection Bypass

### Multilayer Frida Hook

```javascript
// 1. File system detection
var NSFileManager = ObjC.classes.NSFileManager;
var paths = [
    "/Applications/Cydia.app", "/var/lib/apt", "/bin/bash",
    "/usr/sbin/sshd", "/etc/apt", "/Library/MobileSubstrate"
];
// Hook fileExistsAtPath returns NO

// 2. Fork detection (forbidden in sandbox)
var fork_ptr = Module.findExportByName("libSystem.B.dylib", "fork");
Interceptor.replace(fork_ptr, new NativeCallback(function() {
    return -1;
}, 'int', []));

// 3. Scheme detection
// Via MobileSubstrate hook
var LSApplicationWorkspace = ObjC.classes.LSApplicationWorkspace;
// Hook defaultWorkspace → canOpenURL → return NO for cydia://

// 4. Signature detection
var MISValidateSignature = Module.findExportByName(null, "MISValidateSignature");
Interceptor.attach(MISValidateSignature, {
    onLeave: function(retval) { retval.replace(0); }
});
```

## Anti-debugging bypass

### Android

```javascript
// 1. ptrace itself → prevent attachment
// Native: ptrace(PTRACE_TRACEME, 0, NULL, 0)
// Bypass: Hook ptrace → return 0

// 2. TracerPid detection
// /proc/self/status → TracerPid: 0
var fopen = Module.findExportByName(null, "fopen");
Interceptor.attach(fopen, {
    onEnter: function(args) {
        this.path = Memory.readUtf8String(args[0]);
    },
    onLeave: function(retval) {
        if (this.path && this.path.includes("status")) {
            // Modify the returned FILE* and return fake content
        }
    }
});

// 3. isDebuggerConnected (Java)
var Debug = Java.use("android.os.Debug");
Debug.isDebuggerConnected.implementation = function() { return false; };
```

### iOS

```javascript
// 1. PT_DENY_ATTACH
// ptrace(PT_DENY_ATTACH, 0, NULL, 0) → prevent debugger from attaching
var ptrace = Module.findExportByName(null, "ptrace");
Interceptor.replace(ptrace, new NativeCallback(function(request, pid, addr, data) {
    if (request == 31) return 0; // PT_DENY_ATTACH → ignore
    return ptrace(request, pid, addr, data);
}, 'int', ['int', 'int', 'pointer', 'int']));

// 2. sysctl detection
var sysctl = Module.findExportByName(null, "sysctl");
Interceptor.attach(sysctl, {
    onLeave: function(retval) {
        // Modify the p_flag field of kinfo_proc → clear P_TRACED
    }
});

// 3. getppid detection (check whether the parent process is launchd)
// When debugging getppid() != 1
```

## SSL Pinning Bypass

### Android layer five bypass

```text
Layer 1 — TrustManager: Accept all certificates
Layer 2 — OkHttp CertificatePinner: Hook clears pins list
Layer 3 — WebView SSL Error Handler: Ignore certificate errors
Layer 4 — Network Security Config: Modify xml → Trust user certificate
Layer 5 — Native SSL (OpenSSL/BoringSSL): Hook SSL_get_verify_result → X509_V_OK
```

### iOS layer four bypass

```text
Layer 1 — NSURLSession: Hook SecTrustEvaluate → kSecTrustResultProceed
Layer 2 — Alamofire: Hook ServerTrustManager
Layer 3 — AFNetworking: Hook AFSecurityPolicy
Layer 4 - libcurl: LD_PRELOAD replaces SSL verification callback
```

### Common Objection commands

```bash
# Android
objection -g "com.app" explore
android sslpinning disable
# Equivalent to: Automatic Hook above 5 layers

# iOS
objection -g "com.app" explore
ios sslpinning disable
# Equivalent to: Automatic Hook above 4 layers
```

Source: OWASP MSTG, Frida CodeShare, objection wiki
