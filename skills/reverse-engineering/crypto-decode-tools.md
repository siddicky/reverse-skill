# Encryption/Decryption/Encoding and Decoding Tools Quick Check

> Encrypted/encoded/hashed data is frequently encountered in reverse engineering and CTF. This document lists the most useful tools by scenario.

---

## Automatic identification + decryption (when you don’t know what encryption is used)

| Tools | Stars | Purpose | Links |
|------|-------|------|------|
| **Ciphey** | 18k+ | AI automatic recognition and decryption (supports 50+ encoding/encryption/hash) | https://github.com/Ciphey/Ciphey |
| **CyberChef** | 29k+ | Online/offline encoding and decoding Swiss Army Knife (drag-and-drop operation) | https://github.com/gchq/CyberChef |
| **dcode.fr** | — | 900+ crypto/coding/math tools online | https://www.dcode.fr/ |

### Ciphey uses

```bash
pip install ciphey
# Automatically detect and decrypt
ciphey -t "ciphertext"
# read from file
ciphey -f encrypted.txt
```

Ciphey supports: Base64/32/16, Caesar, Vigenere, XOR, AES (weak key), Morse, Binary, Hex, URL encoding, HTML entities, hash identification, etc.

### CyberChef uses

```text
Online version: https://gchq.github.io/CyberChef/
Offline version: Download the HTML file of GitHub Release and open it directly

Commonly used recipes:
- From Base64 → Solution Base64
- XOR → XOR decryption (key can be tried violently)
- AES Decrypt → AES decrypt
- Magic → Automatically detect encoding type
```

---

## Hash identification and cracking

| Tools | Purpose | Links |
|------|------|------|
| **hashID** | Identifies the hash type (MD5/SHA/bcrypt, etc.) | https://github.com/psypanda/hashID |
| **hash-identifier** | Same as above, Python version | https://github.com/blackploit/hash-identifier |
| **haiti** | Modern hash identification tool (more accurate) | `gem install haiti` |
| **Hashcat** | GPU hash cracking | https://hashcat.net/ |
| **John the Ripper** | CPU Hash Cracking | https://www.openwall.com/john/ |
| **hashes.com** | Online hash lookup (rainbow table) | https://hashes.com/ |

```bash
# Identify the hash type
hashid '5f4dcc3b5aa765d61d8327deb882cf99'
# Output: [+] MD5

# haiti (more accurate)
haiti '5f4dcc3b5aa765d61d8327deb882cf99'

# Hashcat crack
hashcat -m 0 hash.txt rockyou.txt  # MD5
hashcat -m 1000 hash.txt rockyou.txt  # NTLM
```

---

## RSA attack

| Tools | Purpose | Links |
|------|------|------|
| **RsaCtfTool** | RSA automatic attack (20+ attack methods) | https://github.com/Ganapati/RsaCtfTool |
| **SageMath** | Mathematical calculations (large number decomposition/elliptic curves) | https://www.sagemath.org/ |
| **factordb.com** | Online large number decomposition query | http://factordb.com/ |
| **yafu** | Local large number decomposition | https://github.com/bbuhrow/yafu |

```bash
# RsaCtfTool automatic attack
python RsaCtfTool.py --publickey pub.pem --private
python RsaCtfTool.py --publickey pub.pem --uncipherfile cipher.txt

# Supported attacks:
# Wiener、Boneh-Durfee、Fermat、Pollard p-1、Williams p+1
# Common modulus, Small q, Hastads, Noveltyprimes, etc.
```

---

## XOR analysis

| Tools | Purpose | Links |
|------|------|------|
| **xortool** | XOR key length guessing + known plaintext attack | https://github.com/hellman/xortool |
| **CyberChef XOR** | Visual XOR operation | CyberChef built-in |

```bash
# Guess XOR key length
xortool encrypted_file
# Decrypt using guessed key length
xortool -l 4 -c 00 encrypted_file

# Known plaintext attack (knowing part of the plaintext)
xortool-xor -f encrypted -s "known_plaintext"
```

---

## classical cipher

| Password Type | Tools | Description |
|---------|------|------|
| Caesar | CyberChef / dcode.fr | Violent 25 offsets |
| Vigenere | dcode.fr / Ciphey | Need to guess key length |
| Substitution | quipqiup.com | Frequency analysis automatic solution |
| Enigma | dcode.fr | Online Simulator |
| Rail Fence | dcode.fr / CyberChef | Fence Code |
| Playfair | dcode.fr | key required |
| Morse | CyberChef | Dot to text |
| Bacon | dcode.fr | Binary steganography |
| ROT13/47 | CyberChef / `tr` | Simple replacement |

---

## Code recognition and conversion

| Encoding | Recognition features | Decoding method |
|------|---------|---------|
| Base64 | Ending `=` or `==`, character set A-Za-z0-9+/ | `base64 -d` / CyberChef |
| Base32 | Uppercase letters + 2-7, trailing `=` | CyberChef |
| Base58 | None 0/O/I/l, common in short identifier encodings | CyberChef |
| Hex | Only 0-9a-f, even length | `xxd -r -p` / CyberChef |
| URL encoding | `%XX` format | `urldecode` / CyberChef |
| HTML entities | `&#XX;` or `&` format | CyberChef |
| Unicode escape | `\uXXXX` format | Python `decode('unicode_escape')` |
| JWT | `xxxxx.yyyyy.zzzzz` (three segments Base64URL) | jwt.io/CyberChef |
| Brainfuck | Only `><+-.,[]` eight characters | Online interpreter |
| Ook! | Only `Ook.` `Ook!` `Ook?` | Online interpreter |

---

## Encrypted identification in reverse engineering

### Identification algorithm through constants

| Constants/Features | Algorithms |
|-----------|------|
| `0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476` | MD5 |
| `0x6A09E667, 0xBB67AE85, 0x3C6EF372` | SHA-256 |
| `0x63, 0x7C, 0x77, 0x7B` (starting with S-Box) | AES |
| `0x243F6A88` (pi in hexadecimal) | Blowfish |
| `0xB7E15163, 0x9E3779B9` | RC5/RC6/TEA |
| `0x61707865` ("expa") | ChaCha20/Salsa20 |
| `0xC6EF3720` | XTEA |

### Identified by behavior

| Behavioral Characteristics | Possible Algorithms |
|---------|-----------|
| 256-byte lookup table + swap operation | RC4 |
| 16 byte blocks + multiple rounds of permutation | AES |
| Feistel structure (left and right swap) | DES/Blowfish/TEA |
| Large number multiplication/modular exponentiation | RSA |
| Elliptic curve point operation | ECDSA/ECDH |
| Fixed 64-round cycle | TEA/XTEA |
| 32 rounds + delta constant | XTEA |

---

## Automated cryptanalysis

| Tools | Purpose | Links |
|------|------|------|
| **FeatherDuster** | Automated cryptanalysis framework | https://github.com/nccgroup/featherduster |
| **PkCrack** | ZIP known plaintext attack | https://www.unix-ag.uni-kl.de/~conrad/krypto/pkcrack.html |
| **bkcrack** | ZIP known plaintext attack (modern version) | https://github.com/kimci86/bkcrack |
| **z3** | SMT solver (constraint solving) | https://github.com/Z3Prover/z3 |
| **angr** | Symbolic execution (automatically solves input) | https://angr.io/ |

---

## rapid decision tree

```text
Get a piece of unknown data:

1. Look at the length and character set
   - only hex characters → may be hex encoded or hashed
- has = → Base64 at the end
   - Three points → JWT
   - 32/40/64 characters hex → hash (MD5/SHA1/SHA256)

2. Try it automatically with Ciphey
   ciphey -t "data"

3. If Ciphey fails → use CyberChef Magic mode

4. If it is a hash → hashID identification type → Hashcat/John crack

5. If it is RSA → RsaCtfTool automatic attack

6. If it is XOR → xortool analyzes key

7. If it is traditional ZIP encryption → Prioritize using `bkcrack` known plaintext attack, do not do unproofed password brute force first

8. If it is custom encryption → IDA/Ghidra reverse algorithm → handwritten decryption script
```

---

## Online resources

| Resources | Links | Purpose |
|------|------|------|
| CyberChef | https://gchq.github.io/CyberChef/ | Universal codec |
| dcode.fr | https://www.dcode.fr/ | 900+ password tools |
| quipqiup | https://quipqiup.com/ | Automatic replacement password solution |
| factordb | http://factordb.com/ | RSA large number decomposition |
| jwt.io | https://jwt.io/ | JWT decoding/validation |
| hashes.com | https://hashes.com/ | Hash reverse check |
| crackstation | https://crackstation.net/ | Online hash cracking |
