# BurpSuite MCP Full Control Extension

Complete control of all core functionality of BurpSuite via MCP protocol. Cross-platform support Windows / Linux (Kali) / macOS.

## Quick start

### 1. Compile extension

**Windows**:
```cmd
cd burp-mcp-full
build.bat
```

**Linux / Kali / macOS**:
```bash
cd burp-mcp-full
chmod +x build.sh
./build.sh
```

The build script will automatically: detect JDK 21+, download dependencies (montoya-api 2025.5 / gson / nanohttpd), compile, enter extension descriptors (`META-INF/extensions/burp-extension.properties`) into jar, and package fat jar. No Gradle required.

Output: `build/libs/burp-mcp-full.jar`.

### 2. Load into Burp

```
Burp Suite → Extensions → Add → Java → Select build/libs/burp-mcp-full.jar
```

After loading, you will see this in Output:
```
[MCP] Server started on http://127.0.0.1:9876
```

### 3. Authentication (enabled by default since v2)

When the extension starts, a random token is automatically generated and written to `~/.burp-mcp-token`. `mcp-bridge.js` will automatically read this file and carry the `Authorization: Bearer <token>` header in each request, no manual configuration is required.

When the token needs to be fixed (for example, shared by multiple clients), you can use:
- JVM parameter: `-Dburp.mcp.token=<token>`
- Environment variable: `BURP_MCP_TOKEN=<token>` (also used on the bridge side)

All `/health`, `/tools`, `/` (POST) requests are required to carry this header, otherwise 403 will be returned. CORS has converged to only allow `http://127.0.0.1` origins.

### 4. Configure MCP client

Add (stdio mode) in any MCP client (Claude Code / Kiro / Cursor / Cline / Windsurf):

```json
{
  "mcpServers": {
    "burpsuite": {
      "command": "node",
      "args": ["<path to this directory>/mcp-bridge.js"]
    }
  }
}
```

### 5. Get started

Say to AI: "Analyze requests in Burp proxy history to find security vulnerabilities"

## Function list

The extension exposes 78 tools. Commonly used categories are as follows (for the complete list, see `getToolList()` in `src/main/java/com/burpmcp/McpHttpServer.java`, or visit `GET http://127.0.0.1:9876/tools`, which requires the Authorization header):

| Categories | Tools |
|------|------|
| Proxy History | `proxy_history`, `proxy_detail`, `proxy_history_filtered`, `proxy_websocket`, `proxy_clear`, `search_history`, `highlight`, `annotate`, `compare` |
| Send request | `send_request`, `send_to_repeater`, `repeater_send`, `repeater_modify_send`, `send_to_intruder` |
| Intruder attack | `intruder_attack`, `intruder_attack_async`, `intruder_attack_wordlist`, `intruder_pitchfork`, `intruder_cluster_bomb`, `intruder_battering_ram`, `intruder_with_options`, `payload_process` |
| Scanning/Crawling | `scan`(active/passive), `scan_active`, `scan_results`, `scan_issue_detail`, `crawl`, `sequencer` |
| Scope / Sitemap | `sitemap`, `target_info`, `get_scope`, `add_to_scope`, `remove_from_scope`, `add_issue` |
| Intercept/Rules | `intercept_toggle`, `register_http_handler`, `remove_http_handler`, `register_proxy_rule`, `remove_proxy_rule` |
| Encoding | `encode`, `decode`, `convert_request`, `export_request`, `generate_csrf_poc`, `extract_from_response`, `token_analysis` |
| Collaborator | `collaborator_generate`, `collaborator_poll` |
| Configuration | `export_config`, `import_config`, `set_upstream_proxy`, `set_dns_override`, `set_http2`, `cookie_jar`, `save_project`, `burp_version`, `extensions_list`, `log` |

> Scanning/crawling (`scan`, `scan_active`, `crawl`) requires **Burp Professional**. Community edition returns an explicit license error. Manually added issues (`add_issue`) will be written to the Site map.

## Key tool parameters

### `intruder_attack` — Automated enumeration attack

| Parameters | Description |
|------|------|
| `url_template` | URL template, placeholder default `@@` |
| `placeholder` | Placeholder string (default `@@`) |
| `from` / `to` | Enumeration stop value |
| `pad_digits` | Pad zero digits (0 is not padded) |
| `method` | HTTP method (default GET) |
| `body_template` | Request body template (including placeholder) |
| `headers` | Request header object |
| `success_length_not` | Hit condition: response length ≠ this value |
| `success_contains` | Hit condition: The response body contains this string |

### `scan` — Start auditing

| Parameters | Description |
|------|------|
| `url` | Target URL (required, automatically added to scope) |
| `mode` | `active` (default) or `passive` |

After startup, use `scan_results` to poll issues and active audit status (number of requests, number of errors, number of insertion points).

### `register_proxy_rule` — proxy request interception rule

| Parameters | Description |
|------|------|
| `url_contains` | Hit condition: URL contains this string |
| `intercept` | `true` intercepts / `false` releases but does not intercept (default true) |

Deregister the rule via `remove_proxy_rule` (based on `Registration.deregister()`, truly uninstalled from Burp).

## Call example

### View proxy history
```json
POST http://127.0.0.1:9876
{"tool": "proxy_history", "params": {"limit": 10, "url_filter": "personalblog"}}
```

### Send request
```json
POST http://127.0.0.1:9876
{"tool": "send_request", "params": {"method": "GET", "url": "https://example.com/api/test"}}
```

### Automated enumeration attack (core function)
```json
POST http://127.0.0.1:9876
{
  "tool": "intruder_attack",
  "params": {
    "url_template": "https://target.com/api/verify?code=@@",
    "method": "POST",
    "from": 0,
    "to": 999999,
    "pad_digits": 6,
    "success_length_not": 176,
    "headers": {"User-Agent": "Mozilla/5.0"}
  }
}
```

### Switch interception
```json
POST http://127.0.0.1:9876
{"tool": "intercept_toggle", "params": {"enable": false}}
```

## Port configuration

Default listening is `127.0.0.1:9876`. If changes are required (e.g. conflict with PortSwigger official MCP extension on the same port):

1. **Burp side**: When starting Burp, pass the JVM parameter `-Dburp.mcp.port=9877`, or set the environment variable `BURP_MCP_PORT=9877`.
2. **Bridge side**: Set the environment variables `BURP_MCP_PORT=9877` and `BURP_MCP_HOST=127.0.0.1` in the MCP client configuration.

The ports on both sides must be consistent. If Burp is not running or the port is unreachable, the bridge will return clear connection error instructions in `tools/list` and `tools/call`.

## Troubleshooting

| Phenomenon | Troubleshooting |
|------|------|
| Burp Output None "[MCP] Server started" | The port is occupied or the extension loading failed, check the Burp Errors panel |
| MCP client reports "Burp MCP not connected" | Confirm that Burp is running and the extension is loaded; confirm that the ports on both sides are consistent |
| Scan returns "requires Burp Professional" | Normal, Community version does not support Scanner API |
| `remove_http_handler` / `remove_proxy_rule` is invalid | `register_*` returns success=true before confirming |

## Source code build (Gradle optional)

```bash
cd burp-mcp-full
gradle jar      # Gradle 8.7+ needs to be installed on the machine
# Output: build/libs/burp-mcp-full.jar
```

> It is recommended to use `build.bat` / `build.sh` (zero dependencies, automatically download jar). Gradle paths are alternatives only.
