#!/usr/bin/env bash
# tool-discovery.sh — Tool discovery library for Kali Linux
# Equivalent to the Windows version of ToolDiscovery.ps1

set -euo pipefail

# ─── Path derivation ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KALI_SCRIPTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KALI_DIR="$(cd "$KALI_SCRIPTS_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$KALI_DIR/.." && pwd)"
SKILL_ROOT="$PROJECT_ROOT/skills"

# ─── Tool directory definition ─────────────────────────────────────────────────────────────

# The definition format of each tool: name|skill|purpose|version_args|fallback_commands
# fallback_commands separated by commas
declare -a TOOL_CATALOG=(
    "jadx|apk-reverse|Java decompilation|--version|jadx,${HOME}/tools/jadx/bin/jadx,/opt/jadx/bin/jadx"
    "apktool|apk-reverse|APK unpacking and rebuilding|--version|apktool,${HOME}/tools/apktool/apktool,/usr/local/bin/apktool"
    "adb|apk-reverse|Device connection with logcat|version|adb,${HOME}/Android/Sdk/platform-tools/adb"
    "java|apk-reverse|Run jar with Java toolchain|-version|java"
    "apksigner|apk-reverse|APK signature|--version|apksigner,${HOME}/Android/Sdk/build-tools/*/apksigner"
    "zipalign|apk-reverse|APK Alignment||zipalign,${HOME}/Android/Sdk/build-tools/*/zipalign"
    "frida|apk-reverse|Frida dynamic injection|--version|frida"
    "frida-ps|apk-reverse|Frida process enumeration|--version|frida-ps"
    "r2|radare2|radare2 main analyzer|-v|r2,radare2,${HOME}/tools/radare2/bin/r2,/usr/bin/r2"
    "rabin2|radare2|binary recon|-v|rabin2,${HOME}/tools/radare2/bin/rabin2,/usr/bin/rabin2"
    "rasm2|radare2|Assembly/Disassembly|-v|rasm2,${HOME}/tools/radare2/bin/rasm2"
    "radiff2|radare2|binary difference|-v|radiff2,${HOME}/tools/radare2/bin/radiff2"
    "rahash2|radare2|Hash and check|-v|rahash2,${HOME}/tools/radare2/bin/rahash2"
    "rax2|radare2|Base and bit operation conversion|-v|rax2,${HOME}/tools/radare2/bin/rax2"
    "python|reverse-engineering|Auxiliary script execution|--version|python3,python"
    "pip|reverse-engineering|Python package management|--version|pip3,pip"
    "node|js-reverse|Run Node-side JS reproduction with MCP client|--version|node"
    "npx|js-reverse|Run temporary npm package with MCP entry|--version|npx"
    "jshookmcp|js-reverse|Launch @jshookmcp/jshook MCP via npx||npx"
    "reqable-mcp|pentest-tools|Launch the Reqable desktop client MCP via npx||npx"
    "xquik-mcp|threat-intelligence|Remote Exposure X Threat Intelligence MCP||"
    "jeb-pro|apk-reverse|Commercial Android/ARM decompiler (manual license installation)|--version|jeb,${HOME}/tools/JEB/jeb,${HOME}/JEB/jeb,/opt/jeb/jeb"
    "binaryninja|binary-ninja-reverse|Binary Ninja commercial reverse engineering platform (manual license installation)|--version|binaryninja,binaryninja-headless,${HOME}/BinaryNinja/binaryninja,${HOME}/tools/BinaryNinja/binaryninja,/opt/binaryninja/binaryninja"
    "agent-browser|browser-automation|Browser Automation (Playwright)|--version|agent-browser"
    "analyzeHeadless|reverse-engineering|Ghidra headless analytics||analyzeHeadless,${HOME}/tools/ghidra/support/analyzeHeadless,/opt/ghidra/support/analyzeHeadless,/usr/share/ghidra/support/analyzeHeadless"
    "playwright|browser-automation|Playwright browser engine|--version|playwright,npx playwright"
    "proxycat|pentest-tools|Agent pool management and rotation|--version|proxycat"
    "nmap|pentest-tools|Port scanning and service identification|--version|nmap"
    "sqlmap|pentest-tools|SQL injection automation|--version|sqlmap"
    "hashcat|pentest-tools|Password cracking|--version|hashcat"
    "hydra|pentest-tools|Online password blasting|-h|hydra"
    "gobuster|pentest-tools|directory blasting|version|gobuster"
    "ffuf|pentest-tools|Fuzz testing|-V|ffuf"
    "msfconsole|pentest-tools|Metasploit framework|--version|msfconsole"
    "nikto|pentest-tools|Web vulnerability scanning|-Version|nikto"
    "binwalk|reverse-engineering|Firmware analysis and extraction|--help|binwalk"
    "pwntools|reverse-engineering|CTF pwn exploit development framework|version|pwn"
    "bkcrack|reverse-engineering|CTF ZIP/PKZIP ZipCrypto known plaintext attack|--version|bkcrack"
    "yara|malware-analysis|Malware rules matching engine|--version|yara"
    "gdb|reverse-engineering|debugger|--version|gdb"
    "objdump|reverse-engineering|Disassembly|--version|objdump"
    "strings|reverse-engineering|String extraction|--version|strings"
    "file|reverse-engineering|File type identification|--version|file"
    "nuclei|pentest-tools|Vulnerability Scan|-version|nuclei"
    # ─── Kali 2026.1 new tools ───
    "metasploitmcp|pentest-tools|Metasploit MCP Server|-h|metasploitmcp"
    "mcp-kali-server|pentest-tools|Kali official MCP Server (terminal bridge)|-h|kali-server-mcp,mcp-server"
    "hexstrike-ai|pentest-tools|AI MCP Security Automation Platform (150+ Tools)||hexstrike-ai"
    "adaptixc2|pentest-tools|Post-infiltration and confrontation simulation framework||AdaptixServer"
    "atomic-operator|pentest-tools|Atomic Red Team test execution|--help|atomic-operator"
    "sstimap|pentest-tools|SSTI automatic detection and utilization|-h|sstimap"
    "xsstrike|pentest-tools|Advanced XSS Scanner|-h|xsstrike"
    "wpprobe|pentest-tools|WordPress plugin enumeration|--help|wpprobe"
    "fluxion|pentest-tools|WiFi Security Audit and Social Work||fluxion"
    "gef|reverse-engineering|GDB Enhanced Features (Modern Debugging)||gdb"
    "evil-winrm-py|pentest-tools|Python WinRM remote execution|-h|evil-winrm-py"
    "coercer|pentest-tools|Windows Authentication Enforcement (AD Attack)|-h|coercer"
    "pentestswarm|pentest-tools|Swarm Intelligence Autonomous Penetration Framework (Swarm AI)|--version|pentestswarm"
    # ─── Kali classic pre-installed tools that have not been included before ───
    "netexec|pentest-tools|Network service enumeration and exploitation (successor to CrackMapExec)|--help|nxc,netexec"
    "responder|pentest-tools|LLMNR/NBT-NS/MDNS poisoning|-h|responder"
    "crackmapexec|pentest-tools|The Swiss Army Knife of Network Penetration|--help|crackmapexec,cme"
    "bloodhound|pentest-tools|AD attack path visualization||bloodhound"
    "certipy|pentest-tools|AD Certificate Services Attack|--version|certipy"
    "wfuzz|pentest-tools|Web fuzz testing|--help|wfuzz"
    "john|pentest-tools|Password cracking||john"
    "aircrack-ng|pentest-tools|WiFi cracking kit|--help|aircrack-ng"
    "wireshark|pentest-tools|Network protocol analysis|--version|wireshark,tshark"
    "burpsuite|pentest-tools|Web proxy and vulnerability scanning||burpsuite"
)

# Script reference mapping
declare -A SCRIPT_REFS=(
    ["jadx"]="apk-reverse/scripts/decode.sh"
    ["apktool"]="apk-reverse/scripts/decode.sh,apk-reverse/scripts/rebuild-sign-install.sh"
    ["adb"]="apk-reverse/scripts/rebuild-sign-install.sh"
    ["java"]="apk-reverse/scripts/decode.sh"
    ["apksigner"]="apk-reverse/scripts/rebuild-sign-install.sh"
    ["zipalign"]="apk-reverse/scripts/rebuild-sign-install.sh"
    ["frida"]="apk-reverse/scripts/frida-run.sh"
    ["frida-ps"]="apk-reverse/scripts/frida-run.sh"
    ["r2"]="radare2/scripts/recon.sh"
    ["rabin2"]="radare2/scripts/recon.sh"
    ["rasm2"]="radare2/SKILL.md"
    ["radiff2"]="radare2/SKILL.md"
    ["rahash2"]="radare2/SKILL.md"
    ["rax2"]="radare2/SKILL.md"
    ["python"]="apk-reverse/scripts/frida-run.sh"
    ["node"]="js-reverse/SKILL.md"
    ["npx"]="js-reverse/SKILL.md"
    ["jshookmcp"]="js-reverse/SKILL.md"
    ["reqable-mcp"]="pentest-tools/SKILL.md"
    ["xquik-mcp"]="threat-intelligence/SKILL.md"
    ["jeb-pro"]="apk-reverse/SKILL.md"
    ["binaryninja"]="binary-ninja-reverse/SKILL.md"
    ["agent-browser"]="browser-automation/SKILL.md"
    ["playwright"]="browser-automation/SKILL.md"
    ["nmap"]="pentest-tools/SKILL.md"
    ["proxycat"]="pentest-tools/SKILL.md"
    ["metasploitmcp"]="pentest-tools/SKILL.md"
    ["mcp-kali-server"]="pentest-tools/SKILL.md"
    ["hexstrike-ai"]="pentest-tools/SKILL.md"
    ["adaptixc2"]="pentest-tools/SKILL.md"
    ["sstimap"]="pentest-tools/SKILL.md"
    ["xsstrike"]="pentest-tools/SKILL.md"
    ["wpprobe"]="pentest-tools/SKILL.md"
    ["coercer"]="pentest-tools/SKILL.md"
    ["pentestswarm"]="pentest-tools/SKILL.md"
    ["evil-winrm-py"]="pentest-tools/SKILL.md"
    ["gef"]="reverse-engineering/SKILL.md"
    ["bkcrack"]="reverse-engineering/crypto-decode-tools.md,../CTF-Sandbox-Orchestrator/competition-zip-archive/SKILL.md"
    ["netexec"]="pentest-tools/SKILL.md"
    ["responder"]="pentest-tools/SKILL.md"
)

# ─── Tool discovery function ─────────────────────────────────────────────────────────────

# Find the full path of the command
find_command() {
    local name="$1"
    command -v "$name" 2>/dev/null || true
}

# Check if the port is listening
test_tcp_port() {
    local port="$1"
    local host="${2:-127.0.0.1}"
    (echo >/dev/tcp/"$host"/"$port") 2>/dev/null && return 0
    # fallback to nc
    nc -z "$host" "$port" 2>/dev/null && return 0
    return 1
}

# Get tool version
get_tool_version() {
    local cmd="$1"
    local version_args="$2"

    if [[ -z "$version_args" ]]; then
        echo ""
        return
    fi

    local output
    if [[ "${cmd##*/}" == "pwn" && "$version_args" == "version" ]]; then
        output=$(PWNLIB_NOTERM=1 "$cmd" version 2>&1 | head -n1) || true
    else
        output=$("$cmd" $version_args 2>&1 | head -n1) || true
    fi
    echo "$output"
}

# Parse tool definitions and detect availability
# Returns: name|skill|purpose|available|resolved_path|version|source
resolve_tool() {
    local entry="$1"
    IFS='|' read -r name skill purpose version_args fallbacks <<< "$entry"

    IFS=',' read -ra candidates <<< "$fallbacks"

    for candidate in "${candidates[@]}"; do
        # Expand glob (such as build-tools/*/apksigner)
        local expanded
        expanded=$(compgen -G "$candidate" 2>/dev/null | head -n1) || expanded=""

        if [[ -n "$expanded" && -x "$expanded" ]]; then
            local ver
            ver=$(get_tool_version "$expanded" "$version_args")
            echo "${name}|${skill}|${purpose}|yes|${expanded}|${ver}|path"
            return
        fi

        # Try to find as command name
        local cmd_path
        cmd_path=$(find_command "$candidate")
        if [[ -n "$cmd_path" ]]; then
            local ver
            ver=$(get_tool_version "$cmd_path" "$version_args")
            echo "${name}|${skill}|${purpose}|yes|${cmd_path}|${ver}|command"
            return
        fi
    done

    # not found
    echo "${name}|${skill}|${purpose}|no|||missing"
}

# Get MCP configuration path (Claude Code)
get_claude_mcp_config_path() {
    echo "${HOME}/.claude/mcp.json"
}

# Check if the MCP server is registered
check_mcp_registered() {
    local server_name="$1"
    local config_path
    config_path=$(get_claude_mcp_config_path)

    if [[ ! -f "$config_path" ]]; then
        echo "false"
        return
    fi

    if command -v jq &>/dev/null; then
        local result
        result=$(jq -r ".mcpServers.\"${server_name}\" // empty" "$config_path" 2>/dev/null)
        if [[ -n "$result" ]]; then
            echo "true"
        else
            echo "false"
        fi
    else
        # fallback: grep
        if grep -q "\"${server_name}\"" "$config_path" 2>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
    fi
}

# Get bootstrap manifest path
get_bootstrap_manifest_path() {
    echo "${KALI_SCRIPTS_DIR}/bootstrap-manifest.json"
}

# Get capability definition from manifest (requires jq)
get_capability_definition() {
    local name="$1"
    local manifest
    manifest=$(get_bootstrap_manifest_path)

    if [[ ! -f "$manifest" ]]; then
        echo ""
        return
    fi

    if command -v jq &>/dev/null; then
        jq -r ".capabilities[] | select(.name == \"${name}\")" "$manifest" 2>/dev/null
    else
        echo ""
    fi
}
