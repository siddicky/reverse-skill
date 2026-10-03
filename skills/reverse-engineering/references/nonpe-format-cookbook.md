# Non-PE/Multi-format Agent response recipe U–AV + AW–DN

> Juxtaposed with PE anti-debugging recipes A–T (../anti-analysis.md): Press **File Type** to give "Trigger → Action Line → Evidence".  
> **Not** the second set of main processes. Triage identifies the type and jumps to the corresponding skill + this table.  
> Default **Authorized Isolation Lab/Authorized Samples and Devices**. **Detection and forensics** of grid machines, BYOVD, reflective injection, etc. are written, and no tutorials on unauthorized destruction/exploitation are written.  
> Failure to bypass or restore MUST be recorded as Evidence; disabling silencing is considered "harmless".
>
> §1–§8 / U–AV = original rule (Issue #65). §9–§23 / AW–DN = extended rules (Issue #87, after deduplication + semantic enhancement + edge-case patch).

## 0. Quick route check

| Type clue | Main skill | Chapter in this table |
|----------|----------|----------|
| .bat / .cmd / batch processing | malware-analysis | §1, §19 |
| .ps1 / PowerShell | malware-analysis | §2, §20 |
| Office macro / VBA / XLM / .docm/.xlsm | malware-analysis | §3 (including DD OLE extraction, DJ XLM macro) |
| .docx/.xlsx/.pptx OOXML external link / DDE / .rtf OLE | malware-analysis | §10 (including DK RTF) |
| Web/front-end JS obfuscation, JSVMP | js-reverse | §4, §21 (including DE/DF) |
| .sys / kernel driver | reverse-engineering/kernel-driver-reverse.md + cre | §5 |
| .dll focus | malware-analysis / re-agent-workflow | §6 (with A–T deduplication) |
| APK / Magisk / hidden icon | apk-reverse | §7–§8, §23 |
| .pdf / PDF document | malware-analysis | §9 |
| .wasm / WebAssembly | reverse-engineering | §11 |
| .jar/.class / Java bytecode | reverse-engineering | §12 |
| .exe(AutoIt) / .au3 | malware-analysis | §13 |
| .hta / HTML Application | malware-analysis | §14 |
| .wsf/.jse/.vbe | malware-analysis | §15 |
| .msi / Windows Installer | malware-analysis | §16 |
| .reg / registry script | malware-analysis | §17 |
| .vbs / VBScript | malware-analysis | §18 |
| Xposed/LSPosed module | apk-reverse | §22 |
| ELF / Linux binary | reverse-engineering | → elf-analysis.md, anti-analysis.md |
| Mach-O / macOS/iOS | reverse-engineering | → platforms.md |
| Python bytecode | reverse-engineering | → languages.md |

## 1. BAT/CMD（U V W）

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **U** | A large number of SET single character variables + %a%%b% splicing, or ^ continuation line splitting command | Expand SET line by line; command list after restoration; batch deobfuscation tool available; **Prohibited** Treat as "no action" if not restored | E-batch-deobf | P0 |
| **V** | text is garbled when opened, HEX header FF FE (UTF-16 LE BOM) | Confirm BOM → Convert to UTF-8 and then parse; or chcp 65001 + type | E-batch-encoding | P2 |
| **W** | A large number of REM/::, redundant GOTO/labels flood the real logic | to annotate; comb the GOTO true path; isolate execution capture cmd actual command log | E-batch-deadcode | P1 |

## 2. PowerShell（X Z）

> Numbering retains the proposer's custom: **No patch Y**.

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **X** | Multiple layers of FromBase64String / Gzip / Compress / nested -replace | **Decode layer by layer**; record each result separately; optional tools (PowerDecode, etc.), or use manual/scripts without tools | E-ps-decode-layer-N | P0 |
| **Z** | String reverse order, fragmentation + splicing Invoke-Expression/IEX | Restore the complete string; interrupt IEX or script block log; enter plain text command Evidence | E-ps-string-restore | P1 |

## 3. VBA Macro/XLM (AA AB AC DD DJ)

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AA** | olevba/OLEDump Only P-Code, source code stream empty (VBA Stomping) | P-Code decompilation tool; incomplete Word/Excel macro debugging observation; write clear restrictions | E-vba-pcode | P0 |
| **AB** | A large number of Chr() splicing or Base64 strings, suspected shellcode/nested script | Immediate window/script restore string; decode and post-determine type; dynamic target CreateObject/Shell | E-vba-str-decode | P1 |
| **AC** | meaningless If 1=2, or InsertLines/DeleteLines self-modification | statically follows the real branch; dynamic bp self-modification API and dump modified macro | E-vba-selfmod | P2 |
| **DD** | olevba/oledump checks out the VBA macro project (vbaProject.bin); extension .docm/.xlsm/.pptm | oledump.py checks the OLE stream structure; olevba extracts the VBA source code to detect suspicious APIs; checks AutoOpen/Workbook_Open and other automatically executed macros | E-office-vba | P0 |
| **DJ** | .xls/.xlsm Contains Excel 4.0/XLM macros (hidden in cell formulas, non-VBA flow); olevba checks out XLM macro tags | olevba --xlm extracts XLM macro formulas; checks EXEC/CALL/REGISTER functions in hidden worksheets; XLMMacroDeobfuscator Dynamic simulation restoration | E-office-xlm | P0 |

## 4. JavaScript (AD AE AF) → main path js-reverse

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AD** | Custom bytecode array + while/switch interpreter (JSVMP) | Find VM entry and opcode distribution; dynamic log track; AST + dynamic dual track; see js-reverse DeepDive | E-js-vmp | P0 |
| **AE** | while(1){switch} + large string array subscript | AST/Babel reconstruction; array subscript restores string; wakaru and other optional; **Do not** paste the whole PE ollvm-deobfuscation long article | E-js-deobf | P0 |
| **AF** | debugger, hijack console, poor performance.now, DevTools detection | disable breakpoints/fixed time source/headless browser; patch detection point; authorization page | E-js-anti-debug | P1 |

## 5. SYS kernel driver (AG AH AI)

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AG** | DriverEntry is very short, the logic is not at the entrance | Scan MajorFunction[] non-empty slot; priority is IRP_MJ_DEVICE_CONTROL/CREATE; address list entry | E-driver-irp-handlers | P0 |
| **AH** | exists DeviceIoControl / IOCTL distribution | Build control code → processing function table; mark METHOD_* and buffer direction; user mode communication plane | E-driver-ioctl | P0 |
| **AI** | sample loads/drops well-known vulnerable drivers or abnormally signed drivers (BYOVD mode) | compares with **public** lists such as LOLDrivers; remembers driver name/hash/signature; analyzes **calling intent**; **does not** expand exploit steps | E-driver-byovd | P1 |

See the kernel-driver-reverse.md process for details; this table only adds agent action anchor points.

## 6. DLL (AJ–AQ) — Deduplicated with A–T/#72

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AJ** | DLL analysis only looks at export/EP, ignoring TLS or DllMain | **TLS callback + DllMain must be looked at**; the dynamic breakpoint sequence still follows the four-stage rocket (TLS→EP/DllMain→API→ExitProcess) | E-dll-tls-dllmain | P0 |
| **AK** | The export name is wrong, the name is wrong, or the export is inconsistent with the behavior | The export table intersects with the actual call; abnormal export list | E-exports-anomaly | P0 |
| **AL** | No exports or very few exports, but the DLL is still loaded | Locate from entry points, strings, xrefs, and callers; do not give up because of “no exports” | E-dll-noexport | P0 |
| **AM** | Static IAT lacks DLL and is used only at runtime | **See A–T patch R** (Delay-Load / E-delay-import), do not write a long text here | E-delay-import | P0 pointer |
| **AN** | needs to restore exported function parameters and calling conventions | cross-reference + dynamically look at registers/stacks; mark stdcall/fastcall, etc. | E-dll-export-abi | P1 |
| **AO** | Suspected DLL hijacking/sideloading | Check the DLL with the same name, search path, KnownDLLs in the application directory; legal program + abnormal DLL combination | E-dll-sideload | P1 |
| **AP** | No file mapping/reflective loading clues | Memory characteristics, loader behavior, pathless modules; authorization environment forensics | E-dll-reflective | P1 |
| **AQ** | Reduce risk only because the export name "does not look malicious" | **Prohibited** Judge safety based only on the export name; combine segment permissions, entries, strings, and dynamic behavior | E-dll-export-priority | P1 |

DLL/SYS hard door is still: E-imports + E-exports (see re-agent-workflow).

## 7. Android Grid/Persistence (AR AS AT) → apk-reverse

> **Licensed only for samples, images or test devices.** The action is to detect and extract IOC and persistence paths, not to perform destruction.

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AR** | Magisk module/script includes library deletion, flash writing, batch rm system partition, etc. **Grid machine feature commands** | feature command table + module path; high risk damage capability; does not execute grid machine commands | E-android-wiper-cmd | P0 |
| **AS** | loop curl|sh / remote pull script, unconventional C2 URL | Prompt URL; analyze whether the downloaded body contains grid command; note the temporary path | E-android-wiper-backdoor | P0 |
| **AT** | /data/adb/service.d, post-fs-data.d, suspicious /system/priv-app, etc. | column persistence script/APK; content summary certificate | E-android-persistence | P1 |

## 8. Android transparent/hidden icon (AU AV) → apk-reverse

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AU** | LAUNCHER icon fully transparent/empty label, Theme.NoDisplay, no LAUNCHER category, component disabled | aapt dump badging + manifest; decompile and check icon pixels; abnormal item entry | E-android-hidden-icon-manifest | P0 |
| **AV** | is installed but there is no icon on the desktop, background traffic/auto-start/high-risk permissions/dynamic recovery icon | pm list vs desktop; dumpsys package; broadcast and device_admin; behavioral authentication | E-android-hidden-icon-behavior | P1 |

---

> **§9–§23 below are Issue #87 Extended Rules (AW–DC).**
> ELF (→ elf-analysis.md), Mach-O (→ platforms.md), Python (→ languages.md) chapters that are duplicated with existing files have been removed.

## 9. PDF malicious documents (AW AX AY AZ)

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AW** | pdfid detects /JS, /JavaScript, /OpenAction, /AA, /Launch count >0 (including obfuscation counts for hex-encoded names such as /4A#61#76#61...) | pdfid -e statistics (compare plain vs obfuscated counts); pdf-parser extracts suspicious objects; peepdf interaction analysis + JS simulation | E-pdf-autoaction | P0 |
| **AX** | pdfid Check out /EmbeddedFile >0; object stream contains FlateDecode/ASCIIHexDecode cascade filter chain; or hide encoding payload in /Annot object | pdf-parser extract stream data; peepdf decode multi-layer cascade filter (including AES encrypted stream security handler r5/r6); check Annotation Object; file identifies decoding result type | E-pdf-embedded | P0 |
| **AY** The PDF JS extracted by | contains a large number of eval, unescape, String.fromCharCode, atob | peepdf JS simulation environment execution tracking; layer-by-layer decoding Base64/Hex/ROT13; CyberChef assistance | E-pdf-js-deobf | P1 |
| **AZ** | PDF structure anomaly: /JBIG2Decode, XREF table is manipulated, object number jumps | pdfid -d Rename suspicious keywords; check known CVE exploitation patterns; extract exploit triggering conditions | E-pdf-exploit | P1 |

## 10. Office OOXML/DDE/RTF (BA BB DK) → Complementary to §3 VBA

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BA** | docx/xlsx/pptx ZIP contains suspicious external relations (including remote template injection) in word/_rels/ or xl/_rels/ after decompression | Check *.rels external links; check vbaData.xml; extract embedded OLE objects; check protocol processor abuse (ms-msdt: / search-ms: / ms-officecmd:) | E-office-ooxml | P0 |
| **BB** | document contains DDEAUTO or DDEEXEC field code, execute external command through the field | olevba --dde scan; extract DDE command parameters; check whether it points to PowerShell/external exe | E-office-dde | P0 |
| **DK** | .rtf file contains embedded OLE objects (non-OOXML, non-classic OLE compound document) | rtfobj extracts embedded OLE objects; oleobj analyzes object types; checks Equation Editor exploits (CVE-2017-11882, etc.); file identifies extract types | E-rtf-ole | P0 |

## 11. WebAssembly（BC BD BE）

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BC** | The file starts with \x00asm magic bytes; or the JS code contains WebAssembly instantiation logic | wasm2wat converts text; checks the import section to identify the host environment import function; wasm-decompile generates pseudo code; checks the Emscripten glue signature (__wasm_call_ctors) to determine whether it is compiled from JS | E-wasm-struct | P0 |
| **BD** | WASM has a large number of functions but simple logic, and the function body is split into tiny functions; or there are meaningless block/loop nests | diswasm evaluation function minimization level; JEB Pro / IDA WASM plug-in in-depth analysis; dynamic tracking execution log | E-wasm-obfuscation | P1 |
| **BE** | WASM module interacts with the browser through JS import/export functions, and there are WebSocket, fetch, and WebGL calls. | simultaneously analyzes JS glue code and WASM module; browser DevTools tracks data exchange; extracts network communication URL/domain name | E-wasm-c2 | P1 |

## 12. Java JAR/Class（BF BG BH BI）

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BF** | JD-GUI/jadx The class name/method name has meaningless short characters (a.a.a / _0x prefix / numeric class name) when opening the JAR; or a large number of while/switch control flow obfuscation | identifies the obfuscator type (ProGuard / Allatori / ZKM); Java Deobfuscator Static anti-obfuscation; dynamic debugging and tracking key logic at high intensity | E-java-obfuscation | P0 |
| **BG** | A large number of Class.forName(), Method.invoke(), Constructor.newInstance(); or custom ClassLoader + defineClass() loads classes from byte array memory; the import table is harmless but malicious classes are dynamically loaded at runtime | javap -c -v View reflection call details; track Class.forName parameter string; check defineClass() Byte array source; dynamically interrupts Method.invoke | E-java-reflection | P0 |
| **BH** | JAR contains .so (Linux/Android) or .dll (Windows); or System.loadLibrary() calls | to extract native library files; file identifies the format; transfers to ELF/PE independent analysis process | E-java-native | P1 |
| **BI** | JAR/ZIP contains nested JAR/WAR/EAR after decompression; high-entropy .dat/.bin/.img files exist in /resources and /assets | Recursively decompress all nested archives; entropy value analysis determines encryption/compression; check META-INF/MANIFEST.MF and pom.xml | E-java-nested | P1 |

## 13. AutoIt（BJ BK BL DM）

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BJ** | PE string contains AutoIt / AU3 / EA05 / EA06 signature; or the resource section contains AutoIt script resources (note that it is different from AutoHotKey, MITER T1059.010 is shared with both) | autoit-ripper extracts the compiled script; identifies the encoding family (EA05 = AutoIt3.00 / EA06 = AutoIt3.26); extract the 8-byte decryption key after the EA06 header to decrypt the payload; restore the source code | E-autoit-extract | P0 |
| **BK** | extraction script contains a lot of StringEncrypt/_StringEncrypt; or Execute dynamic execution + meaningless variable names | myAutToExe static decompilation; identify anti-debugging technology; analyze the control flow after obfuscation | E-autoit-deobf | P1 |
| **BL** | script includes RegWrite (registry persistence), FileInstall (file release), InetGet (network download), Run/RunWait | marks sensitive API call sequence; analyzes InetGet URL; tracks FileInstall release path | E-autoit-malicious | P0 |
| **DM** | AutoIt performs process hollowing as a loader: CallWindowProc/EnumWindows callback + shellcode + injects legitimate processes (regsvcs.exe, etc.), releases .NET payload (DarkGate / Snake Keylogger / ArechClient2 mode) | checks DllCall / DllCallbackRegister Call chain of kernel32 injection API; extract shellcode data; identify injected target process; extract .NET payload independent analysis | E-autoit-hollowing | P0 |

## 14. HTA / HTML Application（BM BN BO）

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BM** | HTML contains HTA:APPLICATION tag, window.execScript or CreateObject calls | to check HTA:APPLICATION attributes (Application, WindowState); extract VBS/JS in script tag | E-hta-bypass | P0 |
| **BN** | After HTA is started through mshta.exe, XMLHttpRequest / ActiveXObject remotely pulls Payload and executes | Extracts network request URL; tracks ActiveXObject creation (ADODB.Stream, etc.); restores the complete download execution chain | E-hta-download-chain | P0 |
| **BO** | HTA only contains a single line of extremely long obfuscated strings, executed by eval / execScript | extracts Base64/Hex encoding payload decoding; CyberChef recursively detects the encoding type; restores the payload | E-hta-oneline | P1 |

## 15. WSF / JSE / VBE（BP BQ BR BS）

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BP** | .wsf contains \<job\> + \<script language="..."\> tags, mixed JScript/VBScript/Python | Split code blocks according to \<script language\>; analyze according to corresponding language rules respectively | E-wsf-multi | P0 |
| **BQ** | .jse/.vbe contains #@~^ signature at the beginning, Microsoft Script Encoder encoding | screnc-decoder decoding; dynamic execution without tools + dump decoding script | E-jse-decode | P0 |
| **BR** | WSF multiple \<script\> blocks + \<package\> references external resources + \<component\> references COM components | Creates a cross-block call graph; tracks function calls between \<script\>; restores the complete execution process | E-wsf-call-chain | P1 |
| **BS** | WSF contains WshShell.SendKeys to bypass UAC, WshShell.Run with 0 window hiding, WScript.Sleep delay bypass | Check whether the user simulation operation is used to bypass security prompts; record covert execution parameters | E-wsf-anti-detect | P1 |

## 16. MSI installation package (BT BU BV)

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BT** | MSI file contains CustomAction table (Binary / Script / DLL type custom action) | msiexec /a or lessmsi Extract content; check CustomAction table; extract custom action binary file | E-msi-custom-action | P0 |
| **BU** | MSI Binary table contains VBScript/JScript custom operation script | Extracts script binary from Binary table and decodes it into readable script; analyzes according to VBS/JS rules | E-msi-script | P1 |
| **BV** | MSI is installed silently through /quiet /passive /qn; ALLUSERS=1 elevates privileges | records installation command line parameters; analyzes Property table permission settings; marks silent + privilege escalation combination | E-msi-privilege | P1 |

## 17. REG registry script (BW BX BY)

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BW** | .reg Write to HKCU\...\Run or HKLM\...\Run and other automatic startup paths | Extract all paths; mark Run path entries as persistent; record the full path and value | E-reg-persistence | P0 |
| **BX** | .reg Modify HKCR\...\shell\open\command (file association) or HKCR\CLSID\{...}\InprocServer32 (DLL injection) | Check whether shell\open\command is an unconventional exe; check InprocServer32 DLL path | E-reg-hijack | P0 |
| **BY** | .reg Modify HKLM\...\Policies\System (UAC level), EnableLUA, ConsentPromptBehaviorAdmin | Check the default security configuration before modification; analyze the impact on UAC; mark downgrade behavior | E-reg-uac-bypass | P1 |

## 18. VBScript（BZ CA CB CC DN）

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BZ** | .vbs/.js is parsed by both VBScript and JScript; conditional compilation (@_win32) or language feature cross-execution | separates VBScript/JScript code blocks; separate syntax analysis; identifies mixed execution logic | E-vbs-mixed | P1 |
| **CA** | script contains CreateObject("WScript.Shell") / CreateObject("Shell.Application") / Scripting.FileSystemObject | Mark high-risk COM object calls; track Run/Exec parameters; track file paths created by FSO | E-vbs-com-abuse | P0 |
| **CB** | script start #@~^ signature, Microsoft Script Encoder encoding (VBS proprietary) | screnc-decoder decoding; dynamic execution without tools + dump decoding script | E-vbs-encoded | P0 |
| **CC** | VBA/VBScript contains WScript.Shell.Run + cmd /c + PowerShell, subsequent process injection | tracks the CreateObject COM object chain; analyzes injection characteristics in Run parameters; records the complete process creation chain | E-vbs-inject-chain | P0 |
| **DN** | VBScript/JScript achieves fileless persistence through WMI ActiveScriptEventConsumer (no startup folder/registry Run key) | Checks WMI event subscription (__EventFilter + __FilterToConsumerBinding + ActiveScriptEventConsumer); extracts binding script content; marks fileless persistence | E-vbs-wmi-persist | P0 |

## 19. BAT/CMD Advanced Obfuscation (CD–CI) → Complementary to §1 U–W

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **CD** | setlocal enabledelayeexpansion + !var! + dynamic variable name (!var_%i%!) | expands one by one after enabling delayed expansion; Batch-Dump --expand automatically expands | E-bat-delayed-expand | P0 |
| **CE** | Read itself or the file via type/more/findstr :stream ADS Alternative data stream execution | Check: suffix reference (file.bat:payload); dir /r column ADS; type file:stream extraction | E-bat-ads-hidden | P0 |
| **CF** | Write a large number of echo lines to .tmp/.cmd temporary files and then call to execute | Extract all echo redirection to restore the temporary file contents; monitor the script generated by the temporary directory | E-bat-temp-gen | P1 |
| **CG** | for %%i in (...) do set var=%%i Accumulate variables; for /f parse command output line by line | Expand item by item for loop to record the assignment of each iteration; serialize the result for /f | E-bat-for-expand | P1 |
| **CH** | The main batch process receives parameters through %1 %*, and the obfuscated instructions are passed in by the parent process/downloader | Check the call context to record the incoming parameters; Base64 parameter decoding and restoration; restore the complete call chain | E-bat-param-call | P1 |
| **CI** | certutil -decode / powershell -Command / echo \| findstr combined decoding execution | extraction Base64/Hex string decoding; check whether the decoding result is an executable script/PE | E-bat-encoded-exec | P0 |

## 20. PowerShell Advanced Bypass (CJ–CO, DL) → Complementary to §2 X–Z

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **CJ** | [Ref].Assembly.GetType('...AmsiUtils') / amsiInitFailed / GetTypes() etc. AMSI bypass (including hardware breakpoint bypass: CPU debug register, no memory write/VirtualProtect) | identifies bypass mode (Patch / Registry / Environment Variables / Hardware breakpoint); dynamic confirmation takes effect; mark bypass technology type | E-ps-amsi | P0 |
| **CK** | [PSConstraintLanguage] type operation or modify session state through DefaultRunspace to bypass CLM | Identify CLM bypass mode; mark bypass-clm; analyze post-bypass execution context | E-ps-clm-bypass | P0 |
| **CL** | [ScriptBlock]::Create / $ExecutionContext.InvokeCommand constructor; or override ScriptBlock log settings | Check whether the script disables logging; dynamic verification log is bypassed | E-ps-sb-log-bypass | P1 |
| **CM** | IEX (New-Object Net.WebClient).DownloadString(...) or [Reflection.Assembly]::Load(FromBase64...) No file execution | Extract download URL Check domain name/IP reputation; PS log capture memory loading code; Isolate network simulation to extract load | E-ps-reflect-load | P0 |
| **CN** | Three or more nested encoding layers: outer Base64 → Gzip → XOR → plaintext (beyond the two-layer scope of §2 X) | Recursively decode to plaintext or until no further progress; record each intermediate state; automate with PowerDecode; add each result to evidence | E-ps-multi-decode | P0 |
| **CO** | Set-Alias ​​maps IEX to a single-character alias; Get-ChildItem variable: dynamically obtains the variable value | expands all alias mappings and replaces them back with the original command name; AST analysis restores variables | E-ps-alias-decode | P1 |
| **DL** | script contains ntdll.dll EtwEventWrite patch (stomping) silent telemetry; often used in combination with AMSI bypass | Checks for the presence of EtwEventWrite address acquisition + memory patching (ret 0xC3); checks simultaneously with CJ AMSI bypass; flags double bypass combination | E-ps-etw-bypass | P0 |

## 21. JavaScript Advanced Obfuscation (CP CQ DE DF) → Complementary to §4 AD–AF

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **CP** | JS uses Proxy objects to intercept property access + Reflect API to dynamically call methods to bypass static analysis | Identify Proxy get/set/apply trap functions; track Reflect.get actual targets; mark dynamic interception behaviors | E-js-proxy | P1 |
| **CQ** | JS contains _0x... hexadecimal string array + while(!![]) infinite loop + for+switch control flow (obfuscator.io feature) | recognizes obfuscator.io feature (string array + infinite loop); de4js/jsnice automatic deobfuscation; code verification after restoration | E-js-obfuscator | P0 |
| **DE** | JS body is a large bytecode array + VM interpreter loop (multiple while/switch), the entrance points to the eval/Function constructor; the business logic is completely unreadable (§4 AD deepening) | identifies the VM entry function tracking opcode→processing function mapping; the browser dynamically executes Hook eval output; JSimplifier AST reconstruction; record opcode Mapping table | E-jsvmp-deep | P0 |
| **DF** | JS contains eval to dynamically generate new code and execute it immediately, document.write to rewrite the page, or the Function constructor to dynamically construct the function body | Hook eval and Function constructor record the generated code; the browser dynamically executes to capture self-modifying content | E-js-selfmod | P1 |

## 22. Xposed/LSPosed module analysis (CR–CX) → apk-reverse

> Analyze the Xposed/LSPosed **module itself** as a reverse engineering target (non-tool usage scenario).

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **CR** | AndroidManifest.xml None android:name entry Activity; meta-data specifies xposedmodule=true | Check assets/xposed_init to determine the entry class; search IXposedHookLoadPackage/ZygoteInit/CmdInit interface implementation | E-xp-entry | P0 |
| **CS** | code contains XposedHelpers.findAndHookMethod / XposedBridge.hookMethod / findClass | Extract the first parameter (target class) + second parameter (target method) of findAndHookMethod; create a target application list | E-xp-hook-targets | P0 |
| **CT** | module contains DexClassLoader/PathClassLoader for dynamic loading; or Runtime.exec / ProcessBuilder executes commands | tracks DexClassLoader construction parameters; extracts dynamically loaded DEX independent analysis; checks exec command parameters | E-xp-dynamic-load | P0 |
| **CU** | Hook target involves sensitive APIs such as payment/biometrics/text messages/address book/location/encryption key | Classifies the sensitivity of Hook target classes/methods; marks payment class/biometric class/SMS address book class; summarizes threat level | E-xp-sensitive-hooks | P0 |
| **CV** | code contains XposedBridge detection avoidance / Zygote injection trace removal / custom network communication | check stacktrace modification / XposedBridge class reference removal; check independent network requests (OkHttp/Socket); identify C2 targets | E-xp-anti-detection | P1 |
| **CW** | code contains Resources dynamic replacement/View drawing interception/AccessibilityService declaration | Check AssetManager replacement/Resources.updateConfiguration; check AccessibilityService configuration; identify UI hijacking | E-xp-ui-hijack | P1 |
| **CX** | AndroidManifest.xml declares lsposed xposedscope meta-data; or the code contains package name whitelist check | parses xposedscope target application scope; checks dynamic whitelist bypass (reflection modification scope); identifies global Hook override | E-xp-scope-bypass | P1 |

## 23. Magisk module in-depth analysis (CY–DC, DG–DI) → complementary to §7 AR–AT

> §7 Focus on grid machines/vandalism. This section covers non-destructive but suspicious module behavior: installation script analysis, file dropping, Zygisk injection, anti-detection, persistence, privilege escalation, lateral infection.

| ID | Trigger | Action (summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **DG** | Magisk module ZIP root directory contains config.sh / install.sh; META-INF/com/google/android/update-binary is the non-standard installer | extracts the on_install/print_modname/set_permissions function in config.sh/install.sh; check whether update-binary contains additional loads; mark pm install / dd block device / mount -o remount,rw operation | E-mg-install-script | P0 |
| **DH** | ZIP contains system/ / vendor/ / data/ directory structure; or post-fs-data.sh / service.sh and other boot execution scripts | extracts the release file path to identify whether to release the APK to /system/priv-app/; check service.sh + post-fs-data.sh content to identify boot auto-start/background keep-alive/C2 Communication; marks all write operations to the system partition | E-mg-file-drop | P0 |
| **CY** | module contains zygisk/ directory (native libraries such as arm64-v8a.so); or config.sh declares IS_ZYGISK=true | extracts zygisk/ native library analysis ZygiskModule callback (onLoad / preAppSpecialize / postAppSpecialize); check JNI Hook | E-mg-zygisk | P0 |
| **DI** | module script is written to /data/adb/service.d/ or /data/adb/post-fs-data.d/; or modify crontab/init.rc (§7 AT deepening) | extracts the script content written to service.d + post-fs-data.d; check the logic of automatically infecting other modules during uninstallation (post-uninstall.sh / Module directory monitoring); check magisk --remove-modules to trigger protection mechanism | E-mg-persistence | P0 |
| **CZ** | module script contains resetprop to modify system properties / magiskhide / DenyList; or integrate Shamiko (hide Zygisk itself) / TrickyStore (tamper with certificate chain) / PlayIntegrityFork (fake Play Integrity API) | extract all resetprop calls to identify modified properties (ro.debuggable / ro.build.tags, etc.); check DenyList to hide itself; identify Shamiko/TrickyStore/PlayIntegrityFork module-level anti-detection | E-mg-anti-detect | P0 |
| **DA** | module script contains setenforce 0 / mount -o rw,remount /system / chmod 777 sensitive directory | Check SELinux operation (setenforce/chcon/restorecon); check system partition mounting + dm-verity disabled; mark high-risk privilege escalation | E-mg-privilege | P0 |
| **DB** | releases the APK/script containing curl/wget/HTTP client; or releases the APK to apply for sensitive permissions such as INTERNET + READ_CONTACTS/SMS | extracts the network request target URL/IP; analyzes the release APK permission statement; identifies the data transfer logic | E-mg-c2 | P0 |
| **DC** | script traverses the /data/adb/modules/ directory, modifies other module files, or writes a copy of itself to other modules | Check module.prop to inject malicious instructions; check other modules service.sh to append malicious code; identify "parasitic" logic | E-mg-cross-infect | P0 |

---

## 24. Constraints (global)

1. **Not parallel main process**: The stage latch is still based on re-agent-workflow / each skill.  
2. **Evidence must remember**: including failure, semi-reduction, quality= annotations.  
3. **With A–T deduplication**: PE anti-debugging does not duplicate; AM→R; AJ complements DLL perspective without overturning TLS rocket.  
4. **Tools Missing**: Note n/a + manual equivalent, no pretense of using commercial suites.  
5. **Authorization**: Destructive/injection/driver vulnerability categories are only for defense analysis and evidence collection.
6. **Extended rules to remove duplicates**: ELF → elf-analysis.md; Mach-O → platforms.md; Python → languages.md. This table does not repeat the rules of these formats.

## 25. P0 minimum check (when type hits)

```text
□ bat/cmd → U (+ V/W when needed; advanced CD–CI)
□ ps1 → X (+ Z; Advanced CJ–CO + DL ETW)
□ vba/xlm → AA + DD + DJ（+ AB/AC）
□ office ooxml/rtf → BA + DK (+ BB if suspected DDE)
□ js strong obfuscation → AD or AE (+ AF; advanced CP/CQ/DE/DF)
□ sys → AG + AH (+ AI BYOVD)
□ dll → AJ + AK/AL; Delay-Load goes R
□ apk destroy/hide → AR/AS or AU (+ AT/AV)
□ pdf → AW + AX（+ AY/AZ）
□ wasm → BC（+ BD/BE）
□ jar/class → BF + BG（+ BH/BI）
□ autoit → BJ + BL + DM（+ BK）
□ hta → BM + BN（+ BO）
□ wsf/jse/vbe → BP + BQ（+ BR/BS）
□ msi → BT（+ BU/BV）
□ reg → BW + BX（+ BY）
□ vbs → CA + CB + CC + DN（+ BZ）
□ xposed module → CR + CS + CT + CU (+ CV–CX)
□ magisk depth → DG + DH + CY + DI + CZ + DA (+ DB/DC)
```
