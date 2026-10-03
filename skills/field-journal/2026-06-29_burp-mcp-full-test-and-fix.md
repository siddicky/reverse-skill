# 2026-06-29 burp-mcp-full Full testing and repair

## scene classification
BurpSuite extension development/testing

## Goal Overview
 conducted a full runtime usability test on the burp-mcp-full extension (Burp Suite Professional MCP Full Control, 63 tools), and found and fixed 3 bugs + 1 bridge layer race condition.

## complete execution link

1. static verification: Check Java dispatch table / getToolList() / bridge buildToolDefinitions three places 63 tool consistency
2. compilation: build.bat automated fat-jar packaging (JDK 21, montoya-api 2025.5, gson 2.11.0, nanohttpd 2.3.1)
3. loading: Loading extensions in Burp Suite Professional 2026.4.2, confirm [MCP] Server started
4. runtime test: directly call 127.0.0.1:9876: through node http client in 5 batches
   - First batch: 30 read-only/encoding/query tools (zero side effects)
   - second batch: network sending class (send_request / repeater / intruder, target scanme.nmap.org)
   - third batch: Intruder 7 variant (attack/async/wordlist/pitchfork/cluster_bomb/battering_ram/with_options, small range enumeration)
   - fourth batch:Scope/Configuration/Rules/handler/add_issue/compare
   - fifth batch: crawl + proxy_clear
5. discovered and fixed 3 bugs, and the regression verification passed

## pit record

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| `scan()` request_count is always 0 | AuditConfiguration does not accept seed URL, code is missing addRequest | parses host/port/path from url, constructs GET HttpRequest and feeds activeAudit.addRequest() | 2h (including verification) |
| `send_to_intruder()` reports HttpRequest must have an HttpService | uses HttpRequest.httpRequest(raw) without service overload | adds buildRequestWithService(): Regularly parses host/port/https → HttpService from the Host header, uses httpRequest(HttpService, raw) reload | 20min |
| `set_upstream_proxy()` Missing parameter space pointer NPE | params.get("proxy_host") returns null → .getAsString() NPE | Adds null: if (!params.has("proxy_host")) Returns clear error | 5min |
| mcp-bridge.js API asynchronous race condition: the 4th of 4 fast requests lost the response | stdin close when process.exit(0) kills the unfinished HTTP request | pending counter + stdinClosed flag → exit after all requests are completed | 1h (including mock test) |
| curl HTTP_CODE=000 Unable to detect the port | curl is banned by the sandbox on this machine | Use the node http module for detection | 5min |
| Montoya API Audit package path inference error | Based on online javadoc inference Audit is under the scanner package | javap decompiles the real montoya-api-2025.5.jar and confirms that it is under the scanner.audit package | 30min |
| File encoding problem causes the Edit tool to fail to match | UTF-8 with BOM The Chinese content is displayed in the terminal with mis-encoding | Use Python for replacement, specify utf-8-sig | 10min |

## toolchain found

- montoya-api version 2025.5 Audit in `burp.api.montoya.scanner.audit.Audit` (not scanner.Audit)
- AuditConfiguration factory method does not accept seed URL, the seed must be fed into  through Audit.addRequest(HttpRequest)
- HttpRequest.httpRequest(raw) No service overload is enough for Repeater, but Intruder requires HttpService
- Intruder.sendToIntruder(HttpRequest) requires that the request must be appended with service
- api.burpSuite().version()'s major()/minor()/build() has been removed in 2025.5 deprecation→removal, you need to use buildNumber()/edition()/toString() instead
- send_request goes to http.sendRequest(), but does not enter proxy history
- The local curl is blocked by the sandbox, so you need to use node http to detect
- IDA MCP port is not fixed 13337 (incremented between instances), but Burp MCP port is configurable through system properties/env, and the port is fixed

## key code/command

### full test script mode
```javascript
const http = require('http');
function call(tool, params={}, timeoutMs=30000) {
  return new Promise((resolve) => {
    const body = JSON.stringify({tool, params});
    const req = http.request({hostname:'127.0.0.1',port:9876,path:'/',method:'POST',
      headers:{'Content-Type':'application/json','Content-Length':Buffer.byteLength(body)}}, (res)=>{
      let d=''; res.on('data',c=>d+=c); res.on('end',()=>{ try{resolve(JSON.parse(d));}catch(e){resolve({__raw:d.slice(0,200)});} });
    });
    req.on('error', e => resolve({__err: e.message}));
    req.on('timeout', () => { req.destroy(); resolve({__timeout:true}); });
    req.setTimeout(timeoutMs);
    req.write(body); req.end();
  });
}
```

### buildRequestWithService (core fix)
```java
private HttpRequest buildRequestWithService(String rawRequest) {
    java.util.regex.Matcher m = java.util.regex.Pattern.compile(
            "(?im)^Host:\\s*([^:\r\n]+)(?::(\\d+))?\\s*$").matcher(rawRequest);
    if (!m.find()) return HttpRequest.httpRequest(rawRequest);
    String host = m.group(1).trim();
    boolean isHttps = rawRequest.contains("https://") || rawRequest.contains(":443");
    int port = m.group(2) != null ? Integer.parseInt(m.group(2))
              : (isHttps ? 443 : 80);
    HttpService svc = HttpService.httpService(host, port, isHttps);
    return HttpRequest.httpRequest(svc, rawRequest);
}
```

### bridge layer race condition fix (mcp-bridge.js)
```javascript
let pending = 0;
let stdinClosed = false;
rl.on('line', async (line) => { ... pending++; ... finally { pending--; if (stdinClosed && pending === 0) process.exit(0); } });
rl.on('close', () => { stdinClosed = true; if (pending === 0) process.exit(0); });
```

### scan() seed repair
```java
//Feed audit after constructing GET seed request from URL
java.net.URL u = new java.net.URL(url);
String host = u.getHost();
boolean isHttps = "https".equalsIgnoreCase(u.getProtocol());
int port = u.getPort() > 0 ? u.getPort() : (isHttps ? 443 : 80);
String path = (u.getPath() == null || u.getPath().isEmpty()) ? "/" : u.getPath();
String pathQuery = u.getQuery() != null ? path + "?" + u.getQuery() : path;
HttpService svc = HttpService.httpService(host, port, isHttps);
HttpRequest seedReq = HttpRequest.httpRequest(svc,
    "GET " + pathQuery + " HTTP/1.1\r\nHost: " + host + "\r\nConnection: close\r\n\r\n");
activeAudit.addRequest(seedReq);
```

## 's suggestions for improving this package

- routing matrix has covered BurpSuite MCP, no need to modify
- `burpsuite-mcp-guide.md` Update log added (3 fixes + bridge layer + full verification results)
- Tool table has been updated Scanner (scan new mode parameter) and Intruder (send_to_intruder Host header requirement)
- No need to add new bootstrap entries (the compilation script build.bat is self-contained)
- IDA The MCP port is not fixed. It is recommended to indicate  in the MCP service management table.

## Reusable pattern/script snippet

- 63 tool full usability test script mode (see key code above). Suitable for regression testing of any HTTP-based MCP extension.
- buildRequestWithService mode: Parse HttpService from Host header. Applicable to all scenarios in Montoya API where HttpRequest + HttpService need to be constructed from the original request.

## evolution action
- [x] updated the routing matrix (routing has been covered, no need to modify)
- [ ] updated tool-index (use .template, no modification required)
- [ ] updated bootstrap-manifest (no new tools)
- [x] updated the sub-skill document (burpsuite-mcp-guide.md added update log)
- [x] added pitfall record (this entry)
- [ ] No need to update

## Environmental information
- OS: Windows 11 Pro for Workstations 10.0.26200
- tool version: JDK 21.0.11+10 / Burp Suite Professional 2026.4.2 (20260402000047704)
- target platform: montoya-api 2025.5 / gson 2.11.0 / nanohttpd 2.3.1
- test target: scanme.nmap.org (authorized test site)

## redaction requirements
The  test target is the public test site scanme.nmap.org, no redaction is required. Does not include real domain name/IP/Token/user name.

## Index synchronization (last step before submission)

After  finishes writing this log, it must be updated simultaneously with `_index.md`:

1. Add a new line (including date and keywords) in the corresponding section of "Classification by Scenario"
2. updates the count of "cumulative statistics" and the "last updated" date

---
<!-- [Community Contribution] After completion, ask the user whether to PR to the main repository. For the process, see CONTRIBUTE-BACK.md -->
