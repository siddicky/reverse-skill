# Go binary reverse engineering guide

> Go compiled binaries have unique challenges: static linking leads to huge size, tens of thousands of functions, special string format, and difficulty in recovery after symbol stripping.
> This document covers tool chains, recovery techniques, and practical workflows.

---

## Go binary feature recognition

Quickly determine whether a binary is compiled with Go:

```bash
# string characteristics
strings binary | grep -E "runtime\.|go\.buildid|GOROOT"

# rabin2 recon
rabin2 -z binary | grep -i "runtime"

# Unusually large file size (statically linked runtime)
# Typical Hello World: C ~20KB, Go ~2MB
```

Common characteristics:
- A large number of functions containing the `runtime.` prefix
- Contains `go.buildid` section
- Contains `GOROOT`, `GOPATH` path strings
- Number of functions 5000-50000+ (including the entire runtime and standard library)

---

## Core tool chain

### Symbol recovery

| Tools | Purpose | Links |
|------|------|------|
| **GoReSym** | Produced by Mandiant, parses Go symbol information (pclntab/moduledata) | https://github.com/mandiant/GoReSym |
| **GoResolver** | Produced by Volexity, automatically obfuscates Garble binaries using CFG similarity | https://github.com/volexity/GoResolver |
| **redress** | Analyze stripped Go binary, restore type/interface/package structure | https://github.com/goretk/redress |
| **GoStringUngarbler** | Produced by Google, specially designed to recover Garble-obfuscated strings | https://github.com/mandiant/GoStringUngarbler |

### IDA plugin

| Tools | Purpose | Links |
|------|------|------|
| **go_parser** | IDA plug-in, parse moduledata/pclntab/type information | https://github.com/0xjiayu/go_parser |
| **IDAGolangHelper** | IDA script set, parsing Go type information | https://github.com/sibears/IDAGolangHelper |
| **AlphaGolang** | SentinelLabs' IDAPython script set | https://github.com/SentineLabs/AlphaGolang |
| **IDA 9.2+ native support** | Hex-Rays official Go decompilation improvements | https://hex-rays.com/blog/stop-guessing-and-start-going |

### Ghidra plugin

| Tools | Purpose | Links |
|------|------|------|
| **Ghidra + GoReSym output** | Use GoReSym to export symbols and then import them into Ghidra | Use together |
| **golang_loader_assist** | Ghidra Go loading assist | Community script |

### Independent analysis tools

| Tools | Purpose | Links |
|------|------|------|
| **gore** | Go reverse engineering library (underlying redress) | https://github.com/goretk/gore |
| **garble** | Go obfuscation tool (know it to fight it) | https://github.com/burrowers/garble |

---

## Key structures of Go binary

### pclntab (PC Line Table)

The most important structures in the Go binary include:
- All function names and address mappings
- Source file path
- Line number information
- stack frame size

Even if symbols are stripped, pclntab usually still exists (the Go runtime depends on it).

```text
Positioning method:
1. Search for magic bytes: 0xFFFFFFF0 (Go 1.16+) or 0xFFFFFFFB (Go 1.18+)
2. Automatic positioning with GoReSym
3. Automatically parse using go_parser IDA plugin
```

### moduledata

Include:
- pclntab pointer
- Type information table
- itab (interface table)
- Global variable information

### String format

Go strings are not C-style null-terminated, but are `(pointer, length)` structures:

```text
C string: "hello\0"
Go string: struct { ptr *byte; len int } → ptr points to "hello" (no \0)
```

This causes IDA/Ghidra's default string recognition to miss a large number of Go strings.

**Solution**:
- Automatically identify Go strings with `go_parser`
- Export string list using GoReSym
- Manual: find `runtime.stringtable` or locate via cross-reference

---

## Practical workflow

### Scenario 1: Unstriped Go binary

```text
1. GoReSym -t -d -p binary > symbols.json
→ Export all function names, types, and source file paths
2. Load into IDA/Ghidra
3. Import symbol information from GoReSym
4. Filter out runtime.* and standard library functions to focus on user code
5. Start analyzing from main.main
```

### Scenario 2: Go binary after stripping

```text
1. GoReSym -t -d -p binary > symbols.json
→ Even if stripped, pclntab is usually still there
2. If GoReSym fails → use redress
redress -src binary #Restore source file path
redress -pkg binary #Restore package structure
redress -type binary #Restore type information
3. Load into IDA + go_parser plugin
4. Run go_parser to automatically restore
5. Starting from restored main.main
```

### Scenario 3: Garble obfuscated Go binary

```text
Garble will:
- Randomize function names (main.main → main.a3f2b1c)
- encrypted string
- Remove file path information
- Obfuscated package names

Countermeasures:
1. GoResolver (CFG signature matching)
→ Recover standard library function names through control flow graph similarity
2. GoStringUngarbler (string decryption)
→ Automatically identify Garble’s string encryption mode and decrypt it
3. Dynamic analysis (Frida/dlv)
→ Hook runtime function to observe actual behavior
4. Comparative analysis
→ Compile Hello World of the same version of Go, and use binary-diff to compare the runtime part
```

### Scenario 4: CGo hybrid compilation

```text
1. Identify CGo boundaries (_cgo_* functions)
2. The Go part is restored with go_parser
3. Part C analyzed with conventional IDA
4. Pay attention to bridging functions such as _cgo_topofstack and crosscall2
```

---

## Quick check of common commands

```bash
# GoReSym: export symbols
GoReSym -t -d -p binary > symbols.json
GoReSym -t -d -p binary -o ida_script.py  # Generate IDA script

# redress: parsing stripped binaries
redress -src binary          # Source file path
redress -pkg binary          # Package structure
redress -type binary         # type information
redress -interface binary    # Interface information
redress -filepath binary     # full file path

# GoResolver: Deobfuscating Garble
GoResolver -binary binary -output resolved.json

# GoStringUngarbler: Decrypt Garble strings
GoStringUngarbler -i binary -o deobfuscated_binary

# Quickly determine Go version
strings binary | grep "go1\."
GoReSym -p binary | grep "Version"
```

---

## Go analysis process in IDA

```text
1. Load the binary (select the correct architecture)
2. Wait for automatic analysis to complete
3. Run the go_parser plugin:
   - File → Script File → go_parser.py
   - or Edit → Plugins → Go Parser
4. The plugin will automatically:
   - parse pclntab
   - restore function name
   - Tag Go string
   - Parse type information
5. Filter view:
   - Hide runtime.* functions
   - Focus on main.* and third-party packages
6. Start reverse engineering from main.main
```

---

## Common pitfalls

| Trap | Description | Solution |
|------|------|------|
| There are too many functions to see | Go static linking results in 5000-50000 functions | Filter by package name and only see main.* and business packages |
| Incomplete string recognition | Go string is not null-terminated | Restore with go_parser or GoReSym |
| The decompilation result is difficult to read | Go's defer/goroutine/interface makes the pseudocode complex | IDA 9.2+ has improvements, or may be assisted by dynamic analysis |
| Garble obfuscation | Randomize all function names/strings | GoResolver + GoStringUngarbler |
| Version differences | The pclntab format of different Go versions is different | GoReSym supports Go 1.2-1.23+ |
| CGo boundaries | Mixing Go and C code | Identifying _cgo_* functions as dividing lines |

---

## Cooperation with other skills

| Requirements | What to use |
|------|--------|
| IDA in-depth analysis of Go binary | `ida-reverse/` + go_parser plug-in |
| Ghidra Analysis (Free) | Ghidra + GoReSym Symbol Import |
| Quick reconnaissance | `radare2/` — `rabin2 -z` Look at strings |
| Dynamic Hook | Frida (Hook runtime function) or dlv (Go native debugger) |
| Cross-version comparison | `binary-diff/` — Signed migration from old version to new version |
| Garble deobfuscation | GoResolver + GoStringUngarbler |
