# IDA ↔ reverse-skill docking (portable)

This page is a general procedure and does not contain the absolute path to a specific machine. The native readiness report is left at`LOCAL-READINESS.md`(gitignore) in the root of the repository.

## target form

| item | convention |
|----|------|
| IDA installation directory | environment variable`IDADIR`(there are`ida.exe`or`ida.dll`in the directory) |
| HTTP MCP | `http://127.0.0.1:13337/mcp` |
| client server name | Only **`idapro`** (do not register`ida-pro-mcp`at the same time) |
| starts |`scripts/start.ps1`(`--unsafe`, no`?ext=dbg`) |
| Open library | Prioritize large files`scripts/open.ps1`, do not directly adjust`idb_open`| through some clients

If two MCP names point to the same 13337, the tool will be registered twice and compete with the idalib worker for the port.

## Install

```powershell
setx IDADIR "<your IDA installation directory>"

# You must use mrexodia/ida-pro-mcp, do not install PyPI's ida-mcp
python -m pip install "git+https://github.com/mrexodia/ida-pro-mcp.git"

# Activate idalib (path adjusted to native IDA)
python "<IDADIR>\idalib\python\py-activate-idalib.py" -d "<IDADIR>"

# Install plug-in + client configuration
python -m ida_pro_mcp --install --transport streamable-http --scope global
```

## Start up and keep alive

The MCP entry for`type: http`will not pull up the process on its behalf. 13337 When there is no monitoring, all clients report errors.

| script | function |
|------|------|
|`scripts/start.ps1`| If healthy,`OK:<n>:reuse`and refresh last-healthy; the port is listening but the RPC timeout is considered busy and will not be killed; only replace the managed supervisor when no one is listening,`py_eval`is missing, or tools/list fails continuously for more than 3 minutes (and there is no`opening.lock`); never kill`ida.exe`|
|`scripts/watchdog.ps1`| Every minute inspection; health reuse; GUI /`open.ps1`Open library lock / last-healthy less than 3 minutes → reuse; **tools/list Continuous failure for more than 3 minutes`-Force`** |
|`scripts/recover.ps1`| Immediately`-Force`restart supervisor (do not kill`ida.exe`). When the HTTP client marks`idapro`as error, use this |
|`scripts/install-autostart.ps1`| Register scheduled task`reverse-skill-ida-mcp`(login + every minute) |
|`scripts/start-gui.ps1`| Open GUI plug-in when idalib license fails |
|`scripts/open.ps1`| HTTP directly adjusts`idb_open`, bypassing some client schema verification |

Log:`%LOCALAPPDATA%\reverse-skill\ida-mcp\supervisor.log`and`watchdog.log`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "skills\ida-reverse\scripts\start.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "skills\ida-reverse\scripts\open.ps1" -Path "C:\path\to\target.exe" -TimeoutSeconds 600
powershell -NoProfile -ExecutionPolicy Bypass -File "skills\ida-reverse\scripts\install-autostart.ps1"
```

When the GUI occupies 13337 but does not return the packet for a while,`start.ps1`outputs`WARN:gui_busy`and exits to avoid killing the IDA being analyzed.

## client

All point to Streamable HTTP:`http://127.0.0.1:13337/mcp`, server name`idapro`.

You must open a new session after changing the configuration. If the port of Cursor is not listening when it is started, it will not automatically reconnect if the service is pulled up afterwards. It needs to be refreshed manually in the MCP panel.

## Known points to note

1. System32 files:`open.ps1`will be copied to the temporary path (output with`(temp copy)`)
2. `idb_open`Do not adjust directly through MCP of some clients
3. `start.ps1`takes priority over`python -m ida_pro_mcp.idalib_supervisor`, which is more stable than`.cmd`packaging
4. When the formal installation coexists with the desktop carrying bag,`IDADIR`shall prevail.
5. Do not add`?ext=dbg`(the debugger tool is not exposed by default)
