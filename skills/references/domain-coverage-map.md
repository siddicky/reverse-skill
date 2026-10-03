# This package domain coverage map (depth first)

> compares the "hundreds of micro skills" in the community: we use**, a small number of deep skills + routing + ops**to cover the main battlefield.  
> Date: 2026-07-18

## domain → This package entry

| Domain | PRIMARY / Module | Remarks |
|----|----------------|------|
| Mobile Android | `apk-reverse/` `mobile-reverse/` | |
| Mobile iOS | `mobile-reverse/` | |
| Binary Deep Digging | `ida-reverse/` `radare2/` `ghidra-reverse/` | Ghidra = Open Source Main Path |
| Universal RE / Anti-Debugging / OLLVM | `reverse-engineering/` | |
| .NET | `dotnet-reverse/` | |
| Frontend JS / Signature | `js-reverse/` | |
| browser extension | `browser-extension-reverse/` | |
| DSL/wind control VM | `reverse-engineering/dsl-vm-reverse/` | |
| protocol / PCAP protocol | `protocol-reverse/` | |
| Firmware IoT | `firmware-pentest/` | |
| Malicious sample | `malware-analysis/` | |
| Digital Forensics / IR | `digital-forensics/` | |
| Threat Hunting / Blue Team | `threat-hunting/` | |
| Penetration Tools | `pentest-tools/` (+ src-hunter) | |
| Windows / AD | `windows-ad/` | |
| Cloud / Container / K8s | `cloud-k8s/` | |
| Code Audit / SAST | `code-audit/` | |
| Wi-Fi / Wireless | `wifi-wireless/` | |
| OT / ICS | `ot-ics/` | Passive priority; writing register is disabled by default |
| macOS | `macos-reverse/` | iOS mobile-reverse |
| Binary Ninja | `binary-ninja-reverse/` | Commercial GUI/Python API; community MCP only explicitly enabled and default loopback binding |
| thick client | `thick-client/` | |
| Go/Rust Binary | `go-rust-reverse/` | |
| hardware debugging port | `hardware-security/` | handover firmware-pentest |
| database | `database-security/` | |
| Mail / Phishing | `email-security/` | |
| federated identity SSO | `identity-federation/` | complementary to api-security JWT |
| RF / SDR | `radio-sdr/` | Default only; non-Wi-Fi |
| Multi-stage attack | `attack-chain/` | |
| Pwn | `pwn-chain/` | |
| N-day patch | `patch-diff-exploit/` | |
| EDR Research | `edr-bypass-re/` | |
| API | `api-security/` | |
| Supply Chain SBOM | `supply-chain-security/` | |
| LLM/Agent | `llm-security/` | + `ops/skill-supply-chain.md` |
| Browser Automation | `browser-automation/` | |
| Report/Picture | `docs-generator/` `diagram-generator/` | |
| symbol migration | `binary-diff/` | |
| Combat Contract | `ops/` |**Features**|
| CTF Arrangement | `CTF-Sandbox-Orchestrator/` | |
| cryptographic pattern recognition | `reverse-engineering` pattern document | is shared with the reverse task and does not maintain an independent expansion package |

## Clear the domain that is not merged into the entire library (strategy when routing misses)

| domain | policy |
|----|------|
| Pure game plug-in development | is not used as a product direction; Unity samples are still available `reverse-engineering` + seed-014 |
| Deep automotive/aviation certification level | can be externally linked; this package only has RF/OT entry level |
| Pure GRC/compliance long article | does not replace professional GRC tools; writable report template reference |
| 800+ ATT&CK micro skill | Use this table + ATT&CK optional tag (Finding field) |

## and MITER ATT&CK (optional)

The Finding template allows `optional_attack: Txxxx` (see `ops/evidence-finding-path.md`),**does not force the**full ATT&CK engine.
