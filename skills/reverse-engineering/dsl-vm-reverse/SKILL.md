---
name: dsl-vm-reverse
description: Reverse JavaScript-based custom DSL/VM interpreters, non-standard WASM-like runtimes, and risk-control engines. Use when analyzing IIFE or switch-based opcode dispatchers, extracting instruction tables, recovering bytecode semantics, capturing VM state at runtime, or reconstructing execution flow.
---

# 🔄 DSL custom virtual machine reverse engineering (DSL VM Reverse Engineering)

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Confirm that the current task is a custom JS opcode VM/risk control engine, not standard WASM or ordinary webpack
2. `NOW`: `case-init` until `scope.md` is ready; use `offline` / `lab` for offline samples
3. `ACT`: Classify files from "3. Universal reverse workflow" Phase 1, don't stop at the directory

> Used to reverse the custom WASM virtual machine/risk control engine implemented based on JavaScript

---

## Table of contents

- [1. Scope of application ](#1-scope-of-application)
- [2. DSL VM identification feature ](#2-dsl-vm-identification-characteristics)
- [3. Universal reverse workflow ](#3-universal-reverse-workflow)
- [4. Opcode extraction and classification ](#4-opcode-extraction-and-classification)
- [5. Runtime capture scheme ](#5-runtime-capture-solution)
- [6. Common status codes ](#6-common-status-codes)
- [7. Skill Self-Check Checklist ](#7-skill-self-check-list)

---

## 1. Scope of application

Use this skill when the target file meets any of the following characteristics:

| # | Characteristics | Description |
|---|------|------|
| 1 | Starting with IIFE + a large number of single-letter variable names | `!function(){var U=void 0,y=parseInt,E0=Function,...}` |
| 2 | contains `DG()` or similar function containing switch-case loop | interpreter main loop, `d[7]&31` decoding opcode |
| 3 | Large file (500KB+) but zero bytes account for < 1% | Non-standard WASM, pure JS |
| 4 | contains `C[number]` constant table reference | `C[9][xxx]` function table/string table |
| 5 | Single line of compressed code | 583KB Single line, obfuscated variable name |

### Exclusion rules

| Condition | Non-original skill | Go to |
|------|-----------|------|
| files start with `\x00asm` | standard WASM binary | `reverse-engineering/languages.md` |
| File contains WASM magic bytes `Uint8Array([0,97,115,109])` | Embedded WASM | Extract the .wasm file and open it in IDA/Ghidra |
| standard Webpack packaging (`function(e,t,n){...}`) | ordinary JS | `js-reverse/` |
| Zero byte ratio > 20% | WASM binary | `reverse-engineering/languages.md` |

---

## 2. DSL VM identification characteristics

### Code features

```javascript
// Feature 1: IIFE entry, single-letter variables map to numeric constants
!function(){
    var U=void 0, y=parseInt, E0=Function, AN=Uint8Array;
    var E=15, l=10, m=12, x=16, S=13, $=11;
    // Numeric constants are mapped to variable names, replacing the original numbers
    ...
}

// Feature 2: Interpreter main loop DG()
function DG(C, d, ...) {
    var d = [];  // Array simulation WASM stack/locals
    for (d[7] = x; d[7] !== U;) {
        var aE = d[7] & 31;         // Low 5 bits = opcode
        var O = d[7] >> 5 & 31;      // High 5 bits = sub-operation
        switch (aE) {
            case 0: /* ... */ d[7] = 612; break;
            case 1: /* ... */
            // ...N cases
        }
    }
}

// Feature 3: Constant table C[9] stores function index and string
// C[9][0] = ["pc"] → function parameter description
// C[9][667] = "string" → string constant
// C[9][x] = number → function index

// Feature 4: W(C[index], null, ...) calling mode
// W = Function.prototype.call.bind(call)
// All built-in functions are called via C[index] index

// Feature 5: Instruction encoding format
// d[7] = opcode(bit 0-4) | subop(bit 5-9) | operand(bit 10+)
```

### Opcode encoding format

Each instruction is encoded as a 32-bit integer:

```
bit 0-4:   opcode (0-N)
bit 5-9:   sub-operation (0-31)
bit 10-31: operand/immediate value

Decode:
  aE = d[7] & 31        → opcode
  O  = d[7] >> 5 & 31   → sub-operation
  d[other] = d[7] >> 10  → operand
```

---

## 3. Universal reverse workflow

### Phase 1: Document classification (5 minutes)

```bash
# Check if it is a DSL VM
python3 << 'EOF'
with open('target.js', 'rb') as f:
    head = f.read(100)

# 1. Check WASM magic words
if head[:4] == b'\x00asm':
    print("Standard WASM binary")
    exit()

# 2. Check the proportion of zero bytes
data = open('target.js', 'rb').read()
zero_pct = data.count(b'\x00') / len(data) * 100
print(f"Zero byte proportion: {zero_pct:.1f}%")

if zero_pct > 20:
    print("WASM binary")
elif head[:2] == b'!f':
    # Check single letter variable pattern
    if b'var U=void 0' in head or b'U=void 0,y=parseInt' in head:
        print("→ DSL VM!")
    else:
        print("Normal JS IIFE")
EOF
```

### Phase 2: Variable mapping table extraction (10 minutes)

```python
import re

with open('target.js', 'r', errors='replace') as f:
    s = f.read()

# Extract the first 2000 characters of the var X=number mapping
mappings = re.findall(r'var\s+(\w+)\s*=\s*(\d+)', s[:2000])
print('Constant mapping:')
for name, val in mappings:
    print(f"  {name:4s} = {val:3d} (0x{int(val):02x})")
```

### Phase 3: Opcode extraction and classification (15 minutes)

```python
# 1. Extract all cases
all_cases = re.findall(r'case\s+(\d+):', s)
unique = sorted(set(int(c) for c in all_cases))

print(f"Total cases: {len(all_cases)}")
print(f"unique opcode: {len(unique)} items: {unique}")

# 2. Classify each opcode
for op in unique:
    idx = s.find(f'case {op}:')
    snippet = s[idx:idx+200]
    if 'd[7]=' in snippet:
        op_type = 'BRANCH'
    elif 'return' in snippet:
        op_type = 'RETURN'
    elif 'W(C[' in snippet:
        op_type = 'CALL'
    elif 'new' in snippet:
        op_type = 'ALLOC'
    elif 'try' in snippet or 'catch' in snippet:
        op_type = 'EXCEPTION'
    else:
        op_type = 'ARITH/STORE'
    print(f"  opcode {op:2d}: {op_type}")
```

### Phase 4: Constant Table Analysis (30 minutes)

```python
const_refs = re.findall(r'C\[9\]\[(\d+)\]', s)
unique_refs = sorted(set(int(x) for x in const_refs))

print(f"C[9] References: {len(unique_refs)} indexes")
print(f"Range: {min(unique_refs)} - {max(unique_refs)}")

# Analyze context for each reference
for ref in unique_refs[:20]:
    idx = s.find(f'C[9][{ref}]')
    ctx = s[max(0,idx-50):idx+80]
    clean = ''.join(c if c.isprintable() else ' ' for c in ctx)
    print(f"  C[9][{ref}] → {clean}")
```

### Phase 5: Export function tracing (1-2 hours)

Exported functions (such as `getToken`) are located via the following paths:

```
1. Find `AWSCInner.register()` or a similar registration call
2. Identify the registered module and factory function
3. Find the object returned by the factory function → exported function definition
4. If the function name is absent from the JS → it is stored as bytecode in the C[9] constant table
5. Trace the call chain:
   AWSCInner._modules['fy'].getToken()
   → W(C[function index], null, ...)
   → DG() interpreter executes the encoded instruction sequence
```

### Phase 6: Runtime injection (if pure static analysis is not enough)

```javascript
// Inject a minimal AWSC-compliant environment
const fakeEnv = {
    AWSCInner: {
        _modules: {},
        register(name, moduleName, factory) {
            this._modules[moduleName] = factory();
        }
    }
};

// Execute DSL VM code
dslVmCode();

// Get export
const token = fakeEnv.AWSCInner._modules['fy'].getToken({});
```

---

## 4. Opcode extraction and classification

### Refer to the opcode comparison table (based on existing cases)

| Opcode | Operation Type | Characteristics |
|--------|---------|------|
| 0 | **BRANCH** | `d[7]=xxx` Unconditional jump |
| 1 | **CALL** | `W(C[Y],null,function(){...})` Embedded function call |
| 2 | **ARITH** | `d[4]=0`, `d[7]=72` Variable assignment |
| 3 | **ARITH** | `d[0]=d[1][C[x]]`, `d[5]=d[0]<d[3]` Comparison operation |
| 4 | **STORE** | `d[8]=d[5]in d[4]` Property access/existence check |
| 5 | **ARITH** | `d[8]=d[4]-d[8]` Arithmetic operation |
| 6 | **RETURN** | `return gV`, `throw` Return/throw exception |
| 7 | **ALLOC** | `d[6]=[]`, `d[6][C[8]](...)` push operation |
| 8 | **BRANCH** | `d[7]=d[k]?512:425` Conditional jump |
| 9 | **STRING** | `d[6][C[t]]=d[m]`, `new fh(...)` Regular |
| 10 | **ALLOC** | Function parameter preparation, call stack creation |
| 11 | **STRING** | `new fh("\\s",d[5])` Regular matching |
| 12 | **STORE** | `P[d[9]]=d[4][C[H]](d[3])` Data transfer |
| 13 | **CALL** | `C[9][113]=d[9]` module initialization |
| 14 | **STRING** | `d[8]=d[9]+d[m]` String concatenation |
| 15 | **RETURN** | `return EL;` function returns |
| 16 | **ALLOC** | `var r,P,Z,B...` Local variable declaration |
| 17 | **ALLOC** | `(Z=[])[C[8]](69,T,445)` Static array initialization |
| 18 | **TABLE** | function table/type table initialization |
| 19 | **EXCEPTION** | `try{for(var RK=x;...` try-catch loop |
| 20 | **DOM** | `Is[d[o]]` DOM operation |
| 21 | **STORE** | Safely obtain global/object properties |
| 22 | **STRING** | `new fh(r,v)` String/regular processing |
| 23 | **BRANCH** | `try...catch` Safe acquisition + conditional jump |
| 24 | **CALL** | `W(C[2],null,8,z,FL)` Multi-parameter function call |
| 25 | **EXCEPTION** | `try{...}catch(C){...}` Exception capture + jump |

---

## 5. Runtime capture solution

### Solution A: Selenium + CDP native events (recommended, highest success rate)

```python
from selenium import webdriver

driver = webdriver.Chrome()

# Inject anti-detection
driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {
    "source": r"""
        Object.defineProperty(navigator, 'webdriver', {get: () => false});
        Object.defineProperty(navigator, 'plugins', {get: () => [1,2,3,4,5]});
        Object.defineProperty(navigator, 'languages', {get: () => ['zh-CN','zh','en']});
    """
})

# Send CDP native mouse events
driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
    "type": "mousePressed",
    "x": 549.5, "y": 441.2,
    "button": "left", "buttons": 1,
    "clickCount": 1, "pointerType": "mouse"
})
```

### Option B: Playwright Headless Browser

```javascript
const { chromium } = require('playwright');

async function run() {
    const browser = await chromium.launch();
    const page = await browser.newPage();

    // Intercept network requests
    await page.route('**/api/**', async route => {
        await route.continue_();
    });

    await page.goto('https://target-page.com');

    // Wait for DSL VM to initialize
    await page.waitForFunction(() => {
        return window.AWSCInner &&
               window.AWSCInner._modules &&
               window.AWSCInner._modules['fy'];
    });

    // perform operations
    await page.mouse.move(500, 400);
    await page.mouse.down();
    // ... sequence of operations
    await page.mouse.up();
}
```

### Option C: Pure protocol verification (very low success rate)

> The token generated by the DSL VM is usually strongly bound to the browser context (TLS JA3 fingerprint, IP, cookie, request header, etc.), and the server can detect context mismatch after leaving the browser. **Pure protocol solution is not recommended**.

---

## 6. Common status codes

| Code | Meaning | Processing |
|------|------|------|
| 0 | **Verification passed** ✅ | Remove sessionId + sig |
| 300 | **Risk control interception** | is intercepted and cannot pass |
| 8778 | **Verification failed, need to retry** | Retry operation |
| 8776 | **The operation is too fast, need to retry** | Increase the delay and try again |
| 69634 | **General failure** | Check whether the parameters are correct |

---

## 7. Skill self-check list

- [ ] Have I done DSL VM identification (IIFE + single letter variables + DG() interpreter)?
- [ ] Did I extract the variable mapping table (`var X=number`)?
- [ ] Did I extract the opcode list and classify it?
- [ ] Did I analyze the reference range of constant table C[9]?
- [ ] Have I located the exported function registration point?
- [ ] Have I tried a runtime injection scenario when pure static analysis is not enough?
- [ ] Is the field-journal written back after the task is completed?
- [ ] Did you discover new tools/scenarios → update routing.md?

---

## Route registration

| type | routing |
|------|------|
| **Target type**: WASM / DSL VM / Custom instruction set | `reverse-engineering/dsl-vm-reverse/SKILL.md` |
| **User Intent**: "DSL VM / Risk Control Engine Reverse" | This skill |
| **Toolchain**: Playwright / Selenium CDP | Browser injection solution |

### paths cross

```
DSL VM reverse engineering path:
  reverse-engineering/dsl-vm-reverse/ → Phases 1–6 workflow
  ↓ If runtime data capture is needed
  browser-automation/ → Playwright/Selenium CDP
  ↓ If the API protocol layer needs analysis
  js-reverse/ → Observe→Capture→Rebuild
```
