# Red Team Sharp* Tool Analysis & Tool Installation Matrix & dnSpy MCP

## Red Team Sharp* Tool Analysis

 red team tools are largely written in C# (Sharp* series), and reversing them is a common scenario: understanding detection logic, changing features, and extracting embedded configurations.

### Common Sharp* Tool Quick Check

| Tool | Function | Reverse focus |
|------|------|-----------|
|**Rubeus**| Kerberos attack (AS-REP roast / Kerberoast / S4U / pass-the-ticket) | Rubeus project structure is fixed, look for `Interop.*` P/Invoke section to see the native call |
|**SharpHound**| BloodHound data collector | LDAP query logic, collected attribute collection |
|**SharpShell / SharpWS**| Remote execution, horizontal | WMI / WinRM call, command confusion |
|**Seatbelt**| Information collection | Collection item list, judgment logic |
|**SharpRoast**| Kerberoasting | Ticket request/parse |
|**Inveigh / SharpSploit**| Middleman / Universal Exploitation Framework | Reflective loading, API call chain |

### General analysis routine

```text
1. Open dnSpyEx (usually there is no confusion, a few teams will add ConfuserEx)
2. Inspect Program.Main or the entrypoint command dispatch (Rubeus uses a switch(command) structure)
3. Find the implementation class/method of the target command
4. Look at the P/Invoke section (Interop.* namespace) - native API calls are here
5. Extract embedded resources (some tools embed configurations/templates)
6. If you need to change features (EDR avoidance): change command strings, API calls, and string constants
```

### Rubeus structure example

Rubeus dispatches with commands, one class per subcommand. Find Kerberoasting logic:

```text
Entry: Rubeus.CommandLineParser → parse args
Dispatch: switch(command) → "kerberoast" → invoke Ask.TGS(...)
P/Invoke: Rubeus.Interop.Lsa* / Native.cs → native Kerberos API
Key: LsaCallAuthenticationPackage (KERB_RETRIEVE_TKT_REQUEST)
```

Change characteristics of  (circumvention): Change the command string `"kerberoast"` to a custom name, change the `Rubeus` banner string, and change the P/Invoke calling sequence.

### inline configuration extraction

 Many loaders/tools embed C2, key, and certificate encryption in resources or fields:

```powershell
# dnSpyEx Look at Resources (resource tree)
# or command line
powershell -c "[System.Reflection.Assembly]::LoadFile('target.exe').GetManifestResourceNames()"
# After finds the resource, right-click dnSpyEx → Extract / Save
```

 runtime decryption configuration → dynamically dump plaintext at decryption method return point (see `common-workflow.md`).

---

## tool installation matrix

### Windows (preferred, dnSpyEx is GUI)

```powershell
# method A: Chocolatey
choco install dnspy ilspy de4dot detect-it-easy

# Method B: Manual download release (recommended, version controllable)
# dnSpyEx:    https://github.com/dnSpyEx/dnSpy/releases
# de4dot:     https://github.com/de4dot/de4dot/releases
# ILSpy:      https://github.com/icsharpcode/ILSpy/releases
# DIE:        https://github.com/horsicq/Detect-It-Easy/releases
# dnlib:      dotnet add package dnlib  (NuGet)
```

### Linux/macOS (without dnSpyEx GUI, use CLI)

```bash
# ILSpy CLI Decompile
dotnet tool install -g ilspycmd
ilspycmd target.exe -p -o outdir/ # Decompile to directory

# de4dot cross-platform (requires mono or dotnet)
# downloads the .dll of the de4dot product from release, and uses dotnet to run
dotnet de4dot.dll target.exe -o target-clean.exe

# dnlib (scripted, dotnet SDK required)
dotnet new console -o dnclean && cd dnclean
dotnet add package dnlib

# DIE CLI (diec)
# Linux: Install  from https://github.com/horsicq/Detect-It-Easy
diec target.exe
```

### .NET runtime precedes

```bash
# Linux
sudo apt install dotnet-runtime-8.0 # or 6.0/7.0 to see the target
# macOS
brew install --cask dotnet-sdk
```

> dnSpyEx (with IL editor + debugger) is only available in Windows GUI version. For .NET reverse engineering on Linux/macOS, you can only use `ilspycmd` decompilation + `dnlib` script patch, and there is no equivalent interactive debugging GUI. When you need to patch, go to Windows first.

---

## dnSpy MCP integrates

The  community already has multiple dnSpy MCP projects, which expose dnSpy's decompilation/IL inspection into MCP tools that can be directly called by AI - completely consistent with the MCP philosophy of reverse-skill.

### Mainstream dnSpy MCP Project

| Project | Features | Adaptation |
|------|------|------|
|**soufianetahiri/dnspy-mcp**| Core MCP Server, exposing decompile, IL inspection and other tools | Claude Code / Cursor |
|**AgentSmithers/DnSpy-MCPserver-Extension**| runs as a dnSpyEx extension, deeply integrated with the GUI | loads | within dnSpyEx
|**malwarecakefactory/dnspy-mcp-extension**| 33 tools covering triage → deobfuscation whole process | full process automation |

### registered to Claude MCP Configure

After  installs the dnSpyEx extension according to the corresponding project README, register it at `~/.claude/mcp.json` (the specific command/args are subject to the project README):

```json
{
  "mcpServers": {
    "dnspy": {
      "command": "dotnet",
      "args": ["path/to/dnspy-mcp.dll"]
    }
  }
}
```

The AI ​​linkage path of this skill after  is registered: The user says "analyze this .NET" → route to `dotnet-reverse/` → prioritize the `dnspy_decompile` / `dnspy_inspect_il` tool surface → switch to the GUI if it fails.

> dnSpy MCP does not have the built-in bootstrap capability of reverse-skill, and users need to manually install the extension and register it according to the project README. You may consider adding `bootstrap-manifest.json` in the future.

---

## Community Resource Index

### highly recommends

- **Washi blog**— .NET reverse engineer: https://blog.washi.dev/posts/misconceptions-about-dotnet/
  - core point of view:**should not rely too much on dnSpy's C# decompiler, but should be familiar with the IL editor**(consistent with the IL priority principle of this project)
- **dnSpyEx**— Active maintenance branch of dnSpy: https://github.com/dnSpyEx/dnSpy
- **de4dot**— .NET deobfuscation: https://github.com/de4dot/de4dot
- **dnlib**— Metadata programming: https://github.com/dnlib/dnlib

### practical tutorial

- Medium《De-obfuscating and reversing a .NET/C# spyware》— dnSpy + de4dot practical info-stealer de-obfuscating
- YouTube "dnSpy Patch .NET EXEs & DLLs" — step by step patch + keygen
- Kanxue Forum .NET Reverse Section - Search ".net Reverse" / "dnSpy" / "ConfuserEx" There are a large number of practical posts, Nuitka reverse, and anti-kill discussions
- Guided Hacking "Top 5 .NET Reverse Engineering Tools" — dnSpy still ranks first
- StackExchange / Reverse Engineering — `DynamicMethod` Debugging and other advanced issues

### This repository already has .NET resources (linkage)

- `reverse-engineering/tools.md` `.NET Analysis` segment — dnSpy/ILSpy tool quick review + Codegate 2013 two-stage XOR+AES-CBC mode
- `reverse-engineering/field-notes.md` `.NET` segment — tool shorthand
- `reverse-engineering/awesome-re-resources.md` — de4dot selected for
- `field-journal/seed-014_unity-il2cpp-reverse.md` — Unity IL2CPP (native side, complementary to .NET managed layer)

The reverse depth content of .NET is unified into this module, and the quick search index can be retained in `reverse-engineering/`.
