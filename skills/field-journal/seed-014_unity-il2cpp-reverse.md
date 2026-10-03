# [Seed] Unity IL2CPP game reverse engineering → restore metadata + modify logic

## Scene classification
Game Security/Mobile Reverse

## Goal overview
A Unity packaged Android game (IL2CPP mode) with in-game purchases or core algorithms written in C# but compiled to native. It is necessary to restore method names, locate key logic, and modify/hook implementation modifications.

## Complete execution link

1. Unpack the APK and confirm it is IL2CPP
   ```bash
   unzip target.apk -d apk
   ls apk/lib/arm64-v8a/        # See libil2cpp.so i.e. IL2CPP
   ls apk/assets/bin/Data/Managed/Metadata/
   # Key file: global-metadata.dat
   ```
2. Restore metadata using **Il2CppDumper**
   ```bash
   Il2CppDumper libil2cpp.so global-metadata.dat output/
   # Product: DummyDll/ + script.json + il2cpp.h + dump.cs
   ```
3. Run IDA’s IL2CPP script (`ida_with_struct.py`)
   - Load libil2cpp.so → File → Script File → select ida_with_struct.py → select script.json
   - IDA can now see C# method names, signatures, and strings
4. Search by business keyword in dump.cs (`AddCoin` / `OnPurchase` / `Verify` / `IsVip` / `CheckSign`)
5. Get the offset of the key method → ​​IDA skip to disassembly/decompilation
6. Choose how to modify:
   - **Static patch**: Direct IDA to change the judgment to `mov w0, #1; ret`
   - **Dynamic hook**: Frida connects to il2cpp method (using Frida-Il2CppBridge)
7. Repackaging verification/injection verification

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| Il2CppDumper reports that the metadata version is not supported | The new version of Unity has changed the metadata format | Upgrade Il2CppDumper to the latest / use Il2CppInspectorRedux instead | 30min |
| global-metadata.dat is encrypted | uses AntiCheatToolkit / custom encryption | Find the decryption function during game initialization (usually around il2cpp_init) → Frida dumps | 2h after mmap |
| dump.cs sees the method name but IDA does not match | script.json is inconsistent with so | must use the product of the same dump; clear the cache when changing IDA | 20min |
| Frida hook IL2CPP method reports error | IL2CPP method is not standard Java/ObjC, method offset needs to be calculated | Use frida-il2cpp-bridge library, do not hard-write Interceptor.attach | 1h |
| Game crashes after Patch | Verify file hash or anti-tamper | Find hash verification logic and patch it out, or use hook without changing the file | 2h |
| crashes on startup after repackaging | apksigner v2 signature cannot be changed bytes before signing | Delete META-INF + apktool b + apksigner sign | 30min |

## Toolchain discovery

- **Il2CppDumper** Old but still the default choice
- **Il2CppInspectorRedux** is more modern, supports the new Unity, and can output a variety of IDA / Ghidra / Binary Ninja plug-in scripts
- **frida-il2cpp-bridge** is the de facto standard for hooks on IL2CPP, N times better than naked Frida
- **DnSpy** / **dnSpyEx** are used to view DummyDll (dumped pseudo .NET assembly)
- **UnityCheat** series of auxiliary tools (GameGuardian series is not expanded)

## Key code/command

frida-il2cpp-bridge hook example:

```typescript
// hook.ts
import "frida-il2cpp-bridge";

Il2Cpp.perform(() => {
    const Assembly = Il2Cpp.domain.assembly("Assembly-CSharp").image;

    // hook static method
    const PlayerData = Assembly.class("PlayerData");
    PlayerData.method("AddCoin").implementation = function (n: number) {
        console.log("[+] AddCoin called with:", n);
        return this.method("AddCoin").invoke(99999); // Change to 99999
    };

    // hook instance method
    const Purchase = Assembly.class("Purchase");
    Purchase.method("VerifyReceipt").implementation = function () {
        console.log("[+] VerifyReceipt → always true");
        return true;
    };
});
```

```bash
# Compile + Inject
npm install frida-il2cpp-bridge
frida-compile hook.ts -o hook.js
frida -U -f com.target.game -l hook.js --no-pause
```

IDA static patch:

```text
1. Open libil2cpp.so and run il2cpp_load_metadata.py
2. Jump to the offset corresponding to IsPurchaseValid in dump.cs
3. Change the beginning of the function to MOV W0, #1; RET (ARM64)
4. Apply Patches → Save → Replace back to APK → Re-sign
```

## Suggestions for improvements to this package

- `reverse-engineering/SKILL.md` Unity is covered, but IL2CPP **complete working chain** case is missing
- `reverse-engineering/references/il2cpp-cheatsheet.md` is written separately: dump tool comparison, frida-bridge template, encryption metadata processing
- Add frida-il2cpp-bridge to bootstrap manifest

## Reusable patterns/script snippets

**IL2CPP standard process**:

```text
1. Confirm IL2CPP (check if there is libil2cpp.so under lib/abi)
2. Find the metadata (assets/bin/Data/Managed/Metadata/global-metadata.dat or be encrypted)
3. Il2CppDumper/Inspector Restore
4. IDA + script brings back meta information
5. dump.cs search business keywords
6. Choose patch or hook
7. Verification (startup + actual scenario)
```

**Encrypted metadata processing**:

```text
1. Frida hooks in the fopen/open system call to see who reads global-metadata.dat
2. Dump the decrypted metadata in memory after mmap/read
3. Feed the dumped memory as metadata to Il2CppDumper
```

## evolution action
- [ ] reverse-engineering/references Add il2cpp complete chapter
- [ ] bootstrap-manifest added frida-il2cpp-bridge / Il2CppInspectorRedux
- [x] Routing matrix already includes Unity / IL2CPP

## environmental information
- Windows / macOS (for running Il2CppDumper), target device Android arm64
- IDA Pro 7.7+ or Ghidra 11+
- frida-tools 16.x, frida-il2cpp-bridge 0.9+
- Unity version: 2019.x - 2022.x (the metadata format of different versions is slightly different)

## redaction requirements
This article is seed data, written based on public technical models, and does not involve any real games. The package name `com.target.game` is a placeholder.
