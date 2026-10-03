---
name: radio-sdr
description: Use for authorized RF/SDR security research including signal identification, replay feasibility study in shielded labs, and wireless protocol analysis outside classic Wi-Fi.
---

# RF / SDR Security Research

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`:**spectrum and emission are strictly controlled by law**; only authorized frequency band/shielded room/experimental target
2. `NOW`: scope Specify the device, frequency band, and whether it is allowed to transmit (default only receives)
3. `ACT`: only receive identification → demodulation analysis → laboratory reproduction evaluation

## applicable scenarios

- Wireless remote control/sensor and other non-Wi-Fi RF (authorized)
- ADS-B/remote control and other protocols research (legal reception)
- Division of work between and wifi-wireless: This skill is**SDR, general RF**; Wi-Fi attack and defense R29

## workflow

```text
□ Regulations and licensing confirmation
□ Accept only: Identify center frequency and modulation
□ GNU Radio / URH Analysis
□ Replays only in shielded rooms and with written permission
□ Conclusion focuses on: whether unauthorized control is possible/reinforcement suggestions
```

## tool chain

| Tool | Purpose |
|------|------|
| RTL-SDR / HackRF (Compliant) | Transceiver Hardware |
| URH / GNU Radio | Analysis |
| Inspectrum | Signal |

## refers to

- `references/sdr-lab-rules.md`
- `../wifi-wireless/` `../ot-ics/` `../hardware-security/`

## routing context

**upstream**: MASTER R38  
**MUST NOT**: Interference with public communications, unauthorized transmission of

## task completed self-test

- [ ] Does only accept and record regulatory boundaries by default?
- [ ] Checklist？