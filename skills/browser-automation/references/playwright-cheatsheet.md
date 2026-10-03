# Browser and Desktop Automation Quick Check

> Covers common commands and patterns for Playwright (browser automation) and OpenReverse (Windows desktop automation).
> For penetration testing, reverse engineering, and automated collection scenarios.

---

## Playwright/agent-browser command quick tutorial

### Navigation and life cycle

```bash
# open page
agent-browser open "https://target.com/login"

# Wait for the page to load
agent-browser wait --load networkidle

# Close the browser (must be executed, otherwise the process will leak)
agent-browser close
```

### Page snapshot

```bash
# Complete accessibility tree (for debugging)
agent-browser snapshot

# Interactive elements only (recommended, returns @e1, @e2... references)
agent-browser snapshot -i
```

### Element interaction

```bash
# Click
agent-browser click @e1

# Fill in the text box
agent-browser fill @e2 "admin"

# Character-by-character input (suitable for input boxes with JS monitoring)
agent-browser type @e2 "password123"

# button
agent-browser press Enter
agent-browser press Tab
agent-browser press Escape

# scroll
agent-browser scroll down 500
agent-browser scroll up 300
```

### information acquisition

```bash
# Get element text
agent-browser get text @e1

# Get page title
agent-browser get title

# Get current URL
agent-browser get url
```

### wait strategy

```bash
# Wait for element to appear
agent-browser wait @e1

# Wait for fixed time (milliseconds)
agent-browser wait 2000

# Wait for the network to be idle
agent-browser wait --load networkidle

# Wait for navigation to complete
agent-browser wait --load domcontentloaded
```

---

## Common patterns for penetration testing

### Automated login

```bash
agent-browser open "https://target.com/login"
agent-browser snapshot -i
agent-browser fill @username "admin"
agent-browser fill @password "password123"
agent-browser click @login_button
agent-browser wait --load networkidle
agent-browser get url                    # Confirm whether to jump to the background
```

### XSS Payload Injection

```bash
agent-browser open "https://target.com/search"
agent-browser snapshot -i
agent-browser fill @search_input "<script>alert(1)</script>"
agent-browser click @search_button
agent-browser wait --load networkidle
agent-browser snapshot                   # Check if payload is rendered
```

### Form batch submission (with script)

```powershell
$payloads = @("' OR 1=1--", "<img src=x onerror=alert(1)>", "{{7*7}}")
foreach ($p in $payloads) {
    agent-browser open "https://target.com/form"
    agent-browser snapshot -i
    agent-browser fill @input "$p"
    agent-browser click @submit
    agent-browser wait --load networkidle
    agent-browser snapshot              # Check response
}
agent-browser close
```

### Cookie/LocalStorage extraction

```bash
# Via Playwright API (Node.js script mode)
# agent-browser does not directly expose cookies and needs to use script mode
```

```javascript
// playwright-extract.js
const { chromium } = require('playwright');
(async () => {
    const browser = await chromium.launch();
    const context = await browser.newContext();
    const page = await context.newPage();
    await page.goto('https://target.com');
    
    // Extract cookies
    const cookies = await context.cookies();
    console.log(JSON.stringify(cookies, null, 2));
    
    // Extract localStorage
    const storage = await page.evaluate(() => JSON.stringify(localStorage));
    console.log(storage);
    
    await browser.close();
})();
```

### Screenshot evidence collection

```bash
# agent-browser mode
agent-browser open "https://target.com/admin"
agent-browser wait --load networkidle
# Screenshot functionality depends on agent-browser version
```

```javascript
// playwright script mode
await page.screenshot({ path: 'evidence.png', fullPage: true });
```

---

## Playwright Node.js API quick review

### Basic template

```javascript
const { chromium } = require('playwright');

(async () => {
    const browser = await chromium.launch({
        headless: true,           // Headless mode
        // proxy: { server: 'http://127.0.0.1:8080' } // Use Burp proxy
    });
    const context = await browser.newContext({
        ignoreHTTPSErrors: true,  // Ignore certificate errors
        userAgent: 'Mozilla/5.0 ...',
    });
    const page = await context.newPage();
    
    await page.goto('https://target.com');
    // ... operate ...
    
    await browser.close();
})();
```

### Common selectors

```javascript
// CSS selectors
await page.click('#login-btn');
await page.fill('input[name="username"]', 'admin');

// text selector
await page.click('text=Submit');
await page.click('button:has-text("Login")');

// XPath
await page.click('xpath=//button[@type="submit"]');

// combination
await page.click('form >> input[type="submit"]');
```

### network interception

```javascript
// intercept request
await page.route('**/api/**', route => {
    console.log('API call:', route.request().url());
    route.continue();
});

// Modify request
await page.route('**/api/auth', route => {
    route.continue({
        headers: { ...route.request().headers(), 'X-Admin': 'true' }
    });
});

// intercept response
await page.route('**/api/user', async route => {
    const response = await route.fetch();
    const json = await response.json();
    json.role = 'admin';  // Tamper response
    route.fulfill({ response, json });
});
```

### Wait and Assert

```javascript
// await element
await page.waitForSelector('#result');
await page.waitForSelector('.error', { state: 'visible' });

// Waiting for network requests
const [response] = await Promise.all([
    page.waitForResponse('**/api/login'),
    page.click('#login-btn'),
]);
console.log(response.status(), await response.json());

// Waiting for navigation
await Promise.all([
    page.waitForNavigation(),
    page.click('a[href="/admin"]'),
]);
```

---

## OpenReverse Desktop Automation Quick Check

### Mode selection

| mode | command prefix | suitable scenario |
|------|---------|---------|
| UIA | `openreverse uia ...` | Standard Windows controls (buttons, text boxes, lists) |
| CUA | `openreverse cua ...` | Complex/non-standard GUI (IDA disassembly view, custom rendering interface) |

### UIA mode (structured control manipulation)

```bash
# Start application
openreverse uia launch "C:\Tools\x64dbg\x64dbg.exe"

# Get window tree
openreverse uia tree

# click button
openreverse uia click "Button:Open"

# Fill in the text box
openreverse uia fill "Edit:FilePath" "C:\sample.exe"

# Select menu
openreverse uia menu "File > Open"

# Get control text
openreverse uia get-text "Edit:Output"
```

### CUA mode (visual-driven interaction)

```bash
# Take a screenshot of the current screen
openreverse cua screenshot

# Click screen coordinates
openreverse cua click 500 300

# double click
openreverse cua dblclick 500 300

# Enter text
openreverse cua type "search string"

# button
openreverse cua key "ctrl+g"    # IDA: Go to address
openreverse cua key "F5"        # IDA: Decompile
openreverse cua key "F9"        # x64dbg: Run
```

### Network observation (mitmproxy)

```bash
# Start proxy mode observation
openreverse network start --mode proxy --port 8888

# Start local crawl mode
openreverse network start --mode local --filter "target.exe"

# Get captured requests
openreverse network list

# Export as HAR
openreverse network export har output.har

# stop observing
openreverse network stop
```

---

## Automated portfolio of reverse engineering tools

### IDA Pro automation (OpenReverse + ida-reverse)

```text
Scenario: Batch analysis of multiple samples

1. openreverse cua launch "ida64.exe"
2. For each sample:
a. openreverse cua key "ctrl+o" # Open file dialog box
   b. openreverse uia fill "Edit:FileName" "sample_N.exe"
   c. openreverse uia click "Button:Open"
d. Wait for analysis to complete (polling the IDA title bar)
e. Extract results through ida-reverse MCP tool
f. openreverse cua key "ctrl+w" # Close the database
```

### x64dbg automated debugging

```text
Scenario: Automated breakpoint setting and data collection

1. openreverse uia launch "x64dbg.exe"
2. openreverse cua key "F3" # Open the file
3. openreverse uia fill "Edit:FileName" "target.exe"
4. openreverse uia click "Button:Open"
5. openreverse cua key "ctrl+g"           # Go to address
6. openreverse cua type "0x401000"
7. openreverse cua key "F2" # Set breakpoint
8. openreverse cua key "F9" # Run
9. openreverse cua screenshot # screenshot save status
```

---

## Frequently asked questions and solutions

| Problem | Cause | Solution |
|------|------|------|
| agent-browser does not respond | process leaks | First `agent-browser close`, then open | again
| element reference invalid | The page has been refreshed | Re-`snapshot -i` Get new reference |
| form filling is invalid | JS listens to the input event | Use `type` instead of `fill` |
| HTTPS certificate error | Self-signed certificate | Playwright: `ignoreHTTPSErrors: true` |
| Page loading timeout | Slow network/many resources | Increase timeout or use `domcontentloaded` |
| UIA cannot find the control | The application uses self-drawn controls | Switch to CUA mode |
| CUA click offset | resolution/DPI does not match | screenshot first to confirm coordinates |

---

## Installation and dependencies

### Playwright

```powershell
# Install Node.js (if you don’t have it)
winget install OpenJS.NodeJS.LTS

# Install Playwright
npm install -g playwright
npx playwright install          # Download browser engine

# Install agent-browser CLI
npm install -g agent-browser
```

### OpenReverse

```powershell
git clone https://github.com/zhexulong/openreverse.git
cd openreverse
npm install
npm run init:agents -- --target=all <Project path>

# Optional: CUA runtime
npm run install:cua-runtime
npm run doctor:cua-runtime

# Optional: Network Watch
npm run install:mitmproxy
npm run doctor:network
```

---

## Related resources

| Resource | Description | Link |
|------|------|------|
| Playwright official documentation | API reference | https://playwright.dev/docs/intro |
| OpenReverse | Desktop Automation Framework | https://github.com/zhexulong/openreverse |
| mitmproxy | HTTP/HTTPS proxy | https://mitmproxy.org/ |
| Windows UI Automation | UIA Documentation | https://learn.microsoft.com/en-us/windows/win32/winauto/entry-uiauto-win32 |
