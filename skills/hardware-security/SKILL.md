---
name: hardware-security
description: Use for authorized hardware and embedded interface security research including UART/JTAG discovery, debug pad triage, secure boot overview, and offline firmware extraction support.
---

# Hardware / Embedded Interface Security

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Confirm**physical contact authorization**and device ownership
2. `NOW`: ESD/power-safe; default read-only probe
3. `NEXT`: Combined with firmware-pentest to do image analysis
4. `ACT`: Shell and debug interface identification → consoles → Extract

## applicable scenarios

- UART / JTAG / SWD debug port found
- startup log, root shell, boot interruption
- cooperates with disassembly to extract Flash
- Feasibility evaluation of secure boot/encrypted Flash (non-destructive priority)

## workflow

```text
□ Disassemble authorized equipment; take photos and mark test points
□ Use a multimeter to find GND/VCC/TX/RX; logic level 1.8/3.3/5V
□ USB-TTL read-only log; records baud rate
□ JTAG: enumerate IDCODE; evaluate whether locked
□ Extract image → handover firmware-pentest / ghidra
```

## tool chain

| Tool | Purpose |
|------|------|
| USB-TTL / logic analyzer | UART |
| J-Link / CMSIS-DAP | Debugging |
| bus pirate / flipper (lab) | multi-protocol |
| binwalk/flashrom | extraction |

## refers to

- `references/debug-interface-triage.md`
- `../firmware-pentest/` `../ot-ics/`

## routing context

**upstream**: MASTER R34  
**MUST NOT**: Unauthorized disassembly/damage to other people’s equipment

## task completed self-test

- [ ] Do you record the interface level and pin diagram?
- [ ] Is the image hash protected?
- [ ] Checklist？