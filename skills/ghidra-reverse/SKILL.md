---
name: ghidra-reverse
description: Use for free/open reverse engineering with Ghidra (headless or GUI), including decompile, cross-refs, and optional Ghidra MCP workflows when IDA is unavailable.
---

# Ghidra Reverse Engineering

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md`
2. `NOW`: Confirmation requires**Ghidra**(no IDA / prefer open source / batch headless)
3. `NEXT`: read `../tool-index.md` check ghidra / ghidra-mcp path
4. `NEXT`: missing tools → bootstrap `ghidra-mcp` (if supported by manifest) or follow manual steps to install Ghidra
5. `ACT`: Import samples → Automatic analysis → Export key functions to decompile

## applicable scenarios

- Main reverse entry  without IDA license
- batch headless analysis/decompile  in CI
- Ghidra script (Java/Python Jython/PyGhidra) to automate
- and `binary-diff` / `patch-diff-exploit`'s ghidriff linkage

## and IDA work together

| requires | priority |
|------|------|
| already has IDA MCP digging into | `ida-reverse/` |
| Open source / batch / teaching |**This skill**|
| CLI only quick recon | `radare2/` |

## workflow

### 1. Projects and automatic analysis

```text
□ New Project → Import file → Analyze (default analyzer)
□ Record language/compiler identification results and base addresses
□ Mark entry, export table, string xref
```

### 2. Key function

```text
□ From string / import API reverse query
□ Decompile window restoration algorithm
□ Rename functions/variables; write Plate comment
□ Handle Frida/GDB when dynamics are required (reverse-engineering dynamic chapter)
```

### 3. Headless (batch)

```bash
# example: analyzeHeadless path varies by installation, MUST take  from tool-index
analyzeHeadless /path/to/project Proj -import sample.bin -postScript ExportDecomp.py
```

### 4. MCP (if configured)

```text
□ Confirm ghidra MCP port (commonly 8765, subject to tool-index)
□ Use MCP tools to pull decompilation/xrefs, and port guessing is prohibited.
```

## tool chain

| Tool | Purpose | Bootstrap |
|------|------|------|
| Ghidra | decompilation main tool | manual release / package manager |
| ghidra-mcp | AI bridge | bootstrap capability name `ghidra-mcp` |
| ghidriff | patch differential | see `patch-diff-exploit` |

## refers to

- `references/ghidra-cheatsheet.md`
- `../ida-reverse/` `../radare2/` `../binary-diff/`

## routing context

**upstream**: MASTER R22  
**downstream**: dynamic verification → Frida/GDB; exploit → `pwn-chain`  
**is the same as**: `ida-reverse` (commercial digging)

## task completed self-test

- [ ] Is based on the real Ghidra/tool-index path?
- [ ] Should the function address be marked and renamed?
- [ ] Are there any reproducible steps?
- [ ] Checklist / journal？