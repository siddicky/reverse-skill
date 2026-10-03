# [Seed] PCAP custom binary protocol reverse engineering

## Scene classification
Packet capture analysis/protocol reversal

## Goal overview
An IoT device/desktop client uses TCP custom binary protocol (non-HTTP) and captures a PCAP. It needs to restore the frame structure, field meanings, encryption layer (if any), and write a local client/server to reproduce it.

## Complete execution link

1. Open PCAP in Wireshark and do basic statistics first
   - `Statistics → Conversations` See IP/port pair
   - `Statistics → I/O Graphs` Look at the data rhythm
2. Uncover true application layer flow (peeling away standard layers like TLS)
3. On a certain TCP stream → `Follow → TCP Stream` → switch to RAW mode → export
4. Binary level observation: Are the first few bytes of each frame a fixed magic/length field?
   ```bash
   xxd dump.bin | head -20
   ```
5. Use hex mode to find patterns: fixed header, length, TLV, CRC
6. Write a Python parser (struct + scapy) to parse frame by frame
7. Synchronous decompilation from binary to lookup protocol fields (IDA/Ghidra see around send/recv struct)
8. Verification: Start the client and send a frame → the server responds consistently

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| Wireshark does not recognize the protocol and only displays "Data" | is a private protocol and has no parser | Write Wireshark Lua dissector or direct Python offline analysis | 30min |
| looks irregular and different in each frame. | has a compression or encryption layer. | uses entropy analysis (`ent dump.bin`) to determine whether it is encrypted; look for the nonce/IV field | 1h |
| The length field is not calculated correctly | The length may be little-endian / big-endian / including/excluding itself | Find several frames of different lengths and solve the system of equations | 40min |
| TLS catches but cannot solve it | The client does not leave SSLKEYLOGFILE | hooks at the client process layer (Frida catches ssl_read/ssl_write) to catch the plain text | 1.5h |
| The data is correct but the server does not respond | The protocol has an incremental seq / nonce, and replay is rejected | Figure out the seq calculation method (usually the hash of the previous frame or an incremental counter) | 50min |

## Toolchain discovery

- **Wireshark Lua Dissector** Turn private protocols into Wireshark visualizations in < 100 lines
- **scapy** Just define the `Packet` subclass when writing Python parser
- **Kaitai Struct** uses YAML to describe the protocol structure and can generate multi-language parser (Python/Java/C++/JS), suitable for long-term reuse
- **NetworkMiner** is more suitable for "post-facto forensics" (automatic reorganization of files, identification of credentials) than Wireshark
- **ent/binwalk -E** Look at entropy, >7.5 almost certainly encrypted

## Key code/command

scapy custom protocol example (TLV):

```python
from scapy.all import *

class MyMsg(Packet):
    name = "MyProto"
    fields_desc = [
        StrFixedLenField("magic", b"\xab\xcd", 2),
        ByteField("version", 1),
        ByteField("type", 0),
        LenField("length", None, fmt="H"),     # H = uint16 BE
        XIntField("seq", 0),
        StrLenField("payload", "", length_from=lambda p: p.length - 8),
        XShortField("crc", 0),
    ]

# Parse PCAP
pkts = rdpcap('dump.pcap')
for p in pkts:
    if TCP in p and p[TCP].dport == 9527 and p.payload:
        msg = MyMsg(bytes(p[TCP].payload))
        msg.show()
```

Kaitai Struct YAML (preferred for long-term projects):

```yaml
# myproto.ksy
meta:
  id: myproto
  endian: be
seq:
  - id: magic
    contents: [0xab, 0xcd]
  - id: version
    type: u1
  - id: type
    type: u1
  - id: length
    type: u2
  - id: seq_no
    type: u4
  - id: payload
    size: length - 8
  - id: crc
    type: u2
```

Entropy analysis:

```bash
binwalk -E dump.bin             # Entropy graph
ent dump.bin                    # numerical value
```

## Suggestions for improvements to this package

- `reverse-engineering/platforms.md` Added the "4-step method for custom protocol reverse engineering" chapter
- Added `reverse-engineering/references/kaitai-cheatsheet.md` quick check
- bootstrap manifest adds scapy (pip) and binwalk

## Reusable patterns/script snippets

**Custom protocol reverse engineering in 4 steps**:

```text
1. Look at the rhythm (I/O diagram + Conversations to find out the conversation boundaries)
2. Find the frame boundary (magic / length / terminator)
3. Split fields (fixed header, length, payload, verification)
4. Verify encryption (entropy + find nonce + binary inverse check send function)
```

**Tips for finding frame length**:

Export all PSH packets in the same flow → Look at the total length of each TCP segment and see if the length field (positions i, i+1, i+2 are all tried) can deduce the segment length.

## evolution action
- [ ] reverse-engineering/platforms.md Add protocol reverse chapter
- [ ] bootstrap-manifest plus scapy/binwalk
- [ ] Added Kaitai Struct quick check

## environmental information
- Kali / Ubuntu，Wireshark 4.x, Python 3.10+, scapy 2.5
- Target protocol: Custom TCP binary (with TLV/length prefix)
- Encryption layer: Depends on the situation (common AES-CTR / ChaCha20)

## redaction requirements
This entry is seed data, written based on public protocol reverse engineering methods, and does not involve real products.
