---
name: go-rust-reverse
description: Use for reverse engineering stripped Go and Rust binaries including runtime recognition, pclntab/moduel data recovery, panic strings, and idiomatic decompilation recovery.
---

# Go / Rust Binary Reverse Engineering

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read`../field-journal/precedent-reverse.md`
2. `NOW`: Confirm that the sample is a Go/Rust compiled product (`file`/String/Runtime Features)
3. `NEXT`: GoReSym / Are related plug-ins available?
4. `ACT`: Runtime identification → symbol/metadata recovery → business logic

## Applicable scenarios

- Go malware/tools that strip symbols
- Rust releases binary, panics string-driven analysis
- Language-specific methods complementary to general-purpose ida/ghidra

## Workflow

### Go

```text
□ Identify go.buildid, residual runtime symbols, and pclntab
□ Recover function names with GoReSym / redress / IDA Go plugin
□ Note how interface, slice, and string structures appear in decompiled output
□ Network/crypto library paths: crypto/* net/http
```

### Rust

```text
□ panic strings, rust_begin_unwind, and crate paths provide clues
□ Generic instantiation can cause code bloat; locate string cross-references first
□ Async/Tokio state machines require cross-references
```

### dynamic

```text
□ Frida is still usable; account for the Go stack and scheduler
□ Prefer breakpoints guided by logs and configuration strings
```

## tool chain

| Tool | Purpose |
|------|------|
| GoReSym | Go Metadata |
| IDA/Ghidra + Go/Rust plug-in | decompile |
| radare2 | fast string |
| strings / rabin2 | triage |

## refer to

- `references/go-rust-notes.md`
- `../reverse-engineering/go-reverse.md` `../ida-reverse/` `../ghidra-reverse/`
- seed: `field-journal/seed-002_go-malware-stripped.md`

## routing context

**Upstream**: MASTER R33  
**Downstream**: Malicious sample process`malware-analysis`; General RE`reverse-engineering`

## Task completion self-check

- [ ] Restore key function names or equivalent mappings?
- [ ] Is language runtime evidence marked?
- [ ] Checklist？