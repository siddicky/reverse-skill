---
name: ot-ics
description: Use for authorized OT/ICS security assessment covering Purdue model zoning, PLC/SCADA exposure, industrial protocol discovery, and safe passive-first evaluation.
---

# OT / ICS Security

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md` —**Misoperation in industrial control environment can cause physical hazard**
2. `NOW`: Written authorization must state clearly: site, network segment, whether active scanning/writing of register  is allowed
3. `NOW`: case-init; default**passive-first**; writing to PLC is prohibited before `ready_for_act`
4. `NEXT`: tool-index; Most industrial control tools require manual and isolation experiment network
5. `ACT`: Asset and partition identification → Exposed surface → Read-only verification

## applicable scenarios

- Industrial control/SCADA/DCS security assessment (authorization)
- Purdue model partition and cross-zone channel
- Modbus/DNP3/S7/EtherNet/IP and other protocols exposed
- engineering station, HMI, history library, springboard host
- IT/OT Converged Boundary (Firewall Rules, One-Way Gate)

## Iron Law of Safety (MUST)

```text
MUST NOT When not explicitly allowed:
- Write coil/register to PLC
- High-speed scanning of the entire network to produce OT
- Interrupt safety instrumented system (SIS) related paths
Priority: read-only identification, traffic mirroring, offline firmware/configuration analysis
```

## workflow

### Phase 1 — Partitions and Assets

```text
□ Purdue L0–L5 Sketch: Field Equipment → Control → Supervision → Site DMZ → Enterprise
□ Asset list: PLC/RTU/HMI/engineering station/history library/Jump host
□ Protocol and port baseline (only authorized network segments)
```

### Phase 2 — Passive and read-only

```text
□ SPAN/mirror PCAP → protocol-reverse / Wireshark industrial control parser
□ Offline audit of configuration and project files (TIA/RSLogix export, etc.)
□ The default password and plain text protocol (Modbus without authentication) are recorded as Finding, and the value is not written to the disk.
```

### Phase 3 — Restricted Active (authorization only)

```text
□ Low speed identification, maintenance window
□ Read-only function code takes priority
□Evidence for each step; abnormality will be stopped immediately and reported
```

### Phase 4 — Firmware/Patch

```text
□ Controller firmware version → CVE mapping (no blind flashing of firmware)
□ Combined with firmware-pentest for offline image analysis
```

## tool chain

| Tool | Purpose | Note |
|------|------|------|
| Wireshark industrial control dissectors | passive analysis | mirror traffic |
| Nmap NSE (limited) | identification | rate and time window |
| Claroty/Nozomi etc. | Asset Discovery | Commercial/Onsite |
| PLC manufacturer engineering software | configuration audit | offline priority |
| binwalk / Ghidra | firmware | offline |

## refers to

- `references/ot-safe-assessment.md`
- `../firmware-pentest/` `../protocol-reverse/` `../network` via pentest-tools

## routing context

**upstream**: MASTER R28  
**downstream**: firmware dig `firmware-pentest`; protocol `protocol-reverse`; IT horizontal `windows-ad`/`attack-chain`  
**is the same level as**: Do not use the default parameters of ordinary web scan to scan OT

## task completed self-test

- [ ] Does default to passive/read-only and record authorization boundaries?
- [ ] Avoid writes to control loops (unless explicitly allowed)?
- [ ] Does Finding include a description of physical/process effects?
- [ ] Checklist / journal？