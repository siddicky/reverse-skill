# OLLVM Deobfuscation / Obfuscator-LLVM Deobfuscation

> OLLVM decryption workflow for APK .so, ELF binary and control flow flattening scenarios.
> tool and variant information is based on community active project survey in 2026, not training memory.
> is suitable for: Android NDK reinforcement, CTF reverse engineering, packed .so analysis, and commercial obfuscator confrontation.

---

## 0. Quick decision: Which tool should I use?

According to your environment and judgment of the target confusion type, you can directly choose:

| Your situation | Preferred tool | Alternative | Description |
|---------|---------|------|------|
| I have IDA Pro 7.5-7.7 + Hex-Rays and want to flatten |**obpo-plugin**| d810-ng | obpo using microcode + data flow + Hybrid execution, the strongest effect, but cloud plug-in (requires Internet connection, core closed source) |
| I have IDA Pro (any newer version) and want local one-stop deobfuscation |**d810-ng**| D-810 original | local, open source, integrated Z3, supports OLLVM/Tigress/Hodur/Approov multiple variants |
| has Binary Ninja |**ollvm-breaker**| — | for Android .so actual combat (libvdog and other reinforcement samples) |
| No IDA/BN, pure script, target x86/x64 |**ollvm-unflattener**(Miasm) | angr deflat | Miasm-based symbolic execution, BFS multi-layer processing |
| No IDA/BN, pure script, target x86/x64 |**ollvm-unflattener**(Miasm) | angr deflat | Miasm-based symbolic execution, BFS multi-layer processing |
| Pure Python symbolic execution, CTF scenario |**angr**Deobfuscator | Triton | Does not rely on GUI, scripting |
| targets ARM64 .so, no IDA |**deollvm**(Unicorn) | angr | Unicorn-based ARM64 deflat |
| encounters BR obfuscation (indirect branch) |**DeObfBR**| sets data segment read-only | Goron/Arkari style BR obfuscation can be easily countered by data segment read-only |
| encounters Tigress confusion | d810-ng `UnflattenerSwitchCase`/`UnflattenerTigressIndirect` | — | d810-ng built-in Tigress-specific unflattener |

> **core recommendation:**takes priority over**d810-ng**(local, actively maintained, wide variant coverage).**obpo-plugin**works best when cloud services are available. If both fail, use**angr/Miasm**symbols to perform customized processing.

---

## 1. Modern OLLVM variant ecology (2026 community survey)

OLLVM is much more than the original repository it was in 2017. The following are the currently active obfuscator branches. Before decrypting**, you must first determine which variant**is the target, because the countermeasures of different variants vary greatly:

### 1.1 mixer branch lineage

| variant | baseline LLVM | New features compared to original OLLVM | Counterpoints |
|------|----------|----------------------|---------|
|**Obfuscator**(original) | 3.3~4.0 | sub + bcf + fla (three basic passes) | Standard tools can process |
|**Hikari**| 6~8 | Anti Class Dump, Function Call Obfuscate, Function Wrapper, Indirect Branching, Split BB, String Encryption | Need to decrypt the string first + fix indirect jump |
|**Hikari-LLVM15**| 15~19 | + Anti Debugging, Anti Hook, Constant Encryption | is closed source; Constant Encryption increases the difficulty of static analysis |
|**goron**| 7~10 | Indirect Branch/Call/GlobalVariable | ⚠️ Goron style indirect obfuscation can be easily countered by "setting data segment read-only" |
|**Arkari**(komimoe/Hikari) | 14~latest | Based on goron, continuously maintained | is the same as goron, the data segment can only be partially read to counter |
|**Pluto**| 14 | MBA Obfuscation, Random CF, Split BB,**Trap Angr**(Specialized pit angr) | ⚠️ Trap Angr pass will let angr symbol execution fails, you need to change tools or bypass traps |
|**Polaris**(formerly Pluto) | 16 | Alias Access, Indirect Branch/Call, String Encryption, Merge Function, Linear MBA, Dirty Bytes Insertion, Function Splitting, Junk Insertion | Comprehensive Hikari+Pluto, the most difficult, requires layered processing |
|**O-MVLL**| open-obfuscator | Python driver pass manager; Anti Hooking, Arithmetic(MBA), BB Duplicate, CF Breaking, Function Outline, Indirect Branch/Call, Opaque Constants | Modern Android Commonly used for reinforcement, Python configuration is easy to customize |
|**amice**(Rust) | Rust implements the full set of | + VM Flatten, Instruction Virtualization, Delayed Offset Loading, Parameter Aggregation | contains VMization and requires VM handler restoration instead of simple deflat |
|**VMP is**(SmallVmp/VMPilot/xVMP/VMPacker) | — | instruction virtualization |**does not belong to the OLLVM category**, requires VM reverse, reference VM special tool |

### 1.2 Key judgment clue

- **Trap Angr**(Pluto/Polaris): If angr explodes while running or explodes along the path, it is suspected that the target used Trap Angr pass → use d810-ng or Unicorn dynamic method  instead
- **Goron/Arkari indirect jump**: If the distributor uses indirect jump (BR x8 instead of switch), first try to set the relevant data segment to read-only, the indirect jump target often becomes statically solvable
- **Constant Encryption**(Hikari-LLVM15/Polaris/O-MVLL): Constants are decrypted at runtime, pure static cannot see the real value → Unicorn is required to dynamically perform decryption stub
- **VM Flatten**(amice): The control flow becomes a VM dispatch loop,**should not be treated as an ordinary fla to process**, you need to first identify the VM handler table

---

## 2. OLLVM confusion type detection

OLLVM Identification features of the three core passes:

### 2.1 Control Flow Flattening / `fla`

**IDA View characteristics:**
- The function entry first jumps to the only dispatcher block
- The main logic of is split into multiple basic blocks, and the end of each block jumps back to the distributor
- The dispatcher determines the next block to execute  through the**state variable**(state variable)
- huge `switch` structure, there is no logical relationship between each case

```
Original:             OLLVM flattened:
  block_A               entry -> dispatcher
  block_B                 ↓
  block_C              state_machine:
                         switch(state):
                           0 → block_A
                           1 → block_B
                           2 → block_C
```

**variant form (various dispatchers recognized by d810-ng):**
- O-LLVM: switch/if-chain + state variable
- Tigress: `m_jtbl` (switch-case) or `m_ijmp` (indirect jump, requires `goto_table_info` configuration)
- Hodur (PlugX): Nested `while(1)` state machine, `jnz state, #CONST`,**without switch dispatcher**
- Approov: `while(v8 != C)`, status constants are concentrated in `0xF6000–0xF6FFF`

### 2.2 False Control Flow (Bogus Control Flow / `bcf`)

- inserts**unreachable fake branch**between each real branch
- false branch is protected with**opaque predicate**(condition is always true/constantly false, but static analysis cannot directly prove)
- A lot of dead code expands the function volume

```c
//Classic opaque predicate: x(x+1) must be an even number, the compiler cannot prove it
if (x * (x + 1) % 2 == 0) {
    //real logic
} else {
    //Unreachable junk code
}
```

### 2.3 Instruction Substitution (Instruction Substitution / `sub`) → MBA

- Simple arithmetic/bit operations replaced by equivalent complex expressions (MBA, Mixed Boolean-Arithmetic)

```
a + b  →  (a ^ b) + 2*(a & b)
a ^ b  →  (a | b) - (a & b)
a - b  →  a + (~b) + 1
```

### 2.4 Quick classification table

| Confusion type | IDA feature | Main countermeasure |
|---------|---------|------------|
| fla (flatten) | huge switch + distributor | obpo / d810-ng / deflat |
| bcf (false control flow) | unreachable branch + dead code | d810-ng opaque predicate removal / symbolic execution |
| sub/MBA | Complex arithmetic expression | d810-ng MBA simplifyr / SiMBA (Z3) |
| fla + bcf + sub | Full top, greatly expanded |**layered deobfuscation (first bcf then fla then sub)**|

---

## 3. Detailed explanation of mainstream tools (community active project)

### 3.1 obpo-plugin — The strongest effect, cloud plug-in

> [obpo-project/obpo-plugin](https://github.com/obpo-project/obpo-plugin) · 629⭐ · 2026-06 Active

 is a pseudocode optimizer based on Hex-Rays**microcode**, using**data flow tracing + program slicing + hybrid execution (concolic)**to reconstruct flattened control flow. The effect is recognized by the community as one of the strongest.

**Key Features:**
- operates at the microcode layer and directly optimizes the decompiled output (not changing ASM)
- supports IDA 7.5.0 / 7.6.0 / 7.7.0 + Hex-Rays
- architecture: ARM, ARM64, x86, x86_64, PowerPC, PowerPC64, MIPS (7.6/7.5)
- **cloud plug-in**: The target function binary will be uploaded to obpo-server for processing (core closed source, plug-in free and open source)
- server is maintained at its own expense, timeout is 600s,**prohibits multi-threaded/malicious calls to**

**installation and use:**
```text
1. Download obpo_plugin.py and obpoplugin directory
2. Copy to IDA plugins path
3. Restart IDA and open the target binary
4. Locate the dispatcher block (dispatcher) in the CFG, which usually looks like this:
[Screenshots refer to the warehouse assets/dispatchblock.png]
5. Right click → OBPO → Mark and process function
6. Refresh the decompiler after processing is completed
7. New distribution blocks can continue to be marked according to decompilation changes (iterative processing of nested fla)
```

**applicable scenarios and restrictions:**
- ✅ Standard and nested fla, good effect
- ⚠️ Requires internet connection, use sensitive samples (internal undisclosed vulnerabilities, commercial secrets) with caution - the binary will be uploaded to
- ⚠️ The server may be down, relying on the author to maintain
- ❌ cannot resolve all confusions (expressly stated by the author)

### 3.2 d810-ng — The local one-stop choice

> [w00tzenheimer/d810-ng](https://github.com/w00tzenheimer/d810-ng) · 223⭐ · 2026-06-26 Update

Modern maintained/refactored version of D-810 (Next Generation). Locally running, open source, integrated**Z3 SMT**solver with the widest range of variants.

**core capabilities (organized according to d810-ng README):**

*Instruction level optimization: *
| Category | Description |
|------|------|
| MBA simplification | `(a+b)-2*(a&b) => a^b`, Z3 validated DSL rules |
| Hacker's Delight | Bitwise equivalent (from Hacker's Delight book) |
| O-LLVM patterns | Obfuscator-LLVM dedicated MBA pattern |
| Constant folding | 22 constant simplification rules |
| Predicate simplification | Opaque predicate removal (setz/setnz/lnot/smod) |
| Z3 rules | Use SMT to solve | when template matching fails
| Hodur-specific | PlugX (Hodur) MBA pattern of malware |

*Control Flow Unflattener (categorized by target obfuscation): *
| Unflattener | Target | Description |
|------------|------|------|
| `Unflattener` | O-LLVM | standard switch/if-chain + state variable |
| `UnflattenerSwitchCase` | Tigress | Tigress switch-case distribution (`m_jtbl`) |
| `UnflattenerTigressIndirect` | Tigress | Tigress indirect jump (`m_ijmp`), requires `goto_table_info` configuration |
| `HodurUnflattener` | Hodur (PlugX) | nested `while(1)` + `jnz state, #CONST`, no switch |
| `BadWhileLoop` | Approov | `while(v8 != C)`, the status constant is in 0xF6000–0xF6FFF |
| `UnflattenerFakeJump` | General | removes the conditional jump of constant true/constant false |
| `SingleIterationLoopUnflattener` | residual | cleanup `INIT == CHECK` and a single cycle of `UPDATE != CHECK` |
| `UnflattenControlFlowRule` (experimental) | general | CFG unflattener based on path emulation |

**installation and use:**
```text
1. clone d810-ng
2. Install dependencies (including Z3)
3. Copy to IDA plugins directory
4. Press Ctrl-Shift-D in IDA to load the plug-in
5. Check the rule set to apply in the GUI
6. Apply the objective function
```

**Why choose d810-ng instead of the original D-810:**
- original D-810 has been less maintained
- d810-ng has CI testing, refactored code, and new Tigress/Hodur/Approov-specific unflattener
- integrates Z3, and falls back to SMT for solution when template matching fails, with a higher success rate

### 3.3 ollvm-unflattener — Miasm symbolic execution, pure script

> [cdong1012/ollvm-unflattener](https://github.com/cdong1012/ollvm-unflattener) · 265⭐ · 2026-06 Active

 is based on the**Miasm**symbolic execution engine, does not rely on IDA/BN, and is a pure Python command line.

**Features:**
- uses Miasm symbolic execution to restore the original control flow (different from MODeflattener's purely static method)
- **BFS Multi-layer processing**: automatically follow the call of the target function and recursively deconfuse
- supports Windows/Linux x86/x64
- outputs the new deobfuscated binary

**installation and use:**
```bash
git clone https://github.com/cdong1012/ollvm-unflattener.git
cd ollvm-unflattener
pip install -r requirements.txt   # miasm, graphviz, keystone-engine

# Basic usage
python unflattener -i <input.bin> -o <output.bin> -t <function_addr> -a
# -a: Automatically follow the call to do multi-layer processing
```

**applies to:**without IDA, targets x86/x64, and requires batch scripting.

### 3.4 ollvm-breaker — Binary Ninja Practical

> [amimo/ollvm-breaker](https://github.com/amimo/ollvm-breaker) · 441⭐

 uses**Binary Ninja**for flattening. The repository comes with Android reinforcement sample `libvdog.so` as a test case, and has fixed functions such as JNI_OnLoad, crazy::GetPackageName, and prevent_attach_one.

**is suitable for:**Binary Ninja users, Android .so actual combat.

### 3.5 deollvm — ARM64 Unicorn

> [GeT1t/deollvm](https://github.com/GeT1t/deollvm) · 34⭐ · 2026-04

 is based on the ARM64 OLLVM deflat of**Unicorn**. Alternative for handling ARM64 .so without IDA.

### 3.6 DeObfBR — BR obfuscation special project

> [Mrack/DeObfBR](https://github.com/Mrack/DeObfBR) · 96⭐ · 2026-06-25

 specifically removes**BR obfuscation**(indirect branch obfuscation, Goron/Arkari style).

**⚠️ Simple countermeasures (from awesome-ollvm):**Goron/Arkari style indirect correlation confusion can be easily countered by setting the data segment to read-only**through**- indirect jump targets often rely on data segments that are writable during runtime. After setting read-only, it becomes statically solvable.

### 3.7 angr — Symbolic execution general framework

```python
import angr

proj = angr.Project("target.so", auto_load_libs=False)
cfg = proj.analyses.CFGFast()
func = proj.kb.functions[0x12345]

# built-in Deobfuscator
deob = proj.analyses.Deobfuscator(func=func)
deob.normalize()
```

**⚠️ Trap Angr pass of Pluto/Polaris:**These two variants specifically write trap to trap angr symbol execution. If the angr path explodes or is abnormal, it is suspected that the target uses Trap Angr → use d810-ng or Unicorn dynamic method instead.

---

## 4. Complete decryption workflow (by scenario)

### 4.1 General decision tree

```
target binary
  ↓
1. Identify OLLVM variants (see Section 1.2 for clues)
├── Original OLLVM / Hikari / O-MVLL → Standard fla/bcf/sub
├── Pluto / Polaris → Pay attention to Trap Angr, avoid angr
├── Goron / Arkari → Try to read-only the data segment first, and then process the BR
  ├── Tigress                        → d810-ng Tigress unflattener
  ├── Hodur (PlugX)                  → d810-ng HodurUnflattener
  └── amice (Contains VM)                  → Not simple fla，need VM handler reduction
  ↓
2. Select tools (see Section 0 Decision Table)
├── With IDA + Internet access + non-sensitive samples → obpo-plugin
├── With IDA + local → d810-ng
├── There is Binary Ninja → ollvm-breaker
  ├── none GUI + x86/x64           → ollvm-unflattener (Miasm)
  ├── none GUI + ARM64             → deollvm (Unicorn) / angr
└── Pure symbolic execution / CTF → angr
  ↓
3. Layered deobfuscation (order is important)
  a) Remove the opaque predicate first (bcf)   → d810-ng opaque predicate removal
  b) Then remove control flow flattening (fla) → unflattener
  c) Finally simplify MBA (sub)       → d810-ng MBA simplifier / SiMBA
  ↓
4. Verification
├── The function volume is significantly reduced?
├── CFG changes from star/radial to chain/tree?
└── Frida hook key function verification logic is correct?
```

### 4.2 Android NDK .so decryption special project

The .so compiled by Android NDK and reinforced by OLLVM is the most common scenario for APK reverse engineering.

**Step 1 — Extract .so:**
```bash
adb pull /data/app/~~/lib/arm64/libnative.so
# or unzip directly from APK: unzip target.apk -d out/ ; find out -name "*.so"
```

**Step 2 — Identify OLLVM and variants:**
```bash
readelf -a libnative.so | grep -E "Size|text" # .text is unusually large but has few functions → High probability OLLVM
# IDA Open to see function characteristics:
#   huge switch → fla
#   unreachable branch → bcf
#   Complex arithmetic → sub/MBA
#   jumps indirectly to BR x8 → Goron/Arkari, the trial data segment is read-only
#   while(1) + jnz state → Hodur, use d810-ng HodurUnflattener
```

**Step 3 — Dedensification (stratification):**
```
a) bcf: d810-ng opaque predicate removal  (or obpo Automatic processing)
b) fla: d810-ng Unflattener / obpo-plugin / deollvm(ARM64)
c) sub: d810-ng MBA simplifier
```

**Step 4 — Frida Dynamic Verification:**
```javascript
//Trace OLLVM state variables, assist deflat to determine the state variable address
const target = Module.findBaseAddress("libnative.so");
console.log("[+] libnative.so @", target);

//Hook under the distributor entry and observe the state change sequence
Interceptor.attach(target.add(0x1234), {  // dispatcher offset
    onEnter(args) {
        //Read status variables (need to determine register/stack location based on decompilation)
        console.log("[state]", this.context.x8);  // hypothesis state exist x8
    }
});
```

### 4.3 CTF scene quick decryption

CTF Usually time is tight, the fastest path is preferred:

```python
#!/usr/bin/env python3
"""CTF OLLVM quick deflat with angr"""
import angr

proj = angr.Project("challenge", auto_load_libs=False)
cfg = proj.analyses.CFGFast()

# Find the largest functions (most likely to be confused)
funcs = sorted(cfg.functions.values(), key=lambda f: f.size, reverse=True)[:5]
for func in funcs:
    print(f"[*] {func.name} @ {hex(func.addr)} size={hex(func.size)}")
    try:
        deob = proj.analyses.Deobfuscator(func=func)
        deob.normalize()
        print(f"    [+] deobfuscated")
    except Exception as e:
        print(f"    [-] failed: {e}")
        # angr failed → suspected Trap Angr → change to d810-ng / Unicorn
```

---

## 5. MBA expression simplified

### 5.1 Common OLLVM MBA mode

```python
# These equations are the simplification targets of the expression generated by OLLVM sub pass
"(a | b) + (a & b)"        # → a + b
"(a | b) - (a & b)"        # → a ^ b
"(a ^ b) + 2*(a & b)"      # → a + b
"(a | b) & ~(a & b)"       # → a ^ b
"~(~a & ~b)"               # → a | b (De Morgan)
```

### 5.2 Tool selection

| tool | method | applicable |
|------|------|------|
|**d810-ng MBA simplifyr**| IDA intra-batch, Z3 verification | preferred, integrated in decompilation process |
|**SiMBA**(`pip install simba-simplifier`) | command line/library | pure expression simplification, batch processing |
|**Arybo**| Signed bit vector | Large number of MBA expressions |
|**Z3 directly solves**| SMT | is the most versatile, when template matching fails |

```python
# SiMBA Example
from simba import simplify_mba
exprs = ["(a | b) + (a & b)", "(a ^ b) + 2*(a & b)"]
for e in exprs:
    print(f"{e}  →  {simplify_mba(e)}")
```

---

## 6. Complete decryption case script

```bash
#!/bin/bash
# OLLVM deobfuscation pipeline (2026 community tools)
# applicable standard OLLVM / Hikari / O-MVLL ruggedized ELF/.so

BINARY=$1

echo "[*] Stage 0: Basic analysis and variant identification"
file $BINARY
readelf -h $BINARY 2>/dev/null | head -5
echo "    → exist IDA Confirmed variant（Refer to Chapter 1 Festival）"

echo "[*] Stage 1: d810-ng Local anti-obfuscation（First choice）"
echo "    IDA → Ctrl-Shift-D load d810-ng"
echo "    Check: MBA + Opaque predicate + Unflattener"
echo "    Apply to target functions"
echo "    save IDB"

echo "[*] Stage 2: obpo-plugin（like d810-ng Insufficient effect and can be connected to the Internet）"
echo "    IDA → Right click dispatcher → OBPO → Mark and process"
echo "    ⚠️ Do not use sensitive samples（Binary upload cloud service）"

echo "[*] Stage 3: none IDA alternative（x86/x64）"
echo "    python unflattener -i $BINARY -o deobf.bin -t <func_addr> -a"

echo "[*] Stage 4: ARM64 .so none IDA alternative"
echo "    deollvm (Unicorn) or angr Deobfuscator"

echo "[+] Done. exist IDA re-analysis verification。"
```

---

## 7. Common pitfalls (community practical summary)

| Problem | Cause | Solution |
|------|------|---------|
| angr path explosion/abnormal exit | Pluto/Polaris's**Trap Angr**pass | replace d810-ng or Unicorn dynamic method |
| obpo-plugin cannot connect | The server is maintained at its own expense and may be down. | is switched to local d810-ng; an issue can be raised in the obpo repository |
| Goron/Arkari indirect jump deflat failure | distributor uses BR x8 instead of switch | First set the data segment to read-only, then use DeObfBR |
| d810-ng The function is still messy after processing | OLLVM customized the pass parameter/seed | First symbolically execute to remove the opaque predicate, and then unflatten |
| Nested fla (multi-layer flattening) is not cleared at one time | obpo/d810-ng Only one layer is cleared at a time |**iterative processing**: Each time the new dispatcher | is marked
| ARM64 .so uses deflat to report errors | The old deflat script only supports x86 | uses d810-ng / obpo (supports ARM64) / deollvm |
| Hikari string cannot be seen | String Encryption pass | Use Unicorn to simulate decryption stub, dump the decrypted string |
| amice target deflat is completely invalid | contains VM Flatten / Instruction Virtualization |**is not OLLVM fla**, requires VM handler restoration (refer to VM reverse engineering) |
| Hodur(PugX) sample does not have switch distributor | nested while(1) + jnz state | Use d810-ng**HodurUnflattener**, do not use ordinary Unflattener |
| Approov No pattern can be seen in the sample status constants | constants are concentrated in 0xF6000–0xF6FFF | Use d810-ng**BadWhileLoop**unflattener |
| Sensitive sample misuse obpo | Binary upload cloud service | Confidential/undisclosed vulnerability sample**only uses local tools**(d810-ng/angr) |
| Frida hook OLLVM function is stuck | The state variable is changed causing an infinite loop | Add a conditional breakpoint at the distributor entry to limit the number of executions |

---

## 8. Tool Cheat Sheet (2026 Community Activity)

| Tool | Platform | Method | Stars/Price | Recent Updates | Open Source | Remarks |
|------|------|------|---------|---------|------|------|
|**obpo-plugin**| IDA | microcode+concolic (cloud) | 629 | 2026-06 | plug-in open source/core closed source | The strongest effect, requires internet connection |
|**ollvm-breaker**| Binary Ninja | BN API | 441 | 2026-06 | ✅ | Android .so actual combat |
|**olvm-unflattener**| CLI | Miasm symbolic execution | 265 | 2026-06 | ✅ | x86/x64, BFS multi-layer |
|**d810-ng**| IDA | microcode+Z3 | 223 | 2026-06 | ✅ |**is the local preferred**, with wide variant coverage |
|**DeObfBR**| — | BR obfuscation project | 96 | 2026-06 | ✅ | Goron/Arkari indirect branch |
|**IDA_Ollvm-unflattener**| IDA | Miasm plug-in version | 90 | 2026-04 | ✅ | ollvm-unflattener's IDA plug-in package |
|**deollvm**| CLI | Unicorn | 34 | 2026-04 | ✅ | ARM64 Special |
|**angr**| CLI | Symbolic execution | — | active | ✅ | generic, suppressed by Trap Angr |
|**SiMBA**| CLI/Library | MBA Simplification | — | — | ✅ | Expression Simplification |
|**Triton**| CLI | Symbolic execution + taint | — | active | ✅ | Dynamic symbolic execution |

---

## 9. Reference link

**obfuscator (for understanding adversarial targets):**
- [obfuscator-llvm/obfuscator](https://github.com/obfuscator-llvm/obfuscator) — original OLLVM
- [HikariObfuscator/Hikari](https://github.com/HikariObfuscator/Hikari) — Hikari
- [komimoe/Hikari](https://github.com/komimoe/Hikari) — Arkari (based on goron, LLVM 14+)
- [amimo/goron](https://github.com/amimo/goron) — goron
- [bluesadi/Pluto](https://github.com/bluesadi/Pluto) — Pluto
- [za233/Polaris-Obfuscator](https://github.com/za233/Polaris-Obfuscator) — Polaris (formerly Pluto)
- [open-obfuscator/o-mvll](https://github.com/open-obfuscator/o-mvll) — O-MVLL
- [fuqiuluo/amice](https://github.com/fuqiuluo/amice) — Rust implementation of OLLVM passes
- [lich4/awesome-ollvm](https://github.com/lich4/awesome-ollvm) — Ecological overview of**variants (strongly recommended to read first)**

**anti-obfuscation tool:**
- [obpo-project/obpo-plugin](https://github.com/obpo-project/obpo-plugin) — The most powerful cloud plug-in
- [w00tzenheimer/d810-ng](https://github.com/w00tzenheimer/d810-ng) — Locally preferred
- [cdong1012/ollvm-unflattener](https://github.com/cdong1012/ollvm-unflattener) — Miasm pure script
- [amimo/ollvm-breaker](https://github.com/amimo/ollvm-breaker) — Binary Ninja
- [GeT1t/deollvm](https://github.com/GeT1t/deollvm) — ARM64 Unicorn
- [Mrack/DeObfBR](https://github.com/Mrack/DeObfBR) — BR obfuscation special
- [maskelihileci/IDA_Ollvm-unflattener](https://github.com/maskelihileci/IDA_Ollvm-unflattener) — IDA plug-in version
- [angr](https://angr.io/) — Symbolic execution framework
- [SiMBA](https://github.com/tech-srl/simba) — MBA simplified

**Academic/Blog:**
- [Quarkslab: Deobfuscation: Recovering an OLLVM-protected program](https://blog.quarkslab.com/deobfuscation-recovering-an-ollvm-protected-program.html) — deflat classic principle
- [MODeflattener](https://github.com/mrT4ntr4/MODeflattener) — static deflat (vs. ollvm-unflattener)

> related documents: [[anti-analysis.md]] (anti-debugging/anti-analysis summary list), [[tools-advanced.md]] (advanced toolset), [[elf-analysis.md]] (ELF file analysis), [[ai-assisted-re.md]] (AI-assisted reverse engineering)
