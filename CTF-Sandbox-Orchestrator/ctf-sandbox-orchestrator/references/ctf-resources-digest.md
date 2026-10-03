#CTF Resource Essence Quick Check

> Featured from [awesome-ctf-resources](https://github.com/devploit/awesome-ctf-resources) and [awesome-ctf](https://github.com/apsdehal/awesome-ctf)
> Classified by CTF question type, retaining only the most practical tools and resources.

---

## Comprehensive framework

| Tools | Purpose | Links |
|------|------|------|
| Pwntools | Exploit development framework (Python) | https://github.com/Gallopsled/pwntools |
| ctf-tools | One-click installation of CTF toolset | https://github.com/zardus/ctf-tools |
| Ciphey | AI automatic decryption | https://github.com/ciphey/ciphey |
| CyberChef | Online encoding/decoding/encryption/decryption | https://gchq.github.io/CyberChef/ |

---

## Web Class

### tool
| Tools | Purpose |
|------|------|
| Burp Suite | HTTP interception/replay/scanning |
| SQLMap | SQL injection |
| XSStrike | XSS detection |
| dirsearch | directory discovery |
| JWT_Tool | JWT Attack |
| SSRFmap | SSRF exploit |

### Common test points
- SQL injection (joint query/blind injection/time blind injection/stack)
- XSS (reflection/storage/DOM)
- SSRF (intranet detection/cloud metadata)
- File upload (bypass suffix/MIME/content detection)
- Deserialization (PHP/Java/Python pickle)
- Template injection (SSTI)
- JWT forgery/key obfuscation

### Payload reference
- https://github.com/swisskyrepo/PayloadsAllTheThings
- https://book.hacktricks.wiki/

---

## Reverse class

### tool
| Tools | Purpose |
|------|------|
| IDA Pro / Ghidra | Decompile |
| radare2/r2 | CLI analysis |
| angr | symbolic execution |
| Frida | Dynamic Hook |
| GDB + pwndbg | Debugging |
| uncompyle6 | Python decompilation |
| jadx | Android decompilation |
| dnSpy | .NET decompilation |

### Common test points
- Algorithm restoration (encryption/encoding/custom)
- Anti-debugging/anti-VM bypass
- Shell/Obfuscation (UPX/VMProtect/OLLVM)
- Symbolic execution of solving constraints
- Dynamic Hook bypass check
- Go/Rust reversing (symbol recovery)

---

## Pwn class

### tool
| Tools | Purpose |
|------|------|
| Pwntools | Exploit written |
| GDB + pwndbg/GEF | Debugging |
| ROPgadget | ROP chain construction |
| one_gadget | libc one-shot |
| checksec | protection check |
| LibcSearcher | libc version identification |

### Common test points
- Stack overflow (ret2text/ret2libc/ret2shellcode/ROP)
- Heap utilization (UAF/double free/tcache/fastbin)
- Format string (any read and write)
- Integer overflow
- Kernel Pwn (privilege escalation/conditional race)
- Sandbox escape (seccomp bypass)

### Common payload patterns
```python
# ret2libc template
from pwn import *
elf = ELF('./vuln')
libc = ELF('./libc.so.6')
p = process('./vuln')
# leak libc base → calculate system/binsh → overwrite ret
```

---

## Crypto class

### tool
| Tools | Purpose |
|------|------|
| SageMath | Mathematical calculations |
| RsaCtfTool | RSA automatic attack | 
| hashcat/john | Hash cracking |
| CyberChef | Codec |
| z3 (SMT solver) | Constraint solving |

### Common test points
- RSA (Small Public Key Index/Common Mode/Wiener/Coppersmith)
- AES（ECB/CBC padding oracle/bit flipping）
- Classical cryptography (Caesar/Vigenere/replacement)
- Hash length extension attack
- Elliptic curve (ECDSA nonce reuse)
- Lattice password (LLL/CVP)

---

## Forensics class

### tool
| Tools | Purpose |
|------|------|
| Volatility | Memory Forensics |
| Autopsy/Sleuth Kit | Disk Forensics |
| Wireshark | Traffic Analysis |
| binwalk | firmware/file extraction |
| foremost | file recovery |
| exiftool | metadata extraction |

### Common test points
- Memory dump analysis (process/password/malicious code)
- PCAP traffic analysis (HTTP/DNS/TCP reassembly)
- File system analysis (deleted file recovery/hidden partition)
- Log analysis (Web log/system log)
- Disk image analysis

---

## Misc/Stego class

### tool
| Tools | Purpose |
|------|------|
| StegSolve | Image Steganalysis |
| zsteg | PNG/BMP steganography |
| steghide | JPEG steganography |
| Audacity | Audio Analysis |
| strings/xxd | Basic analysis |
| file/binwalk | File type identification |

### Common test points
- LSB steganography (the least significant bit of the picture)
- File header repair/splicing
- QR code/barcode
- Audio spectrogram steganography
- ZIP pseudo-encryption/known plaintext attack
- Encoding recognition (Base64/Hex/Morse/Braille)

---

## Online platform

| Platform | Features | Links |
|------|------|------|
| CTFTime | Event Calendar + writeup | https://ctftime.org/ |
| HackTheBox | Practical target drone | https://www.hackthebox.com/ |
| TryHackMe | Guided Learning | https://tryhackme.com/ |
| PicoCTF | Beginner-friendly | https://picoctf.org/ |
| pwnable.kr | Pwn special project | http://pwnable.kr/ |
| cryptopals | Crypto specialization | https://cryptopals.com/ |
| OverTheWire | War Challenge Series | https://overthewire.org/ |
| Root-Me | Comprehensive Challenge | https://www.root-me.org/ |

---

## Writeup resources

| Resources | Links |
|------|------|
| CTFTime Writeups | https://ctftime.org/writeups |
| 0xdf hacks stuff | https://0xdf.gitlab.io/ |
| LiveOverflow (YouTube) | https://www.youtube.com/c/LiveOverflow |
| John Hammond (YouTube) | https://www.youtube.com/c/JohnHammond010 |
| IppSec (HTB walkthrough) | https://www.youtube.com/c/ippsec |
