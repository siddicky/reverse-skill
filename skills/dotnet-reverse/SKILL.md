---
name: dotnet-reverse
description: .NET/C# binary reverser. Used when the target is .NET assembly (PE header contains CLR, .exe/.dll managed program), C# compiled product (including NativeAOT), red team Sharp* tool (Rubeus / SharpHound / SharpHound, etc.), .NET obfuscator (ConfuserEx / SmartAssembly / Babel / Eazfuscator), .NET loader / info-stealer / shell malware. Prioritize using dnSpyEx + de4dot, and link dnSpy MCP when direct AI operation is required. Not used for pure native binaries (go with reverse-engineering / ida-reverse).
license: MIT
compatibility: Requires a filesystem-based code agent or CLI with shell access, Windows host preferred (dnSpyEx is Windows GUI); ILSpy/de4dot CLI + mono/dotnet runtime is available for Linux/macOS.
allowed-tools: Bash Read Write Edit Glob Grep Task WebFetch WebSearch
metadata:
  user-invocable: "false"
---

# .NET / C# reverse engineering specification

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Confirm target is .NET hosted with DIE/`file`/CLR headers (otherwise SWITCH to `ida-reverse/` / `reverse-engineering/`)
2. `NOW`: If confusion is suspected → unpack `de4dot` first, output `*-clean.exe`, and keep the original sample
3. `NEXT`: dnSpyEx (or dnSpy MCP / `ilspycmd`) static: C# browse +**IL view**see key judgment
4. `ACT`: Dynamic debugging when plaintext/C2 is required;**IL patch**takes precedence over C# to recompile  when logic needs to be changed.
5. The stage ends with 3–6 next step menus for the user (including export report)

## applicable scope

 Use this skill first when the task belongs to the following scenarios:

- identifies and reverses .NET/C# compiled products (managed PE/.exe/.dll)
- Analysis Red Team Sharp* Toolchain (Rubeus, SharpHound, SharpShell, etc.)
- deobfuscation ConfuserEx / SmartAssembly / Babel / Eazfuscator / .NET Reactor and other shells
- Reverse .NET loader / info-stealer / RAT decryption and C2 logic
- patch the C# program (change judgments, constants, keygen)
- analyzes the Mono/Unity hosting layer before IL2CPP (note: IL2CPP is native after compilation, use `reverse-engineering/` + seed-014)

 If targeting pure native binaries (C/C++/Go/Rust compiled, no CLR), use `reverse-engineering/`, `ida-reverse/` or `radare2/` instead.

## Core Principles

- **first identify and then start**: first confirm that it is a .NET managed program (PE header CLR + `#~` / `#Strings` stream + mscoree `_CorExeMain`), and then decide to use dnSpy instead of IDA
- **IL takes precedence over C#**: dnSpyEx's C# decompiler will lose/distort information (compiler-generated state machine, async/await, yield), key judgments and patches must be cut to**IL editor**, C# view is only used for quick browsing
- **de4dot first**: when encountering the obfuscator, first `de4dot` and then do static analysis, otherwise the string/control flow will be messed up
- **MCP linked to**: If dnSpy MCP (`dnspy_*` tool) is registered in the environment, give priority to the MCP side for decompile / IL inspection to avoid switching back and forth to GUI
- **evidence-based output**: the decomposition product, extracted configuration/C2/key, and patch diff must be downloaded to

## toolchain maps

| Capabilities | First Choice | Remarks |
|------|------|------|
| Decompile + debug + patch |**dnSpyEx**| Ace, the only GUI with IL editor; the old dnSpy has stopped updating, use the Ex branch |
| lightweight CLI / headless decompilation |**ILSpy**(`ilspycmd`) | suitable for batch, scripting, Linux/macOS |
| Deconfusion |**de4dot**| ConfuserEx The default solution for mainstream shells such as Family Bucket and SmartAssembly |
| Obfuscator identification |**Detect It Easy (DIE)**/**file**| Determine the shell type first and then decide the de4dot parameter |
| Programming operation IL |**dnlib**| Write C# script to batch change metadata/string decryptor |
| AI direct operation |**dnSpy MCP**| `dnspy_decompile` / `dnspy_inspect_il` and other tool surfaces |

> frontend: Windows host installs dnSpyEx + de4dot (choco or release); Linux/macOS uses `ilspycmd` + `dotnet runtime`. See the installation matrix of `references/sharp-tools.md` for details.

## six-stage workflow

### 1. Identify

 confirms that the target is a managed program, do not mistake native PE for .NET Analysis:

```powershell
# Windows
file target.exe # "PE32 executable ... for MS Windows" is not enough
# key: see if there is CLR
powershell -c "[System.Reflection.AssemblyName]::GetAssemblyName('target.exe')"
# or
Drag dnSpyEx directly in - if it can be opened, it is hosted

# General
strings target.exe | grep -iE "mscoree|_CorExeMain|mscorlib|System\\."
```

**.NET Identification mark:**
- PE header `Data Directory[14]` (CLR Runtime Header) non-zero
- `mscoree.dll` import / `_CorExeMain` import
- `#~`, `#Strings`, `#US`, `#GUID`, `#Blob` metadata stream
- `mscorlib` / `System.Private.CoreLib` string

**NativeAOT Exception:**is compiled into native, without CLR header, but has `System.Private.CoreLib` string and reconstructed type metadata - this type of `reverse-engineering/` (IDA/r2), this skill only provides identification prompts.

### 2. Detect

```powershell
# DIE quickly identifies
diec target.exe                        # Detect It Easy CLI
# or drag it into dnSpyEx to see if there are a lot of garbled class names/control flow deformation
```

 Common obfuscator → Unpacking strategy (see `references/obfuscators.md` for details):

| obfuscator | features | de4dot processing |
|--------|------|------------|
| ConfuserEx (1.0.0 / 2.x) | `<module>` anti-tamper, control flow distortion, string encryption | `de4dot target.exe` Normally automatically recognizes |
| SmartAssembly | `circular`/`string encoding`, resource compression | `de4dot target.exe` |
| Babel.NET | method body encryption, control flow | `de4dot target.exe` |
| Eazfuscator.NET | String/resource encryption | `de4dot`, some versions require manual |
| .NET Reactor | anti-tamper + necrobit | `de4dot`, the new version may fail and requires manual |

### 3. Deobfuscate (deobfuscation)

```powershell
# de4dot automatically recognizes most shells  by default
de4dot target.exe -o target-clean.exe

# specified type (when automatic recognition fails)
de4dot --type cfze target.exe          # ConfuserEx
de4dot --type sa target.exe            # SmartAssembly

# multi-layer obfuscation / de4dot reported unknown
de4dot --detect target.exe # See what it recognizes
# You may need to patch anti-tamper first and then de4dot (see references/obfuscators.md)
```

 outputs: `target-clean.exe`, which is used for subsequent analysis.**retains the original sample**for comparison.

### 4. Static Analyze

dnSpyEx loads the unpacked sample:

- **C# View**: Quick view of class structure, method signature, string (for positioning)
- **IL view**: Key judgments, encryption logic, and state machines must see IL (right click → Edit IL or IL view)
- Find the entrance for : `Main` / `Startup` / module initializer (`Module .cctor`)
- Find the key logic for : search `flag`, `password`, `verify`, `check`, `encrypt`, `http`, `Config`

```text
Locate the string → back reference → find the method to use it → see the judgment logic in IL view
```

### 5. Dynamic (dynamic debugging)

dnSpyEx debugger: attach process/start debugging, breakpoint under key method, observe runtime:
- decrypted plaintext string (many obfuscators decrypt the string at runtime)
- C2 address, configuration decryption result
- exception-driven control flow (anti-debug commonly used `try/catch` to hide the real path)

> .NET dynamic debugging is much more friendly than native - you can directly see object values ​​and string contents. Prioritize dynamic rather than static.

### 6. Patch (modify as needed)

```text
dnSpyEx → Right click method → Edit Method (C# ) or Edit IL
  - Change the judgment: ldc.i4.0 → ldc.i4.1 (false→true)
  - Change constants: directly edit strings/numbers
  - Delete verification: nop deletes the entire paragraph
File → Save Module → Replace original file
```

**IL patch reliability > C# patch**: C# recompilation may fail (missing references, incorrect syntax), IL editing has almost no distortion. See `references/common-workflow.md` for details.

## triggers scene routing

When user  says this, enter this skill:
- ".NET / C# binary reverse engineering" / "C# program decompilation"
- "dnSpy analysis" / "dnSpyEx patch"
- "ConfuserEx / SmartAssembly / Babel Deconfusion / Unpacking"
- "Sharp* Tool Analysis" (Rubeus / SharpHound / SharpShell)
- ".NET malware / loader / info-stealer reverse"
- "C# program patch / keygen / modification judgment"

## When does cut out

- IL2CPP compiled Unity game → `reverse-engineering/` + `seed-014_unity-il2cpp-reverse.md` (IL2CPP is native, does not use dnSpy)
- NativeAOT product → `reverse-engineering/` (same as above, native)
- pure native PE (no CLR) → `reverse-engineering/` / `ida-reverse/`
- needs to batch migrate symbols/functions to other versions → `binary-diff/`
- needs to draw the attack path/call chain diagram → `diagram-generator/`

## routing context

**upstream entrance**: `skills/SKILL.md` (master control), `routing.md`
**downstream outlet**:
- IL2CPP / NativeAOT（native）→ `reverse-engineering/`
- deep native .so/.dll segment analysis → `ida-reverse/` / `radare2/`
- requires AI to directly operate dnSpy → register and link dnSpy MCP (see `references/sharp-tools.md`)

**Same level association module**:
- `reverse-engineering/languages-compiled.md` (.NET introduction points to this module)
- `apk-reverse/` (Xamarin/MAUI Android reverse engineering can switch back to this module to see the C# layer)

## Reference Document

- [references/obfuscators.md](references/obfuscators.md) — ConfuserEx / SmartAssembly / Babel / Eazfuscator / .NET Reactor Detailed explanation of obfuscation + anti-tamper to bypass
- [references/common-workflow.md](references/common-workflow.md) — Complete workflow, IL patch reliability, string decryptor extraction, state machine identification
- [references/sharp-tools.md](references/sharp-tools.md) — Red team Sharp* tool analysis, tool installation matrix, dnSpy MCP integration, community resource index

## task completed self-test

- [ ] Have you confirmed the CLR/hosted identity (or SWITCHed out this skill)?
- [ ] Should the obfuscated sample be de4dot/equivalently unpacked before further analysis?
- [ ] Is the critical logic verified using IL views (instead of just looking at C# pseudocode)?
- [ ] Is the product (clean sample/configuration/patch diff) available and reproducible?
- [ ] Does - [ ] provide a next step menu or report exit?
