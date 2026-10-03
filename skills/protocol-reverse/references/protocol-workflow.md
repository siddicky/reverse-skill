# Protocol reverse quick check

> Applicable to: `protocol-reverse` skill · 2026-07-18

## Common layout patterns

| Mode | Features | Tips |
|------|------|------|
| Fixed length header + body | First 2/4 byte length | Pay attention to whether the header length is included |
| Magic number | Fixed `0xDEAD`, etc. | Facilitates stream resynchronization |
| TLV | type-length-value repeat | type enumeration is message dictionary |
| Protobuf | field number varint | `protoc --decode_raw` |
| Encrypted frame | High entropy, no plaintext URL | Find nonce/IV neighborhood first |

## Minimal Python skeleton

```python
import struct
def parse_frame(buf: bytes):
    magic, length, msg_type = struct.unpack_from(">IHI", buf, 0)
    body = buf[10:10+length]
    return {"magic": magic, "type": msg_type, "body": body}
```

## PCAP extracts TCP payload

```bash
tshark -r cap.pcap -Y "tcp.port==4433" -T fields -e tcp.payload | head
```