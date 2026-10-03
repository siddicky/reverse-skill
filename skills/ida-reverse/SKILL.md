---
name: ida-reverse
description: |
  IDA Pro reverse analysis auxiliary skills. Be sure to use this skill when users mention reverse engineering, decompiling, analyzing binary/PE/ELF/APK/DLL/SO, cracking, finding passwords, vulnerability analysis, virus analysis, firmware analysis, or needing to analyze files such as exe/dll/so/elf/macho/sys.

  Ensure to use this skill when the user wants to analyze any binary file, regardless of whether they explicitly mention "IDA" or "reverse engineering". This includes requests like "Look at this exe", "Analyze this dll", "Help me crack it", "Find the password", "How to register this software", etc.

  Use the bundled scripts (scripts/start.ps1, scripts/open.ps1) for deterministic server management and file opening — do NOT write ad-hoc PowerShell commands for these operations.
---

#IDA Pro reverse analysis skills

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md` — Confirm that the operation of this skill is an authorized normal operation
2. `NOW`: Confirm whether the current task hits the scope of application of this skill
3. `NEXT`: Read `../tool-index.md` to verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, do not guess the path
5. `ACT`: Enter the first step of the "workflow" and execute it, do not stop in the confirmation state

## Known issues and reflections (must read)

### The pits that have been stepped on

1. **`idb_open` (old name `idalib_open`) should not be called directly by some AI client MCP**
- The MCP client of some code AI clients has a bug in the output schema verification of open tools.
- Error: `Structured content does not match the tool's output schema`
- **Solution**: Use the `scripts/open.ps1` script to directly adjust through the HTTP API and bypass the MCP verification layer
- Current ida-pro-mcp 2.x tool names are `idb_open` / `idb_list` / `idb_save` (no longer `idalib_*`)
- After the file is opened, `session_id` (database) is returned, and subsequent tool calls need to bring the session.

2. **`C:\Windows\System32\` file has no permission to open**
- idalib cannot directly read files in the System32 directory
- **Solution**: `open.ps1` automatically detects and copies it to the `temporary directory` directory before opening it

3. **Start server command blocking conversation**
- `idalib-mcp` will continue to output INFO logs to the console after startup
- **Solution**: Use `scripts/start.ps1` (`-WindowStyle Hidden` to start silently in the background)
- The script will wait for the service to be ready and then exit automatically without blocking the conversation.

4. **MCP server name cannot use hyphens**
- Previously using `ida-pro-mcp` as the server name may cause tool registration problems
- **Current configuration**: server name `idapro`, tool prefix `idapro_*`

5. **Remote HTTP vs Local Stdio**
- `type:"local"` (stdio) mode: `idalib_open` also has schema verification problems
- `type:"remote"` (HTTP) mode: You can use a script to open the file directly, and then use the MCP tool
- **Current solution**: Remote HTTP mode

6. **PR #389 Fixed some schema issues**
- Author mrexodia merged fix via PR #389 after issue #388
- Fixed the structuredContent schema in HTTP mode, but there are still problems with AI client-side validation of some codes
- Latest `main` branch version installed

7. **idalib timeout leaves orphan worker process lock file**
- After the first `open.ps1` times out, idalib's python worker child process may become an orphan, biting `.id0`/`.id1`/`.nam`.
- Any subsequent tools or manual dragging into the IDA GUI will report "Insufficient Permissions"
- **Disabled** `taskkill /F /T` kills the process tree - `/T` will kill the GUI `ida.exe` child process together
- **Solution**: `start.ps1` only replaces the managed supervisor when no one is listening on the port, or `tools/list` returns quickly but lacks `py_eval` (old supervisor); RPC times out and 13337 is still listening, it is considered busy and will not be killed. When opening the library, write `opening.lock` in `open.ps1`, and watchdog must not use `-Force`
- **Deadlock exception**: `tools/list` **Continuous failure exceeds 3 minutes** (according to the last-healthy timestamp, not the process creation time), and there is no in-flight `opening.lock`, and the GUI does not occupy the port, only `-Force` replaces the supervisor, and still does not kill `ida.exe`
- **Back to the bottom**: `open.ps1` detects that the old library is locked and automatically copies it to Temp and adds a GUID prefix

8. **When opened with automatic analysis, it looks like it is stuck**
- `idalib_open(run_auto_analysis=true)` may not return packets for a long time, but the backend actually continues to open and analyze
- Previously, what the user saw was "PowerShell has no output", which could easily be misjudged to mean that the script is stuck.
- **Current solution**: `open.ps1` adds `-TimeoutSeconds` and changes it to background request + foreground polling + scheduled progress output
- When polling to find that the session is ready, `OK: file name: session_id` will be returned in advance, and if it times out, `ERR: open_timeout_xxs` will be returned.

9. **HTTP MCP will silently exit after logging in**
- Cursor/Claude's `type: http` will not start the process on its behalf; the old scheduled task only runs once at login
- `pythonw` has no console, and the Application log is empty when it crashes.
- **Solution**: `start.ps1` is reused if it is healthy by default; `watchdog.ps1` is inspected every minute; the log is in `%LOCALAPPDATA%\reverse-skill\ida-mcp\`
- Install: `scripts/install-autostart.ps1`. If the port is not up when the HTTP client is started, you still need to refresh it manually on the MCP panel.

10. **Streamable HTTP GET `/mcp` will jam single-threaded supervisor**
- Some HTTP MCP clients will send long connection GET (SSE) to `/mcp`. stock `idalib_supervisor` uses `HTTPServer` with `background=False` and only handles one request at a time
- Result: `tools/list` times out, client marks `idapro` as error
- **Solution**: `run-supervisor.py` Change HTTP to `ThreadingHTTPServer` and accept GET `/mcp`; if the patch fails, skip and still start supervisor. Use `scripts/recover.ps1` when stuck (immediately `-Force`)

### Workflow principles

| Steps | What to do | What to use |
|------|--------|--------|
| 1 | Make sure the HTTP server is running | `scripts/start.ps1` (no parameters) |
| 2 | Open the target binary file | `scripts/open.ps1 -Path "xxx.exe"` |
| 3 | Using MCP analysis tools | Direct calls to `idapro_*` / HTTP tools (~65, depending on version) |
| 4 | Analysis completed | Tools automatically available |

## Script resources

### start.ps1 — Start the MCP HTTP server

Path: `scripts/start.ps1`

- Automatically resolve `IDADIR` (environment variable/portable desktop path/common installation path)
- Prioritize using IDA’s own `Python314\python.exe -m ida_pro_mcp.idalib_supervisor`
- By default, `http://127.0.0.1:13337/mcp` is detected first. If it is healthy, `OK:<n>:reuse` will be output and exit.
- 13337 Listening but `tools/list` times out → `WARN:busy` / `OK:busy:reuse`, **not kill** (cannot return the package when the library is opened or the GUI is occupied)
- `tools/list` **continuous failure for more than 3 minutes** (last-healthy timestamp) and no `opening.lock` → regarded as deadlock, output `INFO:deadlock` and replace supervisor with `-Force`. The ongoing `idb_open` and GUI will not take this path
- Only replace the managed supervisor when the port is unlistened, missing `py_eval`, or deadlocked above; **Never kill `ida.exe`, no need to use `taskkill /T`**
- When the GUI occupies 13337, it outputs `WARN:gui_busy` and exits without starting a new supervisor.
- Success output `OK:<number of tools>` (currently about 66), failure output `ERR:timeout`
- supervisor log: `%LOCALAPPDATA%\reverse-skill\ida-mcp\supervisor.log`
- The server runs in the background and does not block conversations

**Calling method**:
```
powershell -File "<skill-root>\ida-reverse\scripts\start.ps1"
```

### watchdog.ps1 / recover.ps1 / install-autostart.ps1 — keep alive

- `watchdog.ps1`: detect 13337; health reuse (and refresh last-healthy); GUI / `open.ps1` open library lock / last-healthy is less than 3 minutes busy → reuse; only if `tools/list` fails continuously for more than 3 minutes, `start.ps1 -Force`
- `recover.ps1`: `start.ps1 -Force` immediately (without killing `ida.exe`). This is used when the HTTP client marks `idapro` as error
- `install-autostart.ps1`: Register scheduled task `reverse-skill-ida-mcp` (login + every minute)
- Log: `%LOCALAPPDATA%\reverse-skill\ida-mcp\watchdog.log`

### open.ps1 — Open binary file

Path: `scripts/open.ps1`

- Directly call `idb_open` through HTTP API, bypassing MCP schema verification
- Automatically detect System32 paths and copy to temporary directory
- Automatically clean up old database files with the same name (`.id0`/`.id1`/`.nam`/`.til`/`.i64`)
- Automatically downgrade the old library when it is locked: copy it to Temp and add the GUID prefix and open it without reporting an error
- Place the open request for execution in the background to avoid long synchronization waits causing the script to become unresponsive
- Supports `-TimeoutSeconds`, returns `ERR:open_timeout_xxs` after timeout, and will not get stuck indefinitely
- Output `INFO:opening:elapsed/timeout seconds` every 10 seconds to facilitate judgment that it is still being analyzed
- Successfully output `OK: file name: session_id`, and add `(temp copy)` mark when downgrading
- Automatically retry the Temp copy upon failure

**Calling method**:
```
powershell -File "<skill-root>\ida-reverse\scripts\open.ps1" -Path "C:\path\to\file.exe"
```

**Optional parameters**:
```
# Specify SessionId
powershell -File "scripts\open.ps1" -Path "file.exe" -SessionId "my_session"

# Skip automatic analysis (recommended for large files)
powershell -File "scripts\open.ps1" -Path "large.exe" -NoAutoAnalysis

# Set a timeout to avoid no return for a long time with automatic analysis
powershell -File "scripts\open.ps1" -Path "file.exe" -TimeoutSeconds 600
```

**Output Convention**:
```
# Analysis in progress (output every 10 seconds)
INFO:opening:11/600s

# Open successfully
OK:sample.exe:abcd1234

# Opened successfully, but downgraded to Temp copy due to lock file
OK:1234abcd-sample.exe:abcd1234 (temp copy)

# Timeout limit reached
ERR:open_timeout_600s
```

**Actual measurement instructions**:
- `Snipaste.exe` with automatic analysis actually takes about `324s` to return successfully, which belongs to "analyzing for a long time" rather than "script deadlock"
- Therefore, when encountering GUI programs or more complex samples, it is recommended to explicitly set `-TimeoutSeconds 600` first

## Core tool list

### Overview Analysis (Step 1)
- `idapro_survey_binary(detail_level="minimal")` — Quick overview: number of functions, strings, segments, entry points, import categories (encryption/network/file IO)
- `idapro_list_funcs(queries)` — list functions (paginated, filter by name)
- `idapro_list_globals(queries)` — list global variables
- `idapro_entity_query(kind, filter)` — unified query: functions/globals/imports/strings/names

### Decompilation and disassembly
- `idapro_decompile(addr)` — decompile to pseudocode
- `idapro_disasm(addr, max_instructions=N)` — disassembly
- `idapro_analyze_function(addr, include_asm=false)` — Comprehensive analysis (pseudocode+string+constant+caller+callee+block)
- `idapro_func_profile(queries)` — function profile metrics

### Cross-reference and data flow
- `idapro_xrefs_to(addrs)` — check who refers to the target address
- `idapro_xref_query(addr, direction)` — advanced xref query (direction/type filtering)
- `idapro_callees(addrs)` — list of subfunctions
- `idapro_callgraph(roots, max_depth)` — call graph
- `idapro_trace_data_flow(addr, direction, max_depth)` — data flow tracing (forward/backward)

### search
- `idapro_find_regex(pattern, limit)` — Regular search string
- `idapro_search_text(pattern)` — Search for text in the disassembly list
- `idapro_find_bytes(patterns, limit)` — byte pattern search (supports ?? wildcard)
- `idapro_find(type, targets)` — advanced search (immediate/string/reference)

### Memory and data
- `idapro_get_bytes(addrs)` — read raw bytes
- `idapro_get_string(addrs)` — read string
- `idapro_get_int(queries)` — read integer value
- `idapro_get_global_value(queries)` — Read global variable values
- `idapro_read_struct(queries)` — Read structure field values
- `idapro_search_structs(filter)` — search structure

### Modification operation
- `idapro_set_comments(items)` — add comments (disassembly + decompilation two-way synchronization)
- `idapro_append_comments(items)` — append comments
- `idapro_rename(batch)` — Batch rename (function/global/local/stack variable)
- `idapro_patch_asm(items)` — Patch assembly instructions
- `idapro_patch(patches)` — Patch bytes
- `idapro_define_func(items)` — define functions
- `idapro_undefine(items)` — undefine
- `idapro_define_code(items)` — Convert bytes to code

### Type system
- `idapro_declare_type(decls)` — declare C structure/enumeration/union
- `idapro_set_type(edits)` — apply types to functions/global/local
- `idapro_infer_types(addrs)` — inferred types
- `idapro_type_query(queries)` — Query declared types
- `idapro_type_inspect(queries)` — View type details

### Stack frame
- `idapro_stack_frame(addrs)` — View stack frame variables
- `idapro_declare_stack(items)` — declare stack variables
- `idapro_delete_stack(items)` — delete stack variables

### sign
- `idapro_make_signature(addrs)` — generate a unique byte signature for an address
- `idapro_make_signature_for_function(addrs)` — generate signature for function
- `idapro_find_xref_signatures(addrs)` — Generate signatures for code referencing addresses

### Debugger (requires ?ext=dbg)
- `idapro_open_file(file_path)` — Open a file in a GUI IDA instance
- The debugger tool is hidden by default and can be enabled via the URL parameter `?ext=dbg`

### Session management (ida-pro-mcp 2.x)
- `idapro_idb_open` / HTTP `idb_open` — ⚠️ It is recommended to use `open.ps1` to open
- `idapro_idb_list` / HTTP `idb_list` — list all sessions
- `idapro_idb_save` / HTTP `idb_save` — save database
- Most analysis tools require the `database=<session_id>` parameter (session output by open.ps1)

### other
- `idapro_int_convert(inputs)` — base conversion (**You must use this, don’t calculate the base yourself!**)
- `idapro_export_funcs(addrs, format)` — export functions (json/c_header/prototypes)
- `idapro_py_eval(code)` — Execute Python in the context of IDA
- `idapro_server_health()` — Server health check
- `idapro_server_warmup()` — Warm up subsystems (string cache, Hex-Rays, etc.)

## Complete reverse analysis workflow

### Step 1: Start the server

**Path A — Headless idalib (requires valid license)**
```
powershell -File "scripts/start.ps1"
```
Output `OK:<number of tools>` (currently about 65) indicates readiness.

**Path B — GUI + plug-in (when idalib license fails or interactive analysis is required)**
```
powershell -File "scripts/start-gui.ps1" -Path "C:\target.exe"
```
Or double-click the portable version `Launch-IDA-Pro.cmd` to open the sample in IDA.

After confirming that `[MCP] ... port=13337` appears in the Output window, the MCP tool is available.

See `LOCAL-SETUP.md` for general docking steps.

### Step 2: Open the file

Headless：
```
powershell -File "scripts/open.ps1" -Path "C:\target.exe" -TimeoutSeconds 600
```
Output `OK:filename:session_id` to indicate success (followed by `(temp copy)` to automatically downgrade to a temporary copy).

If `ERR:idalib_license:...` appears, use path B (GUI mode) instead, and do not retry open.ps1 repeatedly.

GUI mode: Just open the sample directly in IDA without open.ps1.

### Step 3: Global overview (including import table hardware)
```
idapro_survey_binary(detail_level="minimal")
```
focus on:
- Architecture (x86/x64/ARM)
- Entry point (main/WinMain/DllMain)
- Interesting strings (URLs, paths, error messages)
- **Import Category (MUST)**: Cryptofunction / Network API / File Operation / Process Injection / Registry - Must be implemented Evidence (recommended id: `E-imports`), available `idapro_entity_query(kind="imports")` or the imports section in the survey output
- **DLL/SYS**: Export table and import table are juxtaposed (Evidence `E-exports`)
- **.NET**: Use module/metadata/managed reference digests as equivalence anchors when writing E-imports semantic slots without traditional IAT
- **Clean Import Table**: Indicate dynamic loading suspicions and promote dynamic API breakpoint verification
- Popular functions (functions with high xref count are usually critical logic)

**Hard access control**: Before writing the imports view/classification summary (or legal equivalent anchor) to Evidence, MUST NOT enter Step 4 to dig into the conclusion, and MUST NOT claim that the survey is completed. The failure MUST be recorded even when the import table is empty or the query fails. When the packed IAT repair fails, MUST remember `E-iat-repair-fail` and switch to dynamic debugging to capture the API, and static crashing is prohibited. When the user requests to redo the import table/IAT check, the named step MUST be redone (feasibility latch when blocked: description + confirmation; if mandatory, mark quality=unreadable), and it is forbidden to change irrelevant steps.

### Step 4: Go deep into key functions
```
idapro_analyze_function(addr="Key function name")
```
or:
```
idapro_decompile(addr="function name")
idapro_disasm(addr="function name", max_instructions=50)
```

### Step 5: Data flow and cross-reference
```
idapro_xrefs_to(addrs="Key address/string")
idapro_callgraph(roots=["key function"], max_depth=3)
idapro_trace_data_flow(addr="key address", direction="backward", max_depth=5)
```

### Step 6: Record and optimize
```
idapro_set_comments(items=[{"addr": "0x140001000", "comment": "your understanding"}])
idapro_rename(batch={"func": [{"addr": "function address", "name": "meaningful name"}]})
```

### Step 7: Output report
After the analysis is completed, generate `report.md` to record the findings and steps.

## Prompt Engineering Guidelines

1. **Don’t do base math manually** — any time you need to convert a number, use `idapro_int_convert`
2. **Survey first and then delve deeper** — first look at the overview and then analyze in a targeted manner
3. **Continuous annotation and renaming** — Continuously update function names and variable names during the analysis process to improve the accuracy of subsequent analysis
4. **Track cross-references** — Find interesting data/strings and use `xrefs_to` to see who has cited it
5. **Encountering obfuscated code** — First perform preprocessing such as string decryption, import hash removal, and control flow flattening removal.
6. **C++ STL code** — Use FLIRT/Lumina to identify library functions and then analyze the business logic
7. **Don’t brute force** — Analysis should deduce solutions from disassembly, using simple Python to assist calculations
8. **Encountered "No database bound"** - No binary file has been opened yet, execute `open.ps1` first
9. **Encountered "Failed to open database"** - The old database file may be locked, `open.ps1` will automatically downgrade to the Temp copy (the output contains the `(temp copy)` mark)
10. **When opening GUI/complex samples with automatic analysis** - Add `-TimeoutSeconds 600` by default, do not misjudge long `INFO:opening:...` as script stuck

---

## Routing context

**Upstream entrance**: `skills/SKILL.md` (master control), `routing.md`
**Upstream alternative**: `radare2/` (if you don’t want to open IDA, you can quickly scout with r2 first)
**Downstream Export**:
- Requires Frida dynamic verification → `reverse-engineering/tools-dynamic.md`
- Requires symbolic execution/angr → `reverse-engineering/tools-dynamic.md`
- Requires general reverse methodology → `reverse-engineering/SKILL.md`

**Sibling association module**: `radare2/` (alternative when IDA is not available)

---

##On-Demand Bootstrap

The entry script of this skill has been connected to the unified bootstrapping system.

### Automation capability boundary

| Tools | Automatic installation | Installation method | Instructions |
|------|-----------|---------|------|
| idalib-mcp | ✓ | pip install (from GitHub) | Automatically install if `start.ps1` is missing |
| IDA Pro body | ✗ | Commercial software, manual installation required | Set the `IDADIR` environment variable to point to the installation directory |

### Installation steps (verified)

```cmd
# 1. Set the IDA path (replace with your actual IDA installation directory)
setx IDADIR "<Your IDA installation directory>"

# 2. Install ida-pro-mcp from GitHub (ida-mcp on PyPI is another project, don’t install it wrong!)
pip install git+https://github.com/mrexodia/ida-pro-mcp.git

# 3. Install the IDA plug-in (select Streamable HTTP + Global + select all clients)
ida-pro-mcp --install

# 4. Restart IDA Pro and open the target file
# The plug-in automatically monitors 127.0.0.1:13337

# 5. Verification
ida-pro-mcp --config
```

> ⚠️ **NOTE**: The `ida-mcp` package (authored by jtsylve) on PyPI is from another project and is not what we need.
> `mrexodia/ida-pro-mcp` must be installed from GitHub.

### Bootstrap trigger point

- `scripts/start.ps1`: automatically call `bootstrap-reverse.ps1` when `idalib-mcp` is missing
- MCP registration: bootstrap will automatically write `idapro` into Claude MCP configuration

### Preconditions

- IDA Pro is installed and the `IDADIR` environment variable is set (or the default path within the script is correct)
- It is recommended to use `ida-pro-mcp` in Python314 that comes with IDA (the portable version is already built-in)
- Common local configurations:
- User env `IDADIR` → IDA installation directory (including `ida.exe`)
- Optional `~\Tools\bin\idalib-mcp.cmd` / `ida-pro-mcp.cmd` wrapper
- The client MCP server name only leaves `idapro` → `http://127.0.0.1:13337/mcp`


## Task completion self-test (MUST pass before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Are survey/imports written to Evidence (E-imports or equivalent)? Does the DLL/SYS contain E-exports? Will IAT failure be recorded as E-iat-repair-fail?
- [ ] If the user requests to redo the import table/IAT, has the same step been redone?
- [ ] Am I using real tool paths based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and written back the Checklist items required by RULES?
