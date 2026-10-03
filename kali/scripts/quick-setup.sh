#!/usr/bin/env bash
# quick-setup.sh — Kali 2026.1 one-click initialization
# Run this script on a fresh Kali system to do it automatically:
#   1. System update
#   2. Install Kali 2026.1 new tools
#   3. Configure Kali native MCP
#   4. Install non-preinstalled reverse engineering tools
#   5. Refresh tool index
#   6. Output configuration report
#
# usage:
#   sudo bash kali/scripts/quick-setup.sh [--skip-update] [--minimal]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Parameters ──────────────────────────────────────────────────────────────────

SKIP_UPDATE=false
MINIMAL=false

for arg in "$@"; do
    case "$arg" in
        --skip-update) SKIP_UPDATE=true ;;
        --minimal) MINIMAL=true ;;
    esac
done

# ───Color ────────────────────────────────────────────────────────────────

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
BOLD='\033[1m'
RESET='\033[0m'

banner() { echo -e "\n${BOLD}${CYAN}═══ $* ═══${RESET}\n"; }
ok() { echo -e "${GREEN}[✓]${RESET} $*"; }
warn() { echo -e "${YELLOW}[!]${RESET} $*"; }
info() { echo -e "${CYAN}[i]${RESET} $*"; }

# ─── Check permissions ───────────────────────────────────────────────────────────────

if [[ $EUID -ne 0 ]]; then
    echo "Please run with root privileges: sudo bash $0"
    exit 1
fi

# ─── Check Kali version ───────────────────────────────────────────────────────────

banner "Check system version"

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    info "System: $PRETTY_NAME"
    info "Version: ${VERSION:-unknown}"
    info "Core: $(uname -r)"
else
    warn "Unable to detect system version, continue execution..."
fi

# ─── System update ───────────────────────────────────────────────────────────────

if [[ "$SKIP_UPDATE" != "true" ]]; then
    banner "System update"
    apt-get update -qq
    apt-get upgrade -y -qq
    ok "System has been updated"
else
    info "Skip system update (--skip-update)"
fi

# ─── Install Kali 2026.1 new tools ──────────────────────────────────────────────────

banner "Install Kali 2026.1 new tools"

NEW_TOOLS_2026_1=(
    "adaptixc2"
    "atomic-operator"
    "fluxion"
    "gef"
    "metasploitmcp"
    "sstimap"
    "wpprobe"
    "xsstrike"
)

NEW_TOOLS_2025_4=(
    "evil-winrm-py"
    "hexstrike-ai"
)

for tool in "${NEW_TOOLS_2026_1[@]}" "${NEW_TOOLS_2025_4[@]}"; do
    if dpkg -l "$tool" &>/dev/null 2>&1; then
        ok "$tool installed"
    else
        info "Install $tool..."
        apt-get install -y -qq "$tool" 2>/dev/null && ok "$tool installed successfully" || warn "$tool failed to install (may not be in your source yet)"
    fi
done

# ─── Install Kali native MCP ──────────────────────────────────────────────────────

banner "Configure Kali native MCP"

MCP_TOOLS=("mcp-kali-server" "metasploitmcp" "hexstrike-ai")

for tool in "${MCP_TOOLS[@]}"; do
    if dpkg -l "$tool" &>/dev/null 2>&1; then
        ok "$tool installed"
    else
        info "Install $tool..."
        apt-get install -y -qq "$tool" 2>/dev/null && ok "$tool installed successfully" || warn "$tool installation failed"
    fi
done

# ─── Install AD/intranet penetration tools ────────────────────────────────────────────────────

if [[ "$MINIMAL" != "true" ]]; then
    banner "Install AD/intranet penetration tools"

    AD_TOOLS=("coercer" "netexec" "responder" "bloodhound" "certipy-ad")

    for tool in "${AD_TOOLS[@]}"; do
        if dpkg -l "$tool" &>/dev/null 2>&1; then
            ok "$tool installed"
        else
            info "Install $tool..."
            apt-get install -y -qq "$tool" 2>/dev/null && ok "$tool installed successfully" || warn "$tool installation failed"
        fi
    done
fi

# ─── Install non-preinstalled reverse engineering tools ───────────────────────────────────────────────────────

banner "Install reverse analysis tools"

# jadx (Kali is not pre-installed, download from GitHub)
if ! command -v jadx &>/dev/null; then
    info "Install jadx (from GitHub Release)..."
    bash "$SCRIPT_DIR/bootstrap-reverse.sh" jadx --skip-refresh 2>/dev/null && ok "jadx installed successfully" || warn "jadx installation failed"
else
    ok "jadx is available"
fi

# Node.js (required by some MCPs)
if ! command -v node &>/dev/null; then
    info "Install Node.js..."
    apt-get install -y -qq nodejs npm && ok "Node.js installed successfully" || warn "Node.js installation failed"
else
    ok "Node.js is available: $(node -v)"
fi

# frida-tools
if ! command -v frida &>/dev/null; then
    info "Install frida-tools..."
    pip3 install --break-system-packages frida-tools 2>/dev/null && ok "frida-tools installed successfully" || warn "frida-tools installation failed"
else
    ok "frida is available"
fi

# ─── Configure MCP client ───────────────────────────────────────────────────────────

banner "Configure MCP client"

# Detect the actual user ($HOME under sudo may be /root)
REAL_USER="${SUDO_USER:-root}"
REAL_HOME="$(getent passwd "$REAL_USER" 2>/dev/null | cut -d: -f6 || true)"
if [[ -z "$REAL_HOME" || ! -d "$REAL_HOME" ]]; then
    REAL_USER="root"
    REAL_HOME="$(getent passwd root 2>/dev/null | cut -d: -f6 || true)"
fi
if [[ -z "$REAL_HOME" || ! -d "$REAL_HOME" ]]; then
    REAL_HOME="/root"
fi

MCP_CONFIG_DIR="$REAL_HOME/.claude"
MCP_CONFIG="$MCP_CONFIG_DIR/mcp.json"

if command -v jq &>/dev/null; then
    mkdir -p "$MCP_CONFIG_DIR"

    if [[ ! -f "$MCP_CONFIG" ]]; then
        echo '{"mcpServers":{}}' > "$MCP_CONFIG"
    fi

    # Register kali-server
    jq '.mcpServers["kali-server"] = {"command": "kali-server-mcp", "args": ["--port", "5000"]}' "$MCP_CONFIG" > /tmp/mcp-tmp.json && mv /tmp/mcp-tmp.json "$MCP_CONFIG"

    # Register metasploit-mcp
    jq '.mcpServers["metasploit-mcp"] = {"command": "metasploitmcp", "args": ["--transport", "stdio"]}' "$MCP_CONFIG" > /tmp/mcp-tmp.json && mv /tmp/mcp-tmp.json "$MCP_CONFIG"

    # Register hexstrike
    jq '.mcpServers["hexstrike"] = {"command": "hexstrike-ai", "args": []}' "$MCP_CONFIG" > /tmp/mcp-tmp.json && mv /tmp/mcp-tmp.json "$MCP_CONFIG"

    # Register jshook
    jq '.mcpServers["jshook"] = {"command": "npx", "args": ["-y", "@jshookmcp/jshook@0.3.4"], "env": {"JSHOOK_BASE_PROFILE": "search"}}' "$MCP_CONFIG" > /tmp/mcp-tmp.json && mv /tmp/mcp-tmp.json "$MCP_CONFIG"

    chown "$REAL_USER:$REAL_USER" "$MCP_CONFIG" "$MCP_CONFIG_DIR"
    ok "MCP configuration has been written: $MCP_CONFIG"
else
    warn "jq is not installed and MCP cannot be automatically configured. Please copy kali/mcp-kali-example.json manually"
    info "Install jq: apt install jq"
fi

# ─── Refresh tool index ─────────────────────────────────────────────────────────────

banner "Refresh tool index"

chmod +x "$SCRIPT_DIR"/*.sh "$SCRIPT_DIR"/lib/*.sh
sudo -u "$REAL_USER" bash "$SCRIPT_DIR/refresh-tool-index.sh" 2>/dev/null || bash "$SCRIPT_DIR/refresh-tool-index.sh"
ok "Tool index refreshed"

# ─── Output report ───────────────────────────────────────────────────────────────

banner "Configuration completed"

echo -e "${BOLD}✅ Kali 2026.1 reverse skill routing package has been configured${RESET}"
echo ""
echo "  Installation path: $(cd "$SCRIPT_DIR/../.." && pwd)"
echo "MCP configuration: $MCP_CONFIG"
echo "  Tool Index: $(cd "$SCRIPT_DIR/../.." && pwd)/skills/tool-index.md"
echo ""
echo "Kali native MCP:"
command -v kali-server-mcp &>/dev/null && echo "    ✓ mcp-kali-server" || echo "    ✗ mcp-kali-server"
command -v metasploitmcp &>/dev/null && echo "    ✓ metasploitmcp" || echo "    ✗ metasploitmcp"
command -v hexstrike-ai &>/dev/null && echo "    ✓ hexstrike-ai" || echo "    ✗ hexstrike-ai"
echo ""
echo "2026.1 New tools:"
for tool in "${NEW_TOOLS_2026_1[@]}"; do
    if dpkg -l "$tool" &>/dev/null 2>&1; then
        echo "    ✓ $tool"
    else
        echo "    ✗ $tool"
    fi
done
echo ""
echo "Next step:"
echo "1. Tell your AI client to read kali/RULES-kali.md"
echo "2. Or ask AI directly: 'Read kali/RULES-kali.md and execute the configuration'"
echo "3. Security/reverse tasks will be automatically routed later."
echo ""
