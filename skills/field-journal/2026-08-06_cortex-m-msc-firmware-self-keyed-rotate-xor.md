# 2026-08-06 Cortex-M virtual disk upgrade firmware’s own mask rotation/XOR package

## scene classification

 binary / firmware reverse

## Goal Overview

 analyzes a Cortex-M debugging tool upgrade package, identifies its custom packaging algorithm, and distinguishes the application image in the upgrade package from the USB Mass Storage bootloader resident on the device.

## Scope Summary (redaction)

- auth_basis: own_system
- network_profile: authorized_target_only (actually a local offline sample)
- asset_types: [firmware_container, cortex_m_application, usb_msc_updater]

## role

- lead_role: lead
- specialists: [cre, cce, doc]

## complete execution link

1. made statistics on the length, entropy, tail period and chunking of the original packet, and found that the file size was an integer multiple of 1 KiB, and the tail had a 7-byte period.
2. starts from Cortex-M vector table constraints, enumerates single-byte rotation/XOR relationships, and restores the first block first.
3. found that each 1 KiB block resets the rotation phase, and the first ciphertext byte of the block can be used directly as the XOR mask of the block.
4. decodes each block with `P[i] = ROR8(C[i], (3*i) mod 7) XOR C[0]` and uses the inverse transform to reconstruct the original packet byte by byte.
5. cross-verified with the second official firmware of the same series: the legal vector table, version string and readable code were recovered in the same format; the first plaintext byte of all blocks was zero.
6. deduces the application base address through the vector target address and file offset, and confirms that the upgrade package does not contain a pre-bootloader.
7. combines the official "Enter bootloader/emulated USB disk" instructions to reconstruct the external process of copying MSC files to Flash writing, and marks the internal details of the bootloader as inference.
8. tests common CRC, STM32 hardware CRC, Adler and accumulation on the tail 32-bit field. It does not match and remains as an unresolved integrity field.

## Evidence chain summary (redaction)

| E-id | source_type | Reusable command mode | Association Finding |
|---|---|---|---|
| E-001 | local_binary | Block entropy, cycle tail, vector constraints | F-001 |
| E-002 | derived_algorithm | block first mask + ROR/XOR + round-trip | F-001 |
| E-003 | static_analysis | Vector, string, Thumb disassembly | F-002 |

## Finding / Path summary

- top_finding: Some high-entropy firmware packages are simply self-masked ROR/XOR obfuscation reset by 1 KiB and should not be prematurely classified as standard encryption.
- path_type: solve/callflow
- path_one_liner: Cycle and block structure → vector table crib → first block recovery → block boundary reset → second firmware cross-validation → application/bootloader boundary → MSC upgrade external process.

## pit record

| Problem | Cause | Solution | Time consuming |
|---|---|---|---|
| first uses the "majority byte after derotation" of each block as a mask, a few blocks still have garbled characters | The most common plaintext byte of text-dense blocks is not necessarily zero | compares the first byte model of the block; the garbled characters disappear and reappear in the second firmware | |
| Single full file XOR/rotation only works at the beginning | Rotate phase and mask reset every 1 KiB | Explicit chunking by `0x400` | Low |
| IDA and radare2 failed to start | There is no IDA path on this machine, the r2 bootstrap installer is abnormal | Use Python + Capstone to verify the Cortex-M entry | |
| When seeing `firmware_crc32`, it is assumed that the end is a standard CRC32 | The string is a metadata key and cannot prove the package tail parameters and coverage | The system retains unknowns after excluding common families and does not force naming | Low |

## toolchain found

- Python is suitable for bitwise transformation enumeration, round-trip and cross-sample invariant verification.
- Capstone is sufficient to verify Cortex-M vector entry and local control flow in the absence of IDA/Ghidra/radare2.
- The quality of string recovery is a strong signal for comparing candidate masking models, but must be combined with absolute pointers and disassembly to avoid relying solely on "looking readable".

## Key algorithm

```text
block_size = 0x400
mask = packed_block[0]
rotation(i) = (3 * i) mod 7
plain[i] = ROR8(packed[i], rotation(i)) XOR mask
```

Use `ROL8` for inverse transformation of ; the verification standard is that the encoding result is the same as the original packet byte by byte.

## 's suggestions for improving this package

- adds a check of "whether the block boundary resets the cycle" in the container identification phase of firmware-pentest.
- When the heuristic zero-byte crib fails on a few blocks, give priority to testing self-describing masks at the beginning/end of the block.
- For the situation where "the upgrade package only contains applications", the report must separately mark the internal behavior of the bootloader and the inevitable behavior of the protocol layer.

## reusable mode

1. first checks whether the cycle is reset according to common Flash/transfer block sizes (256, 512, 1024, 2048, 4096).
2. uses Cortex-M's SRAM stack pointer and Thumb Reset Vector as strong crib.
3. performs three verifications on each candidate model: full file round-trip, second sample recurrence, and absolute address reference consistency.
4. If the tail field does not match common validations, do not treat variable names or strings as evidence of the algorithm.

## evolution action

- [x] added field-journal record
- [x] updated field-journal index
- [ ] updated routing matrix
- [ ] updated tool-index
- [ ] updated bootstrap-manifest
- [ ] Updated sub-skill documentation

## Environmental information

- OS: Windows
- tool version: Python 3.12, Capstone 5.0.6
- target platform/version: Cortex-M3 / F1 compatible MCU, application area firmware

## redaction test

- [x] has no real domain name, IP, certificate, token, PII
- [x] No local absolute path
- [x] No sample file body and sample hash
- [x] The manufacturer, product and version information has been generalized to
