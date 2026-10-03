# APK Security Testing Quick Check

> Based on OWASP MASTG (Mobile Application Security Testing Guide).
> Covers six dimensions: static analysis, dynamic analysis, network communication, data storage, authentication and authorization, and code protection.

---

## Static analysis checklist

### Manifest Audit

```text
□ android:debuggable="true" → Debuggable (should not appear in production environment)
□ android:allowBackup="true" → Data can be backed up and extracted
□ Component of android:exported="true" → Exposed Activity/Service/Receiver/Provider
□ Custom permission protectionLevel → whether it is normal (should be signature)
□ Scheme in intent-filter → Customize whether deeplink can be hijacked
□ android:usesCleartextTraffic="true" → Allow plain text HTTP
□ minSdkVersion is too low → security features may be missing
```

### Code audit key points

```text
□ Hardcoded key/Token (search for "key", "secret", "password", "api_key")
□ Unsafe random numbers (java.util.Random instead of SecureRandom)
□ Insecure encryption (ECB mode, DES, MD5 for passwords)
□ WebView configuration (setJavaScriptEnabled + addJavascriptInterface = RCE risk)
□ SQL injection (rawQuery splicing user input)
□ Path traversal (openFile of ContentProvider does not verify the path)
□ Log leakage (Log.d/Log.i outputs sensitive information)
□ Clipboard leakage (ClipboardManager stores sensitive data)
□ Implicit Intent leakage (sendBroadcast does not specify a package name)
```

### Third-party library audit

```text
□ Outdated OkHttp/Retrofit version (known vulnerability)
□ Outdated WebView kernel
□ SDK with known vulnerabilities (check for CVE)
□ Advertising SDK data collection scope
□ Push SDK configuration (whether token is leaked)
```

---

## Dynamic Analysis Checklist

### Frida Hook Priority Goals

| Target | Hook Point | Purpose |
|------|---------|------|
| Login authentication | `LoginActivity.login()` | Observe credential processing |
| Signature generation | `*Sign*`, `*sign*`, `*encrypt*` | Restore signature algorithm |
| SSL Pinning | `CertificatePinner.check` | Bypass packet capture |
| Root detection | `*root*`, `*su*`, `*magisk*` | Bypass detection |
| Crypto operations | `javax.crypto.Cipher` | Extract key/IV |
| Token storage | `SharedPreferences.getString` | Observe token reading and writing |
| Network request | `OkHttpClient.newCall` | Observe request construction |

### Commonly used Frida one-line commands

```bash
# Track all cryptographic operations
frida-trace -U -f com.target.app -j '*Cipher*!*'

# Track all HTTP requests
frida-trace -U -f com.target.app -j '*OkHttp*!*'

# Track SharedPreferences reading and writing
frida-trace -U -f com.target.app -j '*SharedPreferences*!*'

# Trace all native function calls
frida-trace -U -f com.target.app -i 'Java_*'
```

### Objection Quick Commands

```bash
# connect
objection -g com.target.app explore

# Common commands
android hooking list activities
android hooking list services
android sslpinning disable
android root disable
android clipboard monitor
env                              # View application catalog
sqlite connect <db_path>         # Connect to database
```

---

## Network communication security

### Packet capture configuration

```text
Method 1: System proxy + Burp/mitmproxy
- Set up WiFi proxy → Burp listening address
- Install the CA certificate to the device
- Android 7+ requires network_security_config or Frida bypass

Method 2: VPN mode (recommended)
- Using HttpCanary/Packet Capture
- does not require root, no proxy configuration is required
- But unable to decrypt SSL Pinning traffic

Method 3: Frida + r2frida
- Intercept network calls directly within the process
- Not restricted by proxy/VPN
```

### Check items

```text
□ Whether to use HTTPS (all API calls)
□ Whether there is SSL Pinning (certificate binding)
□ Whether the certificate verification is correct (self-signed is not accepted)
□ Is there a Certificate Transparency (CT) check?
□ Whether the API key is transmitted in clear text in the request
□ Does the Token have an expiration mechanism?
□ Is there a request signature to prevent tampering?
□ Whether there is replay attack protection (nonce/timestamp)
□ Is WebSocket encrypted?
□ Whether there is sensitive data in the URL parameters (will be logged)
```

---

## Data storage security

### Check location

| Locations | Risks | Check Orders |
|------|------|---------|
| SharedPreferences | Clear text storage token/password | `adb shell cat /data/data/pkg/shared_prefs/*.xml` |
| SQLite database | Unencrypted sensitive data | `adb pull /data/data/pkg/databases/` |
| External storage | Readable by any application | `adb shell ls /sdcard/Android/data/pkg/` |
| Application log | Leak debugging information | `adb logcat \| grep pkg` |
| Backup files | allowBackup=true | `adb backup -f backup.ab pkg` |
| Keyboard cache | Input history | Check if `inputType` is `textPassword` |
| Screenshot protection | Sensitive pages can be screenshotted | Check `FLAG_SECURE` |

### Comparison of encrypted storage solutions

| Solution | Security | Description |
|------|--------|------|
| SharedPreferences plain text | ❌ | Read directly after root |
| EncryptedSharedPreferences | ✓ | AndroidX Security Library |
| SQLCipher | ✓ | Encryption SQLite |
| Android Keystore | ✓✓ | Hardware-level key protection |
| Custom AES encryption | ⚠️ | Depends on key management |

---

## Authentication and Authorization

### Common vulnerabilities

| Vulnerabilities | Testing Methods |
|------|---------|
| Weak password policy | Try 123456, password, etc. |
| No locking mechanism | Brute force login interface |
| Token does not expire | Replay old token after logging out |
| Unauthorized access | Modify user_id in request |
| SMS verification code can be blasted | 4/6 digits with no frequency limit |
| OAuth configuration error | redirect_uri can be tampered with |
| Biometric Authentication Bypass | Hook BiometricPrompt |
| Device binding bypass | Modify device_id |

### Test Payload

```bash
# ultra vires test
curl -H "Authorization: Bearer USER_A_TOKEN" \
     "https://api.target.com/users/USER_B_ID/profile"

# Token replay
# 1. Log in normally to obtain token
# 2. Log out
# 3. Request with old token → should return 401

# SMS verification code blasting
for code in $(seq 0000 9999); do
    curl -X POST "https://api.target.com/verify" \
         -d "phone=13800138000&code=$code"
done
```

---

## Code protection assessment

| Protection measures | Detection methods | Bypass difficulty |
|---------|---------|---------|
| ProGuard Obfuscation | jadx Check if class name is a/b/c | Low (just rename) |
| String encryption | Search for decryption function, Hook to obtain plain text | Medium |
| Anti-debugging | Try attach debugger | Medium (Frida can bypass it) |
| Root Detection | Runs on a rooted device | Medium (Universal Script Bypass) |
| Emulator Detection | Run on emulator | Low-Medium |
| Integrity verification | Install after modifying APK | Medium (patch verification function) |
| Reinforcement/unpacking | View entry classes and .so | Medium-High (requires unpacking) |
| Native protection | Core logic in .so | High (requires IDA analysis) |
| VMP virtualization | Code is executed virtually | Extremely high |

---

## Quick testing process (30 minutes)

```text
1. [5min] Unpacking + Manifest audit
   apktool d app.apk
   Check debuggable/allowBackup/exported/cleartext

2. [10min] Quick code audit
   jadx -d out app.apk
Search : password, key, secret, token, http://

3. [5min] Network test
   Configure agent → operate APP → check if there is clear text/weak encryption

4. [5min] Storage check
   adb shell → check shared_prefs and databases

5. [5min] Dynamic verification
   Frida hook key function → confirm discovery
```
