---
name: digital-forensics
description: Use for authorized digital forensics including memory dumps, disk timelines, PCAP investigation, artifact triage, and IR evidence preservation.
---

# Digital Forensics & IR Artifacts

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md` or organization IR authorization description
2. `NOW`: Confirmed that this is **forensic/attribution** rather than offensive scanning
3. `NOW`: Establish case; read-only copy of evidence takes precedence (original media write-protected)
4. `NEXT`: tool-index; Volatility and other common manual operations
5. `ACT`: Preservation Hash → Timeline → Key Artifacts

## Applicable scenarios

- Memory dump analysis (Volatility 2/3)
- Disk/E01/File Timeline
- PCAP traceability and protocol restoration (can be combined with `protocol-reverse/`)
- Host artifacts: Prefetch, Shimcache, Event Log, Browser History
- Emergency response IOC extraction (joint `malware-analysis/` / `threat-hunting/`)

## Workflow

### 1. Preservation

```text
□ Calculate SHA256; record time zone and collection command
□ Work on a copy; original read-only
□ chain of custody notes written into timeline
```

### 2. Memory

```bash
vol -f mem.dmp windows.info
vol -f mem.dmp windows.pslist
vol -f mem.dmp windows.netscan
vol -f mem.dmp windows.cmdline
```

### 3. Host artifacts

```text
□ Event log: Security / PowerShell / Sysmon
□ Persistence: Run key, service, scheduled task, WMI
□ Execution traces: Amcache, Prefetch, BAM
```

### 4. Network

```text
□ tshark statistics session and DNS
□ Export suspicious flow → protocol-reverse or malware C2 analysis
```

## tool chain

| Tool | Purpose |
|------|------|
| Volatility 3 | Memory |
| Timeline Explorer / Plaso | Super Timeline |
| tshark | PCAP |
| Eric Zimmerman Toolset | Windows Artifacts |
| Autopsy / FTK Imager | Disk |

## refer to

- `references/forensics-triage.md`
- `../malware-analysis/` `../threat-hunting/` `../protocol-reverse/`

## routing context

**Upstream**: MASTER R25  
**Downstream**: Malicious sample digging → malware-analysis; rules → threat-hunting

## Task completion self-check

- [ ] Preserve hash and replica policies?
- [ ] Is the timeline reviewable?
- [ ] Are IOCs graded for redaction?
- [ ] Checklist？