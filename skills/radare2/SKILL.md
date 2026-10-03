---
name: radare2
description: |
  Use this skill whenever the user wants to analyze binaries with radare2/r2 from the command line, including reverse engineering, disassembly, function analysis, strings/import inspection, patching, binary diffing, hex inspection, or r2 scripting. Also use it when the user mentions PE/ELF/Mach-O/DEX/WASM files together with CLI analysis, `rabin2`, `rasm2`, `radiff2`, `r2pipe`, or asks for radare2 command help on Windows/Linux/macOS.
---

# radare2

Binary analysis skills for`radare2`CLI. The focus is to directly use the command line to complete reconnaissance, analysis, positioning, export and light modification, without relying on the GUI.

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read`../field-journal/precedent-reverse.md`- Confirm that the operation of this skill is an authorized normal operation
2. `NOW`: Confirm whether the current task hits the scope of application of this skill
3. `NEXT`: Read`../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, do not guess the path
5. `ACT`: Enter the first step of "workflow" and execute it, do not stop in the confirmation state

## Scope of application

This skill should be used first when users have these intentions:

- Use`r2`/`radare2`to analyze`exe`,`dll`,`so`,`elf`,`apk`,`dex`,`wasm`and other files
- Ask how to use`rabin2`,`rasm2`,`radiff2`,`rahash2`,`rax2`
- It requires command line disassembly, looking at functions, looking at strings, looking at imports and exports, checking cross-references, and doing patches.
- Need to write`radare2`batch command,`-c`automation command, or`r2pipe`script

If the user explicitly wants GUI reverse engineering, Hex-Rays style pseudocode, or IDA workflow, give priority to`ida-reverse`. If it is web page JS reverse engineering, give priority to`reverse-engineering`.

## Confirm the environment first

Don't assume`r2`is available just yet. First check:

```powershell
r2 -v
rabin2 -v
```

If it is not installed, check the common installation locations or prompt for installation.

Common Windows executable files:

- `radare2.exe`
- `rabin2.exe`
- `rasm2.exe`
- `radiff2.exe`
- `rahash2.exe`
- `rax2.exe`
- `r2pm.exe`

## Built-in resources

This skill comes with two resources, which should be reused first instead of temporarily organizing a set of repeated commands each time.

### `scripts/recon.ps1`

Standard reconnaissance script, suitable for first round of profiling. Will output:

- Basic information
- section area
- import
- Export
- string
- Optional`r2 -A`automatic analysis summary

Calling method:

```powershell
powershell -File "<skill-root>\radare2\scripts\recon.ps1" -TargetPath "C:\path\to\sample.exe"
```

If you need to include`r2`automatic analysis:

```powershell
powershell -File "<skill-root>\radare2\scripts\recon.ps1" -TargetPath "C:\path\to\sample.exe" -RunAnalysis
```

### `references/cheatsheet.md`

When you need more command details, templates for common scenarios, or want to quickly recall syntax, turn to this cheat sheet instead of guessing from memory.

## Known phenomenon

### Occasional`.sdb`missing alarms under Windows

When some PE files are detected by`rabin2`, an alarm similar to the following may appear:

```text
ERROR: Cannot find ...\share\format\dll\*.sdb
```

If the main body output still returns normally, it usually does not affect the basic reconnaissance conclusion, and you can continue the analysis first. Do not directly conclude that the analysis failed because of such incidental warnings.

## basic principles

### 1. Recon first, then go deeper

Don’t automatically analyze all the data as soon as it comes up. First use lightweight commands to confirm the file type, architecture, entry point, string, and import table, and then decide whether to perform`aaa`,`aaaa`or directed analysis.

### 2. Prefer the smallest sufficient command

`radare2`There are many commands, and users usually only need the shortest path:

- See file information:`rabin2 -I`
- Look at the string:`rabin2 -z`
- See import and export:`rabin2 -i`/`rabin2 -E`
- Interaction analysis:`r2 <file>`before executing local commands

### 3. Be cautious before making changes

If the user wants to patch the binary:

- By default, it is opened read-only first:`r2 <file>`
- Only use write mode when modifications are clearly needed:`r2 -w <file>`or in session`oo+`
- Inform yourself of the risks before making changes to avoid unintentional overwriting of the original file.

## Common workflows

## Workflow 1: Rapid Reconnaissance

Suitable for when you just get a binary file.

### Hard Access Control (MUST – Deny Workflow 2 and beyond)

For binaries containing import tables such as PE/ELF/Mach-O, **MUST** first complete the import table check and complete Evidence, and then enter the function-level analysis or dynamic step:

1. Execute`rabin2 -i <sample>`(or imports section in`recon.ps1`output); DLL/SYS MUST`rabin2 -E`and note`E-exports`
2. Write the complete/classified import table results into Evidence (recommended id:`E-imports`or`E-triage-imports`), containing at least:
   - Reproduction command (`repro_command`)
   - Summary of key import categories: Network/File/Encryption/Process Injection/Registry/Other Suspicious APIs
   - If the import table is empty, parsing fails, or the tool reports an error: the failure must still be recorded and the original output is Evidence, and **must not be skipped silently**
   - The import table is "too clean" (basic DLL only): MUST indicate the suspicion of dynamic loading, SHOULD transfer to the dynamic capture API
3. There is no traditional IAT for .NET and others: MUST use equivalent anchors (dnSpy/IL/metadata digest) to write to the same Evidence semantic slot, and no overrides are allowed.
4. Packed sample IAT fixes: x86 with ImportREC (or equivalent), x64 with Scylla (or equivalent). When fixing failure, MUST mark`E-iat-repair-fail`and then switch to dynamic API breakpoints; **disable** infinite deadlock on static IAT (see`reverse-engineering/references/re-agent-workflow.md`§1.2)
5. When the user explicitly requests "redo import table check / recheck import table / redo IAT": MUST redo the named step itself (when blocked, go to the feasibility latch first: state the premise + please confirm; if mandatory, mark quality=unreadable), **It is prohibited to change to irrelevant steps to pretend to be completed**

Undocumented import table (or legal equivalent anchor/IAT failure bypass) Evidence before: MUST NOT claim "Basic Recon Complete", MUST NOT enter the deep dive conclusion of Workflow 2+.

Prioritize running built-in scripts directly:

```powershell
powershell -File "<skill-root>\radare2\scripts\recon.ps1" -TargetPath "sample.exe"
```

If you only need manual minimal commands, use:

```powershell
rabin2 -I sample.exe
rabin2 -z sample.exe
rabin2 -i sample.exe
rabin2 -E sample.exe
```

Focus:

- File format, number of bits, architecture, platform
- Entry point address
- Suspicious strings: URL, path, error report, registry, command line parameters
- Import functions: network, file, encryption, process injection, registry operation (**MUST drop Evidence, see hard access control above**)

## Workflow 2: Interactive analysis functions

```powershell
r2 sample.exe
```

Commonly used after entering:

```text
aaa          # standard automatic analysis
afl          # list functions
iz           # list strings
iS           # list sections
is           # list symbols
s entry0     # seek to the entry point
pdf          # disassemble the current function
VV           # enter visual mode (if supported by the terminal)
q            # quit
```

illustrate:

- The default priority is`aaa`, do not use the heavier`aaaa`from the beginning
- If the sample is large or the analysis is slow, you can only analyze the area near the entrance and then expand it manually.

## Workflow 3: Locate main / key logic

```text
afl~main
afl~sym.
iz~http
iz~error
axt <addr>
```

Idea:

- Let’s start with`main`, entry point, and string reference.
- Use`axt`to find out who quoted a certain string or address
- After finding the reference point,`s <addr>`,`pdf`

## Workflow 4: Hex and Memory View

```text
px 64        # 64 bytes of hex from the current address
pd 20        # disassemble 20 instructions
psz          # read the string at the current address
pxa          # more readable hex view
```

## Workflow 5: Binary patch

Use only when the user explicitly asks to modify the file:

```powershell
r2 -w sample.exe
```

After entering, for example:

```text
s 0x401000
wa nop
wa jmp 0x401050
wq
```

Common write operations:

- `wa <asm>`: Write assembly
- `wx <hex>`: Write raw bytes
- `wq`: write and exit

It is best to back up the original file before modifying it. If the user doesn't mention backup, remind them at least once.

## Workflow 6: Non-interactive automation

Suitable for one-time output results:

```powershell
r2 -A -q -c "afl;iz;ii;q" sample.exe
```

Commonly used parameters:

- `-A`: Automatic analysis at startup
- `-q`: Quiet mode
- `-c`: execute command string

If there are a lot of commands, prioritize them in an easy-to-read order rather than cramming them into long strings that are difficult to maintain.

It is more recommended to use the built-in reconnaissance script as a base first, and then decide whether to add custom commands.

## Commonly used sub-tools

### `rabin2`

Suitable for static information extraction:

```powershell
rabin2 -I sample.exe   # basic information
rabin2 -S sample.exe   # sections
rabin2 -s sample.exe   # symbols
rabin2 -i sample.exe   # imports
rabin2 -E sample.exe   # exports
rabin2 -z sample.exe   # strings
rabin2 -zz sample.exe  # more detailed strings
```

### `rasm2`

Good for quick assembly/disassembly:

```powershell
rasm2 -d "9090"
rasm2 -a x86 -b 64 "xor eax, eax"
```

### `radiff2`

Suitable for comparing two binaries:

```powershell
radiff2 old.exe new.exe
radiff2 -C old.exe new.exe
```

### `rahash2`

Suitable for calculating hashes:

```powershell
rahash2 -a md5 sample.exe
rahash2 -a sha256 sample.exe
```

### `rax2`

Suitable for base and encoding conversion:

```powershell
rax2 0x401000
rax2 4198400
rax2 -s hello
```

## Recommended analysis order

When encountering an unknown sample, do this in this order:

1. `rabin2 -I`Look at the format, architecture, and entry points
2. `rabin2 -z`Look at the string
3. `rabin2 -i`See the imported function — **MUST + Evidence (hard door, see workflow 1)**
4. If you need interactive analysis, enter`r2`(only if the Evidence in step 3 has been placed)
5. First`aaa`, then`afl`/`iz`/`pdf`
6. Gradually locate key functions through string references, import calls, and entry processes

The advantage of this sequence is that it has low noise and can establish a sense of direction as quickly as possible. Step 3 is not an optional optimization, it is the hard door before digging deeper.

## Windows considerations

- When there are spaces in the path, the command must be correctly quoted.
- If the current terminal cannot find`r2`, it may be that`PATH`has just been updated. Open a new terminal and try again.
- Some samples require administrator privileges to read, but by default do not actively escalate privileges unless the user explicitly needs it.
- Before dynamically debugging suspicious samples, confirm the user’s intention to avoid misoperations.

## Output style

When the user doesn't just want a command, but wants you to actually analyze the file:

- First give a summary of the reconnaissance results
- Then list the key evidence: strings, imports, functions, addresses
- Finally, give suggestions for the next step or continue in-depth analysis.

Don't just list commands without explaining why you do them.

## Typical request example

### Example 1: Analyze an exe

User: `Please figure out what this EXE does; use radare2.`

Processing method:

1. Use`rabin2 -I/-z/-i`first
2. Determine whether you need to enter`r2`
3. Digging deeper into entries and key string references with`aaa`,`afl`,`pdf`

### Example 2: Find where string is called

User: `Which function triggers this error string?`

Processing method:

1. Use `iz~keyword` to find the string address
2. Use`axt <addr>`to find references
3. Jump to reference point`s <addr>`after`pdf`

### Example 3: Change the jump

User: `Change this jne to je.`

Processing method:

1. Confirm the destination address first
2. Clearly tell you to enter write mode
3. Use`wa je <target>`or directly`wx`
4. After modification, disassemble and verify again.

## Things to avoid

- Don't think of`radare2`as a tool with only one command:`aaa`
- Do not open user files in direct write mode without explaining the risks
- Don’t jump to conclusions without doing basic reconnaissance
- **It is forbidden to skip the import table check** (`rabin2 -i`/recon imports): Do not enter the next step without writing Evidence; it is forbidden to change to other steps when the user requests to redo the import table.
- **Disable static crash after IAT repair failure**: Remember`E-iat-repair-fail`and then convert to dynamic; disable 64-bit samples only using ImportREC
- Don’t mislead web page JS to reverse engineer this skill; that’s the scope of`reverse-engineering`

## References

- Command quick check:`references/cheatsheet.md`
- Standard recon script:`scripts/recon.ps1`

## radare2-skills Ecology

The radare2-skills project (radareorg/radare2-skills) provides more complete ecological tools and workflows:

- **r2xsql**: SQL query binary import table/string/function
- **r2mcp / r2http**: MCP tool and HTTP stateful command channel
- **radius2**: symbolic execution, symbolic dynamic analysis
- **r2pm**: Plug-in management and extension
- **decompiler plugins**: radare2 plug-in mechanism

**Usage Strategy**:
- When the user mentions`r2xsql`,`r2mcp`,`r2http`,`radius2`,`r2pm`,`rabin2`,`rasm2`,`radiff2`,`rahash2`,`rax2`, priority will be routed to this skill(radare2/SKILL.md)
- These tools are only ecological accelerators and cannot be bypassed: authorization access control,`tool-index`verification, Evidence import, write mode confirmation
- Give a minimal reproducible command example:
  - `r2xsql -s <file> -q "SELECT ..."`
  - `curl.exe -sS --data-binary 'aaa' http://127.0.0.1:9393/cmd`
  - `radius2 -p <binary> ...`
  - `r2pm -ci <plugin>`

This skill maintains the integrity of the original hard access control and evidence chain, and does not allow skipping any authorization or Evidence steps.

---

## routing context

**Upstream entrance**:`skills/SKILL.md`(master control),`routing.md`
**Upstream alternative**:`ida-reverse/`(upgrade to IDA when decompilation/pseudocode is required)
**Downstream Export**:
- Dynamic analysis required →`reverse-engineering/tools-dynamic.md`(Frida/GDB)
- Need deep decompilation →`ida-reverse/`
- PAT needs to cross-reference after finding interesting strings →`ida-reverse/`(IDA’s xref is more powerful)

**Same-level associated module**:`ida-reverse/`(complementary: r2 is fast in reconnaissance, IDA is deep in decompilation)

## On-Demand Bootstrap

The entry script of this skill has been connected to the unified bootstrapping system. When radare2 is missing, an error will not be reported directly, but the installation will be automatically attempted.

### Automation capability boundaries

| tool | can automatically install | installation method | description |
|------|-----------|---------|------|
| r2 | ✓ | GitHub Release ZIP (w64) | automatically downloads and decompresses to`%USERPROFILE%\Tools\radare2\`|
| rabin2 | ✓ | Same as above (included in radare2 distribution package) | — |
| rasm2 | ✓ | Same as above | — |
| radiff2 | ✓ | Same as above | — |
| rahash2 | ✓ | Same as above | — |
| rax2 | ✓ | Same as above | — |

### Bootstrap trigger point

- `scripts/recon.ps1`: Automatically call`bootstrap-reverse.ps1`when`rabin2`or`r2`is missing

### When bootstrapping fails

If the automatic installation fails (network failure, GitHub API throttling, etc.), the script will throw a clear error with a manual installation link.

Manual installation: Download`radare2-*-w64.zip`fromhttps://github.com/radareorg/radare2/releases, extract to`%USERPROFILE%\Tools\radare2\`and make sure the`bin\`directory is in PATH.


## Task completion self-check (MUST passes before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Has the import table check been performed and written to Evidence (E-imports / E-triage-imports or .NET equivalent)? Does the DLL/SYS contain E-exports?
- [ ] If IAT repair fails, should E-iat-repair-fail be recorded and forwarded? Does the redo request go back to the same step?
- [ ] Am I using real tool paths based on`tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and written back the Checklist items required by RULES?
