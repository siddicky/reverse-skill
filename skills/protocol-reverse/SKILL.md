---
name: protocol-reverse
description: Use for authorized reverse engineering of custom binary protocols, Protobuf/gRPC, WebSocket frames, and PCAP-driven protocol recovery.
---

# Protocol Reverse Engineering

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read`../field-journal/precedent-reverse.md`— Confirm authorization and normal operation boundaries
2. `NOW`: Confirm whether the task is **protocol/traffic/serialization format** reverse (non-pure Web parameter signature → transfer to`js-reverse/`)
3. `NOW`: If there is target network interaction →`../scripts/case-init.ps1`completes the scope;`auth`is not granted and prohibits ACT on the target
4. `NEXT`: Read`../tool-index.md`; lack of tool bootstrap (tshark/wireshark, etc. may need to be done manually)
5. `ACT`: Enter workflow Phase 1, output frame layout or message dictionary draft

## Applicable scenarios

- Custom TCP/UDP binary protocol
- Protobuf / gRPC / FlatBuffers / MessagePack
- WebSocket / MQTT / Private RPC
- PCAP/PCAPNG restore fields and state machines
- Client-server verification, sequence number, encrypted frame header

## Don’t leave this skill

| situation | where to go |
|------|------|
| Only HTTP parameter signing/JS encryption |`js-reverse/`|
| TLS certificate issue only |`pentest-tools/`or browser proxy |
| Deep digging of the protocol stack in the firmware + simulation |`firmware-pentest/`and then return to this skill |

## Workflow

### Phase 1 — Collection and Triage

```text
□ Acquire the sample: PCAP / proxy export / client logs / binary
□ Mark direction: C→S / S→C; check for handshakes, heartbeats, and reconnects
□ Fixed header? Magic bytes? Length field? TLV? Fixed length?
□ Is it compressed (zlib/gzip/lz4) or encrypted (AES/ChaCha within the frame)?
□ tshark -r cap.pcap -T fields -e frame.number -e ip.src -e tcp.payload
```

### Phase 2 — Frame layout restoration

```text
□ Align messages of the same type; look for invariant bytes / incrementing sequence numbers
□ Length field: big- or little-endian; includes or excludes the header
□ Checksums: CRC16/32, checksum, and HMAC locations
□ Draw the state machine: Connect → Auth → Ready → Request/Response → Close
□ Tools: Wireshark custom dissector draft / ImHex / 010 Editor template / Kaitai Struct
```

### Phase 3 — Serialization and Encryption

```text
□ Protobuf: recover the .proto schema (blackboxprotobuf / pbtk / protoc --decode_raw)
□ gRPC：HTTP/2 headers + protobuf body
□ Encryption: find key derivation in the client so/dll/JS → combine with ida-reverse / js-reverse / apk-reverse
□ Replay: only within the authorized scope; test harmless fields before sensitive operations
```

### Phase 4 — Product

```text
MUST output:
- Message type table (name/opcode/fields)
- At least 1 reproducible decoding command or script
- Evidence: original hex excerpt + decoding result (desensitization)
```

## tool chain

| Tools | Required | Purpose | Bootstrap |
|------|------|------|------|
| tshark / Wireshark | Strongly recommended | PCAP parsing | manual / winget |
| Python3 | is the | decoding script | system |
| blackboxprotobuf | optional | unknown protobuf | pip |
| ImHex / 010 | Optional | Structure Template | Manual |
| IDA / r2 / Ghidra | on demand | client serialization function | see corresponding skill |

## refer to

- `references/protocol-workflow.md`— Frame Layout and Protobuf Quick Look
- Related:`../ida-reverse/``../js-reverse/``../firmware-pentest/``../pentest-tools/`

## routing context

**Upstream**:`MASTER-ROUTING`R21 ·`routing.md`  
**Downstream**: Requires client algorithm →`ida-reverse`/`js-reverse`; Requires replay →`pentest-tools`/`api-security`  
**Same level**:`malware-analysis`(C2 protocol),`digital-forensics`(traffic forensics)

## Task completion self-check

- [ ] Did you restore the message layout or state machine (instead of just pasting hex)?
- [ ] Is there a reproducible decoding command?
- [ ] Are scope / redaction observed?
- [ ]Write back field-journal / report Checklist?