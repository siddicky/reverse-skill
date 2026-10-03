---
name: apk-reverse
description: Used when doing Android APK reverse engineering in CLI environment. Suitable for APK unpacking, Java decompilation, smali modification, repackaging, Frida dynamic Hook, and switching to so/native analysis on demand. Priority is given to using jadx, apktool, frida, adb, ida-reverse, and radare2 that have been installed on the machine.
---

## ACTION REQUIRED (execute immediately after reading)

> Endpoint extraction/Frida adaptive and other community comparison: ../references/community-security-skills.md; dynamic analysis requires scope authorized devices.

1. `NOW`: Read `../field-journal/precedent-reverse.md` - Confirm that the operation of this skill is an authorized normal operation
2. `NOW`: Confirm whether the current task hits the scope of application of this skill
3. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, do not guess the path
5. `ACT`: Enter the first step of "workflow" and execute it, do not stop in the confirmation state

# APK reverse engineering CLI operation specification

## Scope of application

This skill will be used first when the task falls into the following scenarios:

- Analyze the Java business logic of the APK
- Positioning login, signature, risk control, certificate verification, root detection
- View and modify `AndroidManifest.xml`
- View and modify smali
- Repackage APK
- Use Frida to create Java/native dynamic Hooks
- Switch to native analysis when APK contains `.so`

## The current machine has verified available CLI tools

- `jadx` `1.5.5`
- `apktool` `3.0.2`
- `frida-ps` `17.9.6`
- `adb`
- `java`

## Scenarios where scripts are preferred

The following processes are high-frequency and parameters are prone to errors. It is preferable to use the skill's own scripts:

- Complete `jadx + apktool` at one time and output summary: `scripts/decode.ps1`
- Frida device check, process enumeration, spawn/attach injection: `scripts/frida-run.ps1`
- Rebuild, align, sign, install APK: `scripts/rebuild-sign-install.ps1`
- Quickly extract manifest key components and permissions: `scripts/manifest-summary.ps1`

The following line of commands remains directly called and is not packaged separately:

- `adb devices`
- `adb logcat`
- `frida-ps -U`
- `jadx --version`
- `apktool --version`

## Comes with script

### `scripts/decode.ps1`

use:

- Unified run `jadx` and `apktool`
- By default, the task output directory is created in the same directory as the original APK.
- Output `package`, `java_files`, `smali_dirs`, `so_files` and other abstracts
- Compatible with `jadx` Some decompilation errors occur but there are still usable products

Example:

```powershell
pwsh -File "<skill-root>\apk-reverse\scripts\decode.ps1" -ApkPath "D:\DOWNLOAD\app.apk" -Clean
pwsh -File "<skill-root>\apk-reverse\scripts\decode.ps1" -ApkPath "D:\DOWNLOAD\app.apk" -Name demo -SkipJadx
```

### `scripts/frida-run.ps1`

use:

- Unify Frida's device, process, spawn/attach entries
- Avoid confusion when handwriting parameters `-f`, `-n`, `-U`

Example:

```powershell
pwsh -File "<skill-root>\apk-reverse\scripts\frida-run.ps1" -ListDevices
pwsh -File "<skill-root>\apk-reverse\scripts\frida-run.ps1" -Usb -ListProcesses
pwsh -File "<skill-root>\apk-reverse\scripts\frida-run.ps1" -Usb -Spawn -Package com.example.app -ScriptPath "D:\hooks\test.js"
```

### `scripts/rebuild-sign-install.ps1`

use:

- `apktool b` Rebuild APK
- `zipalign` Alignment
- `apksigner` Signature and Verification
- Optional direct `adb install`

Example:

```powershell
pwsh -File "<skill-root>\apk-reverse\scripts\rebuild-sign-install.ps1" -ProjectDir "C:\work\apktool_out" -Clean
pwsh -File "<skill-root>\apk-reverse\scripts\rebuild-sign-install.ps1" -ProjectDir "C:\work\apktool_out" -Install -Reinstall -DeviceSerial "127.0.0.1:7555"
```

illustrate:

- Generate and reuse debugging keystore by default
- The default output is to the same directory as `ProjectDir`, which is convenient for putting together with the original package and unpacking directory.

### `scripts/manifest-summary.ps1`

use:

- Extract package name
- Column permissions
- Column activity/service/receiver/provider
- Mark the main startup activity

Example:

```powershell
pwsh -File "<skill-root>\apk-reverse\scripts\manifest-summary.ps1" -ManifestPath "C:\work\apktool_out\AndroidManifest.xml"
```

If you want to analyze `.so`, `lib/arm64-v8a/*.so`, `lib/armeabi-v7a/*.so`, then combine:

- `ida-reverse`
- `radare2`

## Tool division of labor

### `jadx`

Used for:

- Java decompilation reading
- Package name, class name, method name search
- First understand the APK from the high-level logic

Commonly used commands:

```bash
jadx -d jadx_out app.apk
jadx --single-class com.example.LoginActivity -d jadx_out app.apk
jadx --deobf -d jadx_out app.apk
```

### `JEB Pro` (optional commercial tool)

Used for:

- Cross-validation and deep decompilation of Android DEX/APK/ARM
- Supplement static analysis when JADX output is incomplete or heavily obfuscated
- Perform second tool chain verification on classes, methods and calling relationships of the same target

boundary:

- JEB Pro is commercial software and users must obtain and install a valid license by themselves; this package will not download, crack or circumvent licenses.
- Only called if `tool-index` has confirmed that the native JEB is available; otherwise continue using `jadx`, `apktool`, Ghidra, IDA, or radare2.
- The third-party JEB MCP bridge is not dependent on this package. Before installation, the source code, permissions, network behavior and version must be reviewed according to `../ops/skill-supply-chain.md`, and then the user must explicitly confirm the registration.

### `apktool`

Used for:

- Unpack APK
- View and modify `AndroidManifest.xml`
- View and modify smali
- Rebuild APK

Commonly used commands:

```bash
apktool d app.apk -o apktool_out
apktool b apktool_out -o rebuilt.apk
```

### `frida`

Used for:

- Dynamic observation of Java method calls
- Hook native export function
- Bypass root detection, certificate verification, debugging detection

Commonly used commands:

```bash
frida-ps -U
frida -U -f com.example.app -l hook.js
frida-trace -U -f com.example.app -j '*!*certificate*'
```

### `adb`

Used for:

- Device connection
- Install APK
- View log
- Pull files

Commonly used commands:

```bash
adb devices
adb install -r app.apk
adb shell pm list packages
adb logcat
adb pull /data/local/tmp/file .
```

## Recommended workflow

### 1. Triage

First determine the general composition of the APK, and don’t rush to change the package or Hook.

Recommended action:

1. Export Java code using `jadx -d jadx_out app.apk`
2. Export smali and resources with `apktool d app.apk -o apktool_out`
3. Take a look first:
   - `AndroidManifest.xml`
   - Main `package`
   - `application`、`activity`、`service`、`receiver`
   - Is there `.so` in the `lib/` directory?
4. Issue #65 Threat Pattern Quick Check (Authorized Samples/Devices; see `../reverse-engineering/references/nonpe-format-cookbook.md` §7–8 for details):
   - Transparent/hidden icon (AU): `aapt dump badging` + manifest theme/label/icon → `E-android-hidden-icon-manifest`
   - Magisk/script grid machine features and remote curl|sh (AR/AS) → Features and URL authentication, **does not execute** the destruction command
   - Persistence path (AT): `service.d` / `priv-app` etc. → `E-android-persistence`

### 2. Java logic observation

Read from `jadx_out` first:

- `MainActivity`
- `Application`
- Login, network, encryption, risk control related categories
- Third-party SDK initialization class

Common keywords:

- `login`
- `sign`
- `encrypt`
- `cipher`
- `token`
- `root`
- `certificate`
- `trust`
- `okhttp`
- `retrofit`
- `webview`

If the Java code is readable, locate the business logic here first.

### 3. Smali confirms with the resource layer

When the result of `jadx` is incomplete, confusing, or actual patch is needed, switch to `apktool_out`:

- See `smali*/`
- See `res/values/strings.xml`
- See `AndroidManifest.xml`

Priority patches:

- `android:exported`
- debug flag
- root detection return value
- Login verification logic
- Certificate verification branch

### 4. Rebuild and install

After modification:

```bash
apktool b apktool_out -o rebuilt.apk
```

Or directly use script to close the loop:

```powershell
pwsh -File "<skill-root>\apk-reverse\scripts\rebuild-sign-install.ps1" -ProjectDir "apktool_out" -Install -Reinstall -DeviceSerial "127.0.0.1:7555"
```

illustrate:

- This skill only guarantees `apktool` link reestablishment
- If it needs to be formally installed on the device later, a signature process is usually required.
- If the task goes into signature/alignment, add `apksigner` / `zipalign`

### 5. Dynamic Hook

When static analysis is not enough, use Frida:

- Hook login function
- Hook `OkHttp` / `Retrofit` / `WebView` Key points
- Hook `javax.crypto`、`MessageDigest`
- Hook root detection function
- Hook SSL pinning logic

in principle:

- Hook the Java layer first, and then see if native Hook is needed
- Print the parameters and return value first, and then decide whether to actively modify the return value

suggestion:

- Simple one-time command directly uses `frida-*`
- Injection processes that require stable reuse are given priority `scripts/frida-run.ps1`

### 6. Native `.so` shunt

If the APK contains the key `.so`:

- Find `lib/**/*.so` with `apktool` or `jadx`
- If you only export symbols, strings, and quick triage, use `radare2`
- For long-term in-depth analysis, decompilation, renaming, and type recovery, use `ida-reverse`

When encountering these signals, switch to native as soon as possible:

- The Java layer is just a JNI wrapper
- The core signing logic is not in Java
- The key logic disappears after `System.loadLibrary()`
- Certificate verification/risk control is in `.so`

## Output requirements

Finally at least explain:

- Entry components and key classes
- The key logic is in Java, smali or `.so`
- Confirmed sensitive points: login, signature, root, SSL, WebView, JNI
- If you made a patch, explain what was changed.
- If Hook is used, please indicate which class/method/exported function is Hooked

## Prohibited matters

- Don’t blindly change smali from the beginning
- Don’t write Hook without looking at the manifest and main entry
- Don’t directly equate incomplete Java decompilation with “unanalyzable logic”
- Don't continue to stick to the Java layer when `.so` clearly carries the core logic.

## Quick command memo

```bash
# Decompile Java
jadx -d jadx_out app.apk

# Unpack APK
apktool d app.apk -o apktool_out

# Rebuild APK
apktool b apktool_out -o rebuilt.apk

# Equipment and processes
adb devices
frida-ps -U

# Start and inject
frida -U -f com.example.app -l hook.js
```

---

## routing context

**Upstream entrance**: `skills/SKILL.md` (master control), `routing.md`
**Downstream Export**:
- The core logic is in `.so` → `ida-reverse/` or `radare2/`
- Requires dynamic Hook/verification → `reverse-engineering/tools-dynamic.md` (Frida chapter)
- General reverse methodology → `reverse-engineering/SKILL.md`

**Sibling association module**: `reverse-engineering/` (.so analysis and advanced Frida usage)

---

## On-Demand Bootstrap

The entry script of this skill has been connected to the unified bootstrapping system. When a tool is missing, it will not directly report an error, but will automatically try to install it.

### Automation capability boundaries

| tool | can be installed automatically | installation method | description |
|------|-----------|---------|------|
| jadx | ✓ | GitHub Release ZIP | automatically download and decompress to `%USERPROFILE%\Tools\jadx\` |
| apktool | ✓ | GitHub Release JAR + wrapper | automatically downloads jar and generates bat to `%USERPROFILE%\Tools\apktool\` |
| JEB Pro | ✗ | User manually installs and provides a valid license | Optional Android / ARM cross-validation tool; third-party MCP bridge needs to be independently audited |
| frida / frida-ps | ✓ | pip install frida-tools | requires Python already installed |
| adb | ✓ | winget / fallback path | automatic installation Android Platform-Tools |
| zipalign | ✗ | needs to be installed manually Android Build-Tools | `sdkmanager "build-tools;35.0.0"` |
| apksigner | ✗ | requires manual installation Android Build-Tools | Same as above |

### Bootstrap trigger point

- `scripts/decode.ps1`: `bootstrap-reverse.ps1` is automatically called when jadx or apktool is missing
- `scripts/rebuild-sign-install.ps1`: Automatically call bootstrap when adb or apktool is missing
- `scripts/frida-run.ps1`: Currently still a manual check (frida is usually installed via pip)

### When bootstrapping fails

If the automatic installation fails, the script throws an explicit error with a manual installation link. Common reasons:
- The network is unreachable (GitHub API / PyPI is unreachable)
- winget is not available (Windows version is too low)
- Java is not installed (apktool depends on JDK)


## Task completion self-check (MUST passes before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Am I using real toolpaths based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and written back the Checklist items required by RULES?
- [ ] If hidden icon/grid machine/persistence clue is hit: Do you want to press U–AV cookbook to record E-android-* Evidence (within authorization scope)?
