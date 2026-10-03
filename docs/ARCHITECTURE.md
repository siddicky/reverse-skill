# System architecture diagram

## Complete behavior chain flow chart

```mermaid
flowchart TD
    Start([User raised security/reverse task]) --> Detect{Trigger keyword matching?}
    Detect -->|yes| ReadRouting[Read SKILL.md + routing.md]
    Detect -->|no| Normal([Normal conversation])
    
    ReadRouting --> RouteMatch{Routing matrix matching?}
    RouteMatch -->|miss| ProposeNew[Propose a new skill<br/>Follow CONTRIBUTING.md]
    RouteMatch -->|hit| CheckJournal[Check if field-journal<br/>has similar experience]
    
    CheckJournal --> CheckTools[Read tool-index.md<br/> to confirm tool status]
    CheckTools --> ToolOK{Are the tools available?}
    
    ToolOK -->|Missing| Bootstrap[Call bootstrap-reverse.ps1<br/>automatic installation]
    ToolOK -->|Available| Execute[Enter skill workflow]
    
    Bootstrap --> BootOK{Installation successful?}
    BootOK -->|success| Execute
    BootOK -->|fail| Guide[Output structured guidance<br/>for manual processing by the user]
    Guide --> UserConfirm([User confirmed installed])
    UserConfirm --> Execute
    
    Execute --> TaskDone{Mission accomplished?}
    TaskDone -->|no| Execute
    TaskDone -->|yes| ReviewCase[Call case-review<br/> to verify the evidence graph]
    ReviewCase --> GenReport[Call docs-generator<br/>to generate reports + charts]
    
    GenReport --> WriteJournal[Write back field-journal<br/>Experience accumulation]
    WriteJournal --> UpdateIndex[Update index/routing/manifest]
    UpdateIndex --> Output([Output final result])
```

## Skills module relationship diagram

```mermaid
flowchart LR
    subgraph Routing layer
        SKILL[SKILL.md<br/>Master control entrance]
        Routing[routing.md<br/>Routing matrix]
    end

    subgraph Reverse engineering
        APK[apk-reverse<br/>APK reverse]
        IDA[ida-reverse<br/>IDA Pro]
        R2[radare2<br/>CLI Analysis]
        RE[reverse-engineering<br/>General methodology]
        BinDiff[binary-diff<br/>symbol migration]
        PatchDiff[patch-diff-exploit<br/>N-day weaponization]
    end

    subgraph Exploitation
        Pwn[pwn-chain<br/>RE→exploit]
        Firmware[firmware-pentest<br/>Firmware full link]
    end

    subgraph Penetration testing
        Pentest[pentest-tools<br/>Tool chain + loop framework]
        SrcHunter[src-hunter<br/>19 playbook]
        EDR[edr-bypass-re<br/>EDR bypass]
    end

    subgraph Web/Browser
        JS[js-reverse<br/>JS signature reverse]
        Browser[browser-automation<br/>Playwright+OpenReverse]
    end

    subgraph Infrastructure
        Bootstrap[bootstrap-reverse.ps1<br/>Bootstrap on demand]
        Discovery[ToolDiscovery.ps1<br/>Tool Discovery]
        ToolIndex[tool-index<br/>Status index]
    end

    subgraph Output layer
        Docs[docs-generator<br/>Report generation]
        Diagram[diagram-generator<br/>Diagram generation]
        Review[case-review<br/>Evidence graph audit]
        Journal[field-journal<br/>Automatic evolution]
    end

    subgraph External
        CTF[CTF-Sandbox-Orchestrator<br/>40+ sub-skills]
    end

    SKILL --> Routing
    Routing --> APK & IDA & R2 & RE & BinDiff & PatchDiff
    Routing --> Pentest & JS & Browser & Pwn & Firmware & EDR
    Routing --> CTF

    Pentest --> SrcHunter
    APK -->|.so diversion| IDA
    APK -->|.so diversion| R2
    PatchDiff -->|Write a PoC| Pwn
    Firmware -->|Find crash| Pwn
    Pwn -->|Integrate| Pentest
    EDR -->|Delivery stage| Pentest
    JS -->|Browser operations| Browser
    
    Bootstrap --> Discovery --> ToolIndex
    
    APK & IDA & R2 & Pentest & JS -->|Mission accomplished| Review
    Review --> Docs
    Docs --> Diagram
    Docs --> Journal
```

## Bootstrap bootstrapping process

```mermaid
flowchart TD
    Need[Missing tool detected] --> ReadManifest[Read bootstrap-manifest.json]
    ReadManifest --> Kind{Installation type?}
    
    Kind -->|github-release-zip| GH[Download the ZIP from GitHub Release<br/> and unzip it]
    Kind -->|pip-package| Pip[pip install]
    Kind -->|npm-mcp| NPM[npx start + register MCP]
    Kind -->|npm-global| Global[npm install -g<br/>+ postInstall]
    Kind -->|winget-package| Winget[winget install]
    Kind -->|local-http-mcp| HTTP[Register URL + start service]
    
    GH & Pip & NPM & Global & Winget & HTTP --> Verify{Verification available?}
    Verify -->|success| AddPath[Add to PATH<br/>Refresh tool-index]
    Verify -->|fail| Manual[Output manual installation guide]
    
    AddPath --> Continue([Continue the mission])
    Manual --> Wait([Waiting for user confirmation])
```

## Penetration testing cycle

```mermaid
flowchart TD
    Init[Initialization: Determine goals/scope/tools] --> Loop

    subgraph Loop[core loop]
        Align[1. Realign the target] --> Review[2. Review known findings]
        Review --> Decide[3. Decide what to do next]
        Decide --> Risk{4. Risk gating}
        Risk -->|low/medium/high| Exec[5. Perform operations]
        Risk -->|serious| Ask[Request user approval]
        Ask -->|approve| Exec
        Exec --> Record[6. Record the results]
        Record --> Check{7. Self-examination}
        Check -->|continue| Align
        Check -->|Finish| Done
    end

    Done[8. Complete the inspection] --> Report([Generate final report])
```

## automatic evolution mechanism

```mermaid
flowchart LR
    Task([Complete task]) --> WriteLog[Write to field-journal<br/>step into pitfalls + solution + code]
    WriteLog --> UpdateIdx[Update _index.md<br/>Category by scene]
    UpdateIdx --> CheckUpdate{Need to update the system?}
    
    CheckUpdate -->|Route missing| FixRoute[Update routing.md]
    CheckUpdate -->|Tool changes| FixTool[Refresh tool-index]
    CheckUpdate -->|new tools| FixManifest[Update bootstrap-manifest]
    CheckUpdate -->|No update required| Done([Finish])
    
    FixRoute & FixTool & FixManifest --> Done

    NewTask([Next time similar tasks]) --> ReadIdx[Read _index.md]
    ReadIdx --> Reuse[Reuse existing experience<br/>Avoid repeated pitfalls]
```

## Multi-platform support architecture

```mermaid
flowchart TD
    subgraph SharedLayer["Shared Layer (Platform Independent)"]
        Skills[skills/<br/>SKILL.md + routing.md + references]
        CTF[CTF-Sandbox-Orchestrator/<br/>40+ sub-skills]
        Journal[field-journal/<br/>Experience accumulation]
        Docs[docs-generator + diagram-generator]
    end

    subgraph Windows["Windows Platform Layer"]
        WinScripts[skills/scripts/*.ps1<br/>PowerShell script]
        WinManifest[bootstrap-manifest.json<br/>winget + GitHub ZIP]
        WinRules[RULES.md<br/>Rules for Windows]
    end

    subgraph Kali["Kali Linux Platform Layer"]
        KaliScripts[kali/scripts/*.sh<br/>Bash script]
        KaliManifest[kali/scripts/bootstrap-manifest.json<br/>apt + pip + GitHub tar]
        KaliRules[kali/RULES-kali.md<br/>Kali version rules]
    end

    Skills --> WinScripts & KaliScripts
    CTF --> WinScripts & KaliScripts
    Journal --> WinScripts & KaliScripts

    WinScripts --> WinManifest
    KaliScripts --> KaliManifest

    WinRules --> Skills
    KaliRules --> Skills
```

### Platform selection logic

| environment Rule file used by | Script used by | | Package management |
|------|--------------|-----------|--------|
| Windows | `RULES.md` | `skills/scripts/*.ps1` | winget / GitHub Release ZIP |
| Kali Linux | `kali/RULES-kali.md` | `kali/scripts/*.sh` | apt / pip / npm / GitHub tar.gz |

### Kali version features

- **A large number of tools pre-installed**: nmap, sqlmap, hashcat, hydra, metasploit, radare2, binwalk, burpsuite, etc. do not require bootstrap
- **apt unified management**: No need for winget or manual decompression of ZIP
- **bash native**: more concise scripts, no PowerShell dependencies
- **Path specification**: `/usr/bin/`, `/opt/`, `~/tools/`, no drive letter or space issues

## File reading timing diagram

```mermaid
sequenceDiagram
    participant U as User
    participant AI as AI client
    participant R as RULES.md / RULES-kali.md
    participant SK as SKILL.md
    participant RT as routing.md
    participant TI as tool-index.md
    participant FJ as field-journal
    participant SUB as Child skill
    participant BS as bootstrap
    participant DOC as docs-generator

    U->>AI: Submit a security task
    AI->>R: Read routing rules
    AI->>SK: Read the master entrypoint
    AI->>RT: Match route
    AI->>FJ: Find similar cases
    AI->>TI: Check tool status
    alt Tool missing
        AI->>BS: Install automatically (.ps1 or .sh)
        BS-->>AI: Result
    end
    AI->>SUB: Enter the workflow
    AI-->>U: Task results
    AI->>DOC: Generate report
    AI->>FJ: Save lessons
    AI-->>U: Done
```
