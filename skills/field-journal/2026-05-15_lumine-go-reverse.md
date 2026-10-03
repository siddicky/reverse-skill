---
name: lumine-reverse-2026-05-15
description: Go 1.24.5 TLS fragmentation proxy lumine v0.9.1 full reverse recovery, including 7 package source code reconstructions
metadata:
  type: project
---

# lumine v0.9.1 — Go TLS shard proxy reverser

**Date**: 2026-05-15
**Target**: `lumine_v0.9.1_windows_amd64.exe` (PE32+, Go 1.24.5, 11.6 MB)
**Original text**: `REVERSE_REPORT.md`

## background

User requested to restore binary to readable Go source. The target is a TLS anti-DPI proxy tool, technology derived from Python [TlsFragment](https://github.com/maoist2009/TlsFragment).

## process

1. **Toolchain construction**: Python + capstone disassembly, GoReSym recovery symbol table (1944 Go functions, 269 from the project)
2. **Package Structure Identification**: Infer 12 packages from GoReSym’s `package.function` naming
3. **Type recovery**: Reverse the JSON deserialized type through `config.json`, and restore the field by combining function reference
4. **Source code reconstruction**: Write readable Go code package by package, retaining logic instead of restoring line by line
5. **Subpackage completion**: dial (outbound binding), errors (error type), format (string tool)

## Key findings

- Core anti-DPI mechanism: TLS record fragmentation + noise injection + waiting for ACK + OOB + Fake TTL
- Policy engine: Domain name Trie + IP Trie → Policy matching
- Rely on `go-freelru` (LRU cache) for DNS/TTL caching
- The source repository `github.com/moi-si/lumine` returns 404 and can only be restored completely by binary

## tool

| Tools | Usage | Version |
|---|---|---|
| GoReSym | Go symbol recovery | v1.7.1 (Mandiant) |
| Capstone | Disassembly engine | latest |
| pefile | PE structure analysis | latest |

## Trampling on pit records

1. **Python3 path problem**: stub python3 of WindowsApps does not support pip install capstone, and the complete CPython path is required.
2. **GoReSym sub-process path**: `~` will not be automatically expanded and requires `os.path.expanduser()`
3. **Tab/space mixed use**: There is a mix of tab/space in the automatically generated Python decompilation script, causing the Go source code format error; all v3 versions use spaces to solve the problem
4. **vendor-less GoReSym**: When the binary of Go 1.24.5 does not have the vendor symbol, GoReSym can still extract the function name but the parameters and local variables cannot be recovered.
5. **String noise**: Go standard library string constants are mixed in a lot and need to be carefully filtered from the package level.

## product

- `REVERSE_REPORT.md` — complete reverse analysis report
- `reconstructed_src_v3/` — 7 Go source files, core engine + 3 sub-packages
