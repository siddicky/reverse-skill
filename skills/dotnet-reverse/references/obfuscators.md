# Detailed explanation of .NET obfuscator deobfuscation

 identifies, unpacks, and anti-tamper bypasses mainstream .NET obfuscators. Core tools:**de4dot**(automatically recognizes most shells) +**dnSpyEx**(manual patch) +**dnlib**(scripted).

## general decision table

| mixer | de4dot type | Typical features | Automatic unpacking | Manual points |
|--------|-------------|---------|---------|---------|
| ConfuserEx 1.x/2.x | `cfze` | anti-tamper, control flow transformation, string encryption, anti-debugging | ✅ Most automatic | new versions need to patch anti-tamper first |
| ConfuserEx 3.x / private modification | `cfze` | Same as above + custom protector | ⚠️ Part of | dump runtime / dnlib |
| SmartAssembly | `sa` | String encoding, resource compression, method call hiding | ✅ Automatic | resource decompression |
| Babel.NET | `babel` | Method body encryption, control flow, string | ✅ Automatic | — |
| Eazfuscator.NET | `eaz` | String/resource encryption, expression obfuscation | ⚠️ Part of | String decryptor |
| .NET Reactor | `reactor` | necrobit (code segment encryption) + anti-tamper | ⚠️ New version is difficult | dump + rebuild metadata |
| Themida .NET | — | shell + virtualization | ❌ de4dot does not work | dump memory, take the native idea |
| Agile.NET / CliSecure | `agile` | Method body encryption | ✅ Automatic | — |

## de4dot standard usage

```powershell
# automatically recognizes (sufficient in most cases)
de4dot target.exe -o target-clean.exe

# Explicitly specify type (automatic recognition failed)
de4dot --type cfze target.exe -o target-clean.exe

# first detects the shell type
de4dot --detect target.exe

# Batch
de4dot *.exe

# only decodes strings and does not control the flow (minimal intervention)
de4dot --strtyp delegate --strtok METHOD_TOKEN target.exe
```

`--strtyp` / `strtok` mode of de4dot: only decodes the string decryptor (specifies the decryption method token), retaining the original control flow. Suitable for scenarios where "you only want to see plain text strings but don't want to touch anti-tamper".

---

## ConfuserEx (most common)

### Feature Recognition

- entry module `<module>` class anti-tamper with `[MethodImpl(NoInlining)]` check
- A large number of `Dictionary<string, T>`'s string decryptors call
- control flow flattening (switch dispatch + state variable)
- resource is embedded in `.cmp` compressed resource
- dnSpyEx C# view: The class name/method name is garbled (`\uXXXX` or meaningless characters), and the method body fills the screen `int num = ...; switch(num)`

### unpacking process

```powershell
# 1. Standard shelling
de4dot target.exe -o target-clean.exe

# 2. If de4dot reports "unknown" or cannot be opened after unpacking → New version/privately modified ConfuserEx
#    first confirm anti-tamper:
Open dnSpyEx → Find the integrity check in Module .cctor or Main
```

### anti-tamper bypass (common in newer versions of ConfuserEx)

ConfuserEx's `anti tamper` will verify the method body hash at runtime and will crash if it is changed. de4dot can usually handle older versions, newer versions need to be done manually:

```text
Method A — dnSpyEx directly patches the verification function:
  1. Find the anti-tamper verification method (usually called in the static construction of <module>)
  2. IL editor: Change the verification method body to ret (return directly)
  3. Save → then feed to de4dot

Method B — runtime dump:
  1. Run MegaDumper / ExtremeDumper to dump the assembly in memory
  2. The dump has been decrypted, and then use de4dot to clean up the residue.
```

### control flow restored

de4dot will restore the flattened switch dispatch to normal if/while. If it is not completely restored (you see residual state machines), you can run de4dot again or follow IL manually.

---

## SmartAssembly

```powershell
de4dot --type sa target.exe -o target-clean.exe
```

 Features:
- string uses `SmartAssembly.Runtime.Strong` series encoding
- resource compression (`{assembly}.Resources`)
- method call hidden (`ProcessCaller` / indirect call)

de4dot has the best compatibility with SmartAssembly and can basically be done with one click.

---

## .NET Reactor（necrobit)

`.NET Reactor`'s**necrobit**encrypts the real method body and saves it to the resource, and then decrypts and injects it at runtime. The original method body is an empty shell. de4dot works with older versions, but often fails with newer versions (4.x+).

```text
When de4dot fails:
1. Let the program run (dotnet target.exe or double-click directly)
2. MegaDumper / ExtremeDumper dump process memory → export decrypted assembly
3. Use de4dot to clean up the residual obfuscation of the dump product
4. If metadata is damaged, use dnlib to rebuild it (see common-workflow.md)
```

---

## string decryptor manually extracts

The  obfuscator encrypts the string and calls the decryption method to restore it at runtime. Most of de4dot can automatically identify the decryptor, if the identification fails, manually:

```text
1. Find the decryption method in dnSpyEx (the signature is usually fixed:static string Decrypt(int) or Decrypt(string, int))
   - Characteristics: Called in large numbers, parameters are numeric constants, and return strings
2. Write down the method token (such as 0x06000012)
3. de4dot specifies the decryptor:
   de4dot --strtyp delegate --strtok 0x06000012 target.exe -o target-clean.exe
```

 If even the decryption method itself is obfuscated (control flow flattening), you need to remove the control flow first and then locate the decryptor.

## anti-debug common techniques

| Technique | Location | Bypass |
|------|------|------|
| `Debugger.IsAttached` check | any method | IL change `ldc.i4.0; ret` or patch getter |
| `Debugger.IsLogging` | — | Same as above |
| time detection (`DateTime.Now` difference) | method entry | patch difference comparison |
| `CheckRemoteDebuggerPresent` P/Invoke | — | nop call |
| Exception driven control flow (try/catch path selection) | main logic | cannot be simple nop, the real path of the catch block must be analyzed |

> .NET anti-debug is simpler than native - most of them are managed API calls, and dnSpyEx IL only needs to change one line.

## de4dot Fallback in case of failure

1. **de4dot --detect**To see the recognition results, compare  in the above table
2. **runtime dump**(MegaDumper / ExtremeDumper / Process Hacker export module)
3. **dnlib script**manual solution (see the dnlib section of common-workflow.md)
4. **dynamic priority**: when running, it will break at the decryption point, read the plain text directly, and get the information without unpacking

 community reference: Washi blog "misconceptions-about-dotnet" (common misconceptions in IL analysis), Kanxue .NET reverse section, Guided Hacking "Top 5 .NET RE Tools".
