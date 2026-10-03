# ctf-demo — Final Report (example)

> The report structure refers to `skills/docs-generator/references/security-report-templates.md`.

## 1. Overview

| item | value |
|----|----|
| target | pwn1 (https://ctf.example.com/challenges/pwn1) |
| type | CTF pwn (stack overflow) |
| results | ✅ flag captured |
| takes time | ~1.5h |

## 2. Executive summary

pwn1 is a 64-bit ELF without PIE/canary, and main uses `gets()` to read the 0x40 buffer.
Overwrite the return address with the 0x48 offset, and call the win function in the program to obtain the flag. Remote verification successful.

## 3. Timeline

See `timeline.md` (5 phases: init → recon → static → exploit → wrap).

## 4. Discover

### F-01

- title: gets() stack overflow in main (ret2win)
- severity: high
- status: validated
- confidence: high
- evidence_ids: [E-001, E-002, E-003]
- location: pwn1:main — gets() into buf[0x40], return offset 0x48, no canary
- impact: Remote code execution as the pwn1 process user; flag disclosure in CTF context.
- repro_steps:
  1. Triage the binary (E-001)
  2. Confirm the overflow offset with a cyclic/crash test (E-002)
  3. Send the ret2win payload against the remote service (E-003)
- remediation: Replace gets() with fgets/read; enable canary, PIE and full RELRO; rely on ASLR.

## 5. Attack path (Evidence → Finding → Path)

### P-01

- title: pwn1 ret2win solve path
- path_type: solve
- start: challenge binary download
- goal: flag capture
- steps:
  1. action: download and triage pwn1 — evidence: E-001 — finding: F-01 | none
  2. action: decompile main and confirm gets() overflow — evidence: E-002 — finding: F-01
  3. action: craft ret2win payload and verify remotely — evidence: E-003 — finding: F-01
- residual_risks: none (isolated CTF lab)

```mermaid
graph LR
  A[Download pwn1] --> B[checksec reconnaissance]
  B --> C[Ghidra decompile main]
  C --> D[Position gets overflow offset 0x48]
  D --> E[Construct payload ret2win]
  E --> F[Remote verification get flag]
```

## 6. Recurrence

```bash
python3 exploit.py REMOTE
```

## 7. Repair suggestions (if it is a real application)

- Use `fgets`/`read` instead of `gets`
- Turn on canary + PIE + full RELRO
- Deploy ASLR (server side)

## 8. Notes

- field-journal has been redacted and precipitated (no real target information)
