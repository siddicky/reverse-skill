# IDA Pro MCP Tool Quick Check

> ida-pro-mcp 2.x tools are classified by function, with common parameters and typical usage.
> server name: `idapro`, tool prefix: `idapro_*`, running in HTTP mode. The number of tools varies with version (about 66, including `py_eval`).

---

## Startup and Session Management

### server starts

```powershell
# Start MCP HTTP server (silent in the background; OK:<n>:reuse when healthy)
powershell -File "scripts/start.ps1"
# output OK:<number of tools> indicates ready (about 66, including py_eval)

# opens the target file (bypassing schema verification)
powershell -File "scripts/open.ps1" -Path "C:\target.exe"
# output OK:filename:session_id

# Large file/GUI program is recommended to add timeout
powershell -File "scripts/open.ps1" -Path "C:\big.exe" -TimeoutSeconds 600

# Skip automatic analysis (quick opening)
powershell -File "scripts/open.ps1" -Path "C:\huge.sys" -NoAutoAnalysis
```

### Conversation tool

| Tool | Purpose | Example |
|------|------|------|
| `idapro_idb_list()` / HTTP `idb_list` | List all sessions | — |
| `idapro_idb_open()` / HTTP `idb_open` | Open the database (`open.ps1` is preferred) | Run script for large files |
| `idapro_idb_save(path)` / HTTP `idb_save` | Save database | Save analysis progress |
| `idapro_idb_current()` | The currently bound session (if provided by the version) | — |
| `idapro_idb_switch(session_id)` | Switch session | When comparing multiple files |
| `idapro_idb_close(session_id)` | Close session | Release resources |
| `idapro_server_health()` | Server health check | — |
| `idapro_server_warmup()` | Preheating subsystem | Before first use |

---

## Step One: Global Overview

### survey_binary — Quick overview of

```
idapro_survey_binary(detail_level="minimal")
```

 returns:
- architecture (x86/x64/ARM/MIPS)
- entry point
- Total number of functions
- string statistics
- segment information
- import classification (encryption/network/file IO/registry)
- high xref popular function

**detail_level option**:
- `"minimal"` — Quick overview (recommended first choice)
- `"standard"` — contains more details
- `"full"` — Complete information

### function list

```
# List all functions (paginated)
idapro_list_funcs(queries=[{"offset": 0, "limit": 50}])

# Filter  by name
idapro_list_funcs(queries=[{"filter": "crypt", "offset": 0, "limit": 20}])
idapro_list_funcs(queries=[{"filter": "main", "offset": 0, "limit": 10}])
```

### unified query

```
# query import function
idapro_entity_query(kind="imports", filter="Create")

# query string
idapro_entity_query(kind="strings", filter="http")

# queries all named symbols
idapro_entity_query(kind="names", filter="")
```

---

## Decompile and disassemble

### decompilation (pseudocode)

```
# by function name
idapro_decompile(addr="main")
idapro_decompile(addr="sub_140001000")

# by address
idapro_decompile(addr="0x140001000")
```

### disassembles

```
# Default instruction number
idapro_disasm(addr="main")

# specifies the number of instructions
idapro_disasm(addr="0x401000", max_instructions=100)
```

### comprehensive analysis (recommended)

```
# gets one-time: pseudocode + string + constant + caller + callee + basic block
idapro_analyze_function(addr="main", include_asm=false)

# contains assembly
idapro_analyze_function(addr="sub_401000", include_asm=true)
```

### function summary

```
# Batch acquisition of function indicators (size, number of blocks, number of xrefs)
idapro_func_profile(queries=["main", "sub_401000", "sub_402000"])
```

---

## cross-reference and call graph

### who referenced the target

```
# Check who called a certain function
idapro_xrefs_to(addrs=["sub_401000"])

# Check who quoted a certain string/data
idapro_xrefs_to(addrs=["0x404000"])

# batch query
idapro_xrefs_to(addrs=["CreateFileW", "ReadFile", "WriteFile"])
```

### Advanced xref Query

```
# specifies direction and type
idapro_xref_query(addr="0x401000", direction="to")    # who quotes me
idapro_xref_query(addr="0x401000", direction="from")  # Who do I quote?
```

### Called function list

```
idapro_callees(addrs=["main"])
```

### call graph

```
# starts from main, depth 3
idapro_callgraph(roots=["main"], max_depth=3)

# Multiple starting points
idapro_callgraph(roots=["sub_401000", "sub_402000"], max_depth=2)
```

### data flow tracking

```
# trace backward: where does this value come from
idapro_trace_data_flow(addr="0x401050", direction="backward", max_depth=5)

# trace forward: where does this value flow
idapro_trace_data_flow(addr="0x401050", direction="forward", max_depth=5)
```

---

## Search

### string search (regular)

```
# Search URL
idapro_find_regex(pattern="https?://", limit=20)

# search file path
idapro_find_regex(pattern="C:\\\\", limit=20)

# Search error message
idapro_find_regex(pattern="error|fail|invalid", limit=30)

# Search key/password related
idapro_find_regex(pattern="key|password|secret|token", limit=20)
```

### disassembly text search

```
# searches for  in the disassembly list
idapro_search_text(pattern="call    sub_")
idapro_search_text(pattern="xor     eax, eax")
```

### byte pattern search

```
# exact bytes
idapro_find_bytes(patterns=["48 8B 05"], limit=10)

# with wildcard
idapro_find_bytes(patterns=["48 89 ?? 24 ??"], limit=10)

# Multiple modes
idapro_find_bytes(patterns=["CC CC CC CC", "90 90 90 90"], limit=5)
```

### Advanced Search

```
# searches for immediate data
idapro_find(type="immediate", targets=["0xDEADBEEF"])

# search string reference
idapro_find(type="string", targets=["password"])
```

---

## memory and data reading

### read raw bytes

```
idapro_get_bytes(addrs=[{"addr": "0x401000", "size": 64}])
```

### read string

```
idapro_get_string(addrs=["0x404000", "0x404100"])
```

### read integer

```
idapro_get_int(queries=[{"addr": "0x405000", "size": 4}])
```

### reads global variable

```
idapro_get_global_value(queries=["g_flag", "g_key_size"])
```

### reads structure

```
idapro_read_struct(queries=[{"addr": "0x405000", "type": "HEADER"}])
```

### search structure

```
idapro_search_structs(filter="FILE")
```

---

## modification operation

### Add comment

```
# Single comment
idapro_set_comments(items=[{"addr": "0x401000", "comment": "Decryption function entry"}])

# batch annotation
idapro_set_comments(items=[
    {"addr": "0x401000", "comment": "XOR decryption loop"},
    {"addr": "0x401050", "comment": "Key initialization"},
    {"addr": "0x4010A0", "comment": "Result verification"}
])

# Add comments (do not overwrite existing ones)
idapro_append_comments(items=[{"addr": "0x401000", "comment": "Additional note: key length 16"}])
```

### renames

```
# renames function
idapro_rename(batch={"func": [
    {"addr": "sub_401000", "name": "decrypt_payload"},
    {"addr": "sub_402000", "name": "verify_license"}
]})

# renames global variable
idapro_rename(batch={"global": [
    {"addr": "0x405000", "name": "g_encryption_key"}
]})

# renames local variable
idapro_rename(batch={"local": [
    {"func": "decrypt_payload", "old": "v1", "name": "plaintext_buf"}
]})
```

### Patch assembly

```
# NOP drops the detection code
idapro_patch_asm(items=[{"addr": "0x401050", "asm": "nop"}])

# modify jump
idapro_patch_asm(items=[{"addr": "0x401060", "asm": "jmp 0x401080"}])

# forces the return of true
idapro_patch_asm(items=[
    {"addr": "0x401000", "asm": "mov eax, 1"},
    {"addr": "0x401005", "asm": "ret"}
])
```

### Patch byte

```
# directly writes bytes
idapro_patch(patches=[{"addr": "0x401050", "bytes": "9090909090"}])
```

---

## type system

### declares structure

```
idapro_declare_type(decls=[{
    "name": "PacketHeader",
    "decl": "struct PacketHeader { uint32_t magic; uint16_t type; uint16_t length; uint8_t data[0]; };"
}])
```

### Application Type

```
# sets the prototype  for the function
idapro_set_type(edits=[{
    "addr": "sub_401000",
    "type": "int __fastcall decrypt(void *buf, int size, const char *key)"
}])

# sets the type  to the global variable
idapro_set_type(edits=[{
    "addr": "0x405000",
    "type": "PacketHeader"
}])
```

### inferred type

```
idapro_infer_types(addrs=["sub_401000", "sub_402000"])
```

### query/view type

```
idapro_type_query(queries=["Packet"])
idapro_type_inspect(queries=["PacketHeader"])
```

---

## stack frame analysis

```
# View function stack frame
idapro_stack_frame(addrs=["main", "sub_401000"])

# declares stack variable
idapro_declare_stack(items=[{
    "func": "sub_401000",
    "offset": -0x20,
    "name": "local_buf",
    "type": "char [32]"
}])
```

---

## signature generation

```
# generates unique byte signature  for address
idapro_make_signature(addrs=["0x401000"])

# generates signature  for the entire function
idapro_make_signature_for_function(addrs=["decrypt_payload"])

# generates signature  for code referencing an address
idapro_find_xref_signatures(addrs=["0x405000"])
```

---

## hexadecimal conversion

```
# hex → decimal
idapro_int_convert(inputs=["0x401000"])

# decimal → hex
idapro_int_convert(inputs=["4198400"])

# batch conversion
idapro_int_convert(inputs=["0xDEAD", "0xBEEF", "12345"])
```

> ⚠️**Always use this tool for base conversion, don’t do the math yourself!**

---

## export with script

### exports function

```
# JSON format
idapro_export_funcs(addrs=["main", "sub_401000"], format="json")

# C header file
idapro_export_funcs(addrs=["main", "sub_401000"], format="c_header")

# function prototype
idapro_export_funcs(addrs=["main", "sub_401000"], format="prototypes")
```

### executes the Python script

```
# executes Python in the IDA context
idapro_py_eval(code="import idautils; print(list(idautils.Functions())[:10])")

# gets segment information
idapro_py_eval(code="import idc; print(idc.get_segm_name(0x401000))")

# batch operation
idapro_py_eval(code="import ida_funcs; f=ida_funcs.get_func(0x401000); print(f.size())")
```

---

## Typical analysis process

### malware analysis

```text
1. survey_binary → see import (network API? encryption? registry?)
2. find_regex("http|socket|connect") → find network-related strings
3. xrefs_to(network string address) → find referenced functions
4. decompile(referenced function) → inspect communication logic
5. trace_data_flow(encrypted parameter, "backward") → trace key origin
6. set_comments + rename → mark discovery
```

### registration verification crack

```text
1. find_regex("serial|license|register|valid") → find verification-related strings
2. xrefs_to(verification string) → locate the verification function
3. analyze_function(verification function) → understand the logic
4. callgraph(verification function, 2) → inspect the call chain
5. patch_asm(conditional jump address, "jmp always_pass") → patch
```

### CTF reverse

```text
1. survey_binary → Confirm structure and entry
2. decompile("main") → inspect the main logic
3. find_regex("flag|correct|wrong") → find the decision point
4. trace_data_flow(decision point, "backward") → trace input transformation
5. use Python to assist with calculation/decryption → obtain the flag
```

### Vulnerability Analysis

```text
1. entity_query(kind="imports", filter="strcpy|sprintf|gets") → find dangerous functions
2. xrefs_to(dangerous function) → find call sites
3. analyze_function(function containing the call site) → inspect context
4. stack_frame(function) → confirm the buffer size
5. trace_data_flow(dangerous parameter, "backward") → confirm user controllability
```

---

## Common errors and solutions

| Error | Cause | Solution |
|------|------|------|
| "No database bound" | does not open the file | executes `open.ps1` |
| "Failed to open database" | The old database is locked | `open.ps1` automatically downgrades to Temp |
| schema verification failed | MCP client BUG | Use `open.ps1` instead of `idb_open` |
| tool timeout | Large file analysis | plus `-TimeoutSeconds 600` |
| "ERR:timeout" (start.ps1) | Server startup failed | Check Python/idalib-mcp installation |
| Base conversion error | Manual calculation error | Use `idapro_int_convert` |
| The function name cannot be found | The name is inaccurate | Use `list_funcs` + filter to search | first
