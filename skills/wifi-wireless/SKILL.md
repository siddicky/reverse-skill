---
name: wifi-wireless
description: Use for authorized wireless security assessment including Wi-Fi capture, WPA handshake analysis, rogue AP detection research, and lab-only deauth testing.
---

# Wi-Fi / Wireless Security

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: reads precedent-pentest; **Wireless attack legal risk is high**, written authorization and physical scope are required
2. `NOW`: scope specifies the target SSID/BSSID/site; scanning neighbor networks is prohibited
3. `NEXT`: Confirm adapter listen mode capability
4. `ACT`: Reconnaissance → Collection → Analysis (laboratory priority)

## Applicable scenarios

- Authorize Wi-Fi Security Assessment
- WPA/WPA2 handshake collection and offline evaluation
- Research on Rogue AP/Phishing Hotspot Detection
- Enterprise Wireless Isolation and Portal Security

## Workflow

```text
□ iwconfig / airmon-ng enter monitor (legal environment)
□ airodump-ng locks the target BSSID channel
□ Handshake or PMKID collection (target only)
□ hashcat/aircrack offline evaluation of password policies
□ Reports: encryption type, quarantine, portal bypass, recommendations
```

## tool chain

| Tool | Purpose |
|------|------|
| aircrack-ng suite | acquisition/evaluation |
| hcxdumptool / hcxtools | PMKID |
| hashcat | password evaluation |
| Wireshark | Management frame analysis |

## refer to

- `references/wireless-lab-rules.md`
- `../pentest-tools/` `../attack-chain/` (near source chapter)

## routing context

**Upstream**: MASTER R29  
**MUST NOT**: Unauthorized deauth, network operations for non-target customers

## Task completion self-check

- [ ] Is the target BSSID strictly targeted?
- [ ] Are reinforcement recommendations included in the report?
- [ ] Checklist？