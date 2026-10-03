# Cybersecurity Skills Router — Exclusively for Kali Linux

> This directory is the optimized adaptation layer of Kali Linux 2026.1. Special optimization based on Kali 2026.1 (kernel 6.18) released in March 2026.
> The core knowledge base (skills/, CTF-Sandbox-Orchestrator/) is shared with the Windows version; Kali-specific README and Bash entries need to cover the Windows core capability names, and additionally provide Kali native tools/MCP capabilities.  
> The root directory [README-kali.md](../README-kali.md) is only a short jump, **subject to this file**.

---

## AI: execute immediately after reading

```text
1. Detect the package root directory (including the warehouse roots of skills/ and kali/)
2. Read kali/RULES-kali.md → global injection and tool scanning
3. bash kali/scripts/refresh-tool-index.sh
4. Share the combat chain with the main package:
- skills/MASTER-ROUTING.md (or pwsh skills/scripts/master-route.ps1)
   - skills/scripts/case-init.ps1 → work/<case>/scope.md
- ACT the target only after auth.status=granted + network_profile
- skills/ops/(evidence chain/role/timeline/IDENTITY)
5. Report configuration results to users
```

For general Agent guidance, see the repository root [README_AI.md](../README_AI.md) (read this file again when Kali is detected).

---

## 0. Relationship with Windows version (ability name alignment)

```text
Project root directory/
├── skills/ # Sharing: SKILL, routing, MASTER-ROUTING, ops, scripts, field-journal
├── CTF-Sandbox-Orchestrator/ # Share: 40+ CTF sub-skills
├── kali/ # ← You are here
│   ├── scripts/
│   │   ├── bootstrap-reverse.sh
│   │   ├── refresh-tool-index.sh
│   │   ├── bootstrap-manifest.json
│   │   └── lib/
│   │       └── tool-discovery.sh
│   ├── RULES-kali.md
│   └── README-kali.md
├── RULES.md # Rules for Windows
└── Readme.md # Windows version instructions
```


### 0.1 Alignment principle

The Kali exclusive entrance is not a simple copy of the Windows README, but the same set of core capability names + Kali additional capabilities**:

- Windows：`skills/scripts/bootstrap-reverse.ps1`
- Kali：`kali/scripts/bootstrap-reverse.sh`
- Normal Linux/macOS: `skills/scripts/bootstrap-reverse.sh`

JEB Pro is a commercial tool that is licensed and installed by the user; Reqable MCP uses the official fixed version of `reqable-mcp-server`, but still requires a separate installation of the Reqable desktop client.

Kali scripts should override the core capability names in the Windows manifest, e.g. `jadx`, `apktool`, `frida`, `jshookmcp`, `xquik-mcp`, `anything-analyzer`, `idapro`, QZXKEE P7QZX, `adb`, `ghidra-mcp`, `seclists`, `burpsuite-mcp`, `nmap`, `pentestswarm`; additional support is available at the same time Kali native tools, such as `mcp-kali-server`, `metasploitmcp`, `hexstrike-ai`, `sstimap`, `xsstrike`, `netexec`, etc.

**Shared part** (no changes required):
- All `SKILL.md`, `routing.md`, `MASTER-ROUTING.md`
- `skills/ops/` Combat Contract (scope/evidence chain/role/timeline)
- All `references/` knowledge bases
- `field-journal/` self-evolution mechanism
- `CTF-Sandbox-Orchestrator/` All
- `docs-generator/`、`diagram-generator/`
- `skills/scripts/case-init.ps1`, `master-route.ps1` (can be called with pwsh)

**Kali Exclusive Section**:
- The scripts are all bash (`.sh`)
- Package management goes `apt`
- The path convention is Linux style (`/opt/`, `~/tools/`, `/usr/bin/`)
- A large number of tools are pre-installed in Kali, and the bootstrap logic is greatly simplified.

---

## 1. Kali’s natural advantages

The following tools work **out of the box** in Kali 2026.1 (no bootstrap required):

### Classic pre-installation tool

| tool | Kali package name | status |
|------|----------|------|
| nmap | nmap | pre-installed |
| sqlmap | sqlmap | pre-installed |
| hashcat | hashcat | pre-installed |
| john | john | pre-installed |
| hydra | hydra | pre-installed |
| metasploit | metasploit-framework | pre-installed |
| gobuster | gobuster | pre-installed |
| ffuf | ffuf | pre-installed |
| radare2 | radare2 | pre-installed |
| binwalk | binwalk | pre-installed |
| frida | python3-frida-tools | pre-installed or pip |
| burpsuite | burpsuite | pre-installed |
| wireshark | wireshark | pre-installed |
| nikto | nikto | pre-installed |
| wfuzz | wfuzz | pre-installed |
| impacket | impacket-scripts | pre-installed |
| netexec | netexec | pre-installed |
| responder | responder | pre-installed |
| aircrack-ng | aircrack-ng | pre-installed |
| bloodhound | bloodhound | apt can be installed |
| ghidra | ghidra | apt can be installed |

### Kali 2026.1 new tools (March 2026)

| tool | package name | purpose |
|------|------|------|
| AdaptixC2 | adaptixc2 | Post-penetration and confrontation simulation framework |
| Atomic-Operator | atomic-operator | Cross-platform Atomic Red Team test execution |
| Fluxion | fluxion | WiFi Security Audit and Social Engineering |
| GEF | gef | GDB Modern Enhanced Debugging Framework |
| MetasploitMCP | metasploitmcp | Metasploit’s MCP Server interface |
| SSTImap | sstimap | Server-side template injection automatic detection and utilization |
| WPProbe | wpprobe | Fast WordPress plugin enumeration |
| XSStrike | xsstrike | Advanced XSS Scanner |

### Kali 2025.4 new tools (December 2025)

| tool | package name | purpose |
|------|------|------|
| evil-winrm-py | evil-winrm-py | Python version WinRM remote command execution |
| hexstrike-ai | hexstrike-ai | AI MCP Security Automation Platform (150+ Tools) |
| bpf-linker | bpf-linker | BPF static linker |

### Kali native MCP tool (key optimization)

| tool | package name | purpose | installation |
|------|------|------|------|
| mcp-kali-server | mcp-kali-server | Kali official MCP, AI directly calls the terminal tool | `apt install mcp-kali-server` |
| MetasploitMCP | metasploitmcp | Metasploit MCP interface | `apt install metasploitmcp` |
| HexStrike AI | hexstrike-ai | 150+ Security Tools MCP Automation | `apt install hexstrike-ai` |

> **This is the biggest advantage of the Kali version compared to the Windows version**: the three MCP tools are directly installed with apt, without manual configuration of GitHub/npm/Docker.

This means that `bootstrap-reverse.sh` requires much less work on Kali than on the Windows version.

---

## 2. Quick start

### 2.0 One-click initialization (recommended for new systems)

```bash
# One-click configuration of the new Kali 2026.1 system (root required)
sudo bash kali/scripts/quick-setup.sh

# Skip system updates (when the network is slow)
sudo bash kali/scripts/quick-setup.sh --skip-update

# Minimal installation (no AD/intranet tools installed)
sudo bash kali/scripts/quick-setup.sh --minimal
```

This script will automatically complete: system update → install 2026.1 new tools → configure native MCP → install reverse engineering tools → refresh index → ​​output report.

### 2.1 First time configuration

```bash
# 1. Enter the project root directory
cd /path/to/cybersecurity-skills-router

# 2. Add execution permissions to the script
chmod +x kali/scripts/*.sh kali/scripts/lib/*.sh

# 3. Refresh tool index (detect local tool status)
bash kali/scripts/refresh-tool-index.sh

# 4. View results
cat skills/tool-index.md
```

### 2.2 Configure Kali native MCP with one click (strongly recommended)

```bash
# Install Kali official MCP three-piece set
bash kali/scripts/bootstrap-reverse.sh mcp-kali-server metasploitmcp hexstrike-ai

# After installation, the MCP configuration is automatically written to ~/.claude/mcp.json
# If using Kiro, manually copy to ~/.kiro/settings/mcp.json
```

### 2.3 Install 2026.1 new tools

```bash
# All new tools installed with one click
bash kali/scripts/bootstrap-reverse.sh adaptixc2 atomic-operator sstimap xsstrike wpprobe fluxion gef

# AD/intranet penetration kit
bash kali/scripts/bootstrap-reverse.sh coercer evil-winrm-py netexec responder bloodhound certipy
```

### 2.4 Install missing tools

```bash
# Install a single tool
bash kali/scripts/bootstrap-reverse.sh jadx

# Install multiple tools
bash kali/scripts/bootstrap-reverse.sh jadx apktool frida jshookmcp

# Install and start the service
bash kali/scripts/bootstrap-reverse.sh idapro --start-services
```

### 2.5 Let the AI ​​client route automatically

Tell your AI client to read `kali/RULES-kali.md` and it will do the global injection automatically.

---

## 3. Path agreement

| Purpose | Kali Path |
|------|----------|
| tool installation directory | `~/tools/` or `/opt/` |
| jadx | `/opt/jadx/` or `~/tools/jadx/` |
| apktool | `/usr/local/bin/apktool` (apt) or `~/tools/apktool/` |
| Ghidra | `/opt/ghidra/` or `~/tools/ghidra/` |
| IDA Pro | `/opt/idapro/` (if there is a Linux version) |
| Android SDK | `~/Android/Sdk/` |
| SecLists | `/usr/share/seclists/` (apt) or `~/tools/SecLists/` |
| Node.js | `/usr/bin/node`（apt/nvm） |
| Python | `/usr/bin/python3` (system comes with it) |
| MCP configuration | `~/.claude/mcp.json` or `~/.kiro/settings/mcp.json` |

---

## 4. Summary of differences from the Windows version

| Dimensions | Windows version | Kali version |
|------|-----------|---------|
| Scripting Language | PowerShell (.ps1) | Bash (.sh) |
| package management | winget / GitHub Release ZIP | apt / pip / npm / GitHub Release tar.gz |
| path separator | `\` | `/` |
| environment variable | `%USERPROFILE%` | `$HOME` |
| Pre-installed tools | Almost none | Lots of security tools pre-installed |
| IDA starts | `start.ps1` | Manually starts the Linux version of IDA; the script only registers/checks MCP, unless the machine itself adds launcher |
| MCP configuration path | `%USERPROFILE%\.claude\mcp.json` | `~/.claude/mcp.json` |
| port detection | `TcpClient` | `nc -z` or `ss` |

---

## 5. Verification Checklist

```bash
# ─── Basic commands ───
java -version
python3 --version
pip3 --version
node -v
npx -v

# ─── Reverse tools ───
jadx --version
apktool --version
adb version
frida --version
r2 -v
gdb --version          # GEF autoload

# ─── Penetration tools (Kali pre-installed) ───
nmap --version
sqlmap --version
hashcat --version
hydra -h | head -1
msfconsole --version
gobuster version
ffuf -V
nuclei -version

# ─── Kali 2026.1 New Tools ───
sstimap -h 2>&1 | head -3
xsstrike -h 2>&1 | head -3
wpprobe --help 2>&1 | head -3
coercer -h 2>&1 | head -3
evil-winrm-py -h 2>&1 | head -3

# ─── AD/Intranet Tools ───
netexec --help 2>&1 | head -3
responder -h 2>&1 | head -3
certipy --version 2>&1 | head -1

# ─── Kali native MCP ───
which kali-server-mcp && echo "mcp-kali-server OK"
which metasploitmcp && echo "metasploitmcp OK"
which hexstrike-ai && echo "hexstrike-ai OK"

# ─── Refresh tool index ───
bash kali/scripts/refresh-tool-index.sh

# ─── Check MCP service (if configured) ───
nc -z 127.0.0.1 5000 && echo "mcp-kali-server OK" || echo "mcp-kali-server offline"
nc -z 127.0.0.1 8085 && echo "metasploitmcp OK" || echo "metasploitmcp offline"
nc -z 127.0.0.1 13337 && echo "IDA MCP OK" || echo "IDA MCP offline"
nc -z 127.0.0.1 23816 && echo "anything-analyzer OK" || echo "anything-analyzer offline"
```

---

## 6. FAQ

### Q: What should I do if the version of radare2 that comes with Kali is too old?

```bash
# Install the latest version from official sources
bash kali/scripts/bootstrap-reverse.sh r2
# The Kali version defaults to apt installation/complement radare2; if you need the latest version, you can use GitHub/source according to the platform documentation.
```

### Q: I am using Parrot OS / BlackArch, can it be used?

Can. The script detects whether the command exists and is not bound to a specific distribution. It’s just that the automatic installation related to `apt` may need to be changed to `pacman` (BlackArch).

### Q: How to configure IDA Pro Linux version?

Install IDA to `/opt/idapro/`, and then modify the `startScript` path of `idapro` in `kali/scripts/bootstrap-manifest.json`.

### Q: I want to use this system on both Windows and Kali

no problem. The `skills/` directory is synchronized through Git, and the experience of `field-journal/` is shared by both parties. Just when executing the script, Windows uses `skills/scripts/*.ps1` and Kali uses `kali/scripts/*.sh`.

