# Optional sandbox tool Profile (compare bootstrap-manifest)

> Z3r0 has a complete set of default image tools; reverse-skill**does not bundle the image**. Use this table for "coverage comparison" and optional Docker recommendations.

## reverse-skill The ability to automatically bootstrap

 Source: `skills/scripts/bootstrap-manifest.json` (subject to file):

| Capabilities | Typical scenarios |
|------|----------|
| jadx / apktool / adb / frida / frida-ps | Android |
| r2 / rabin2 | Binary CLI |
| idalib-mcp / idapro | IDA MCP |
| jeb-pro | Commercial Android/ARM decompiler (manual license installation) |
| jshookmcp / reqable-mcp / anything-analyzer / agent-browser | Web/JS/capture/browser |
| ghidra-mcp | Ghidra |
| nmap / seclists / proxycat / burpsuite-mcp / pentestswarm | Penetration |
| binwalk/pwntools/yara | firmware/pwn/malicious |

```powershell
powershell -File skills\scripts\bootstrap-reverse.ps1 -Capability @('jadx','nmap','yara') -StartServices
powershell -File skills\scripts\refresh-tool-index.ps1
```

## Z3r0 is common in sandboxes but  is not automatically installed in this package manifest

| tool | reverse-skill strategy |
|------|-------------------|
| subfinder / amass / httpx / ffuf / nuclei / sqlmap | document installation / Kali script / external MCP;**do not pretend to bootstrap already have**|
| Ghidra GUI full | ghidra-mcp capabilities + manual plug-in steps |
| gdb / pwndbg | platform documentation manually; pwntools can bootstrap |
| hydra / hashcat | manual or Kali |
| JEB Pro | Users install manually after holding a license; third-party MCP bridge must first complete the supply chain review |
| Reqable desktop client | User manual installation; `reqable-mcp` only registers the official fixed version of the MCP runtime |
| SecLists | seclists Capabilities |

## recommends the "Lightweight Docker Combat" profile (optional, non-dependent)

 only when user**himself**has Docker and authorizes lab:

```text
Minimum:nmap + nuclei + sqlmap container or pentestMCP -style image
Mobile: jadx + apktool + frida host
Reverse: host IDA/r2 + tool-index
```

**MUST NOT**requires users to install Z3r0 to use reverse-skill.

## network_profile linkage

Scanning within the  sandbox is still subject to `network_profile` in case `scope.md`:

- `offline` → It is not recommended to scan the container    externally.  
- `authorized_target_only` → The container can only be opened in_scope  
