# [Seed] IoT router firmware extraction + obtain root via UART

## Scene classification
Firmware/IoT Security

## Goal overview
For a mid- to low-end home router, get the firmware bin from the manufacturer's website, use binwalk to extract squashfs, then use the serial port to connect to the device UART to get the root shell, and analyze its Web management interface and startup script.

## Complete execution link

### Part 1: Firmware Analysis

1. Download the firmware file (manufacturer’s official website / OpenWRT / own dump flash memory)
2. Basic identification
   ```bash
   file firmware.bin
   binwalk firmware.bin                    # look for LZMA / SquashFS / U-Boot
   binwalk -E firmware.bin                 # use the entropy graph to check for encryption
   ```
3. extract
   ```bash
   binwalk -e firmware.bin
   cd _firmware.bin.extracted/squashfs-root
   ```
4. Key points of static analysis
   ```bash
   find . -name 'shadow' -exec cat {} \;          # default password hash
   find . -name '*.cgi' -o -name 'lighttpd*'      # Web services
   find . -name 'rcS' -o -name 'init.d'           # startup scripts
   grep -r 'telnetd\|busybox' .                   # suspicious backdoors
   strings $(find . -name 'httpd') | grep -i 'admin\|debug\|backdoor'
   ```
5. Get`/etc/shadow`and break it offline:
   ```bash
   john --wordlist=rockyou.txt shadow
   ```

### Part 2: Hardware UART

1. Disassemble the machine and look at the PCB → Look for the unoccupied 4-pin/6-pin interface (usually unsoldered or with pins soldered)
2. Use a multimeter to identify
   - GND (connected to ground copper)
   - VCC (3.3V, stable at startup)
   - TX (level jumps more when starting, output in UART → PC direction)
   - RX (basically unchanged at startup)
3. Connect to USB-TTL converter (CP2102 / FT232)
   - Route TX → USB-TTL RX
   - Route RX → USB-TTL TX
   - Routing GND → USB-TTL GND
   - **Do not connect to VCC** (the device is self-powered)
4. Open serial port monitoring on the host
   ```bash
   sudo screen /dev/ttyUSB0 115200
   # Or: minicom/picocom
   ```
5. Power on → Look at U-Boot output → Linux starts → Usually enter the login prompt
6. Try default credentials/broken shadow password → get root shell

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| is an empty directory after binwalk extraction | Some firmware uses non-standard format (manufacturer private header) | is manually extracted using`dd`slice control offset, or`unblob`is used instead of binwalk | 1h |
| binwalk -E shows entropy close to 1 | overall encryption | finds decryption key when firmware upgrade (usually hardcoded in OEM tools) | hours |
| UART cannot see any characters | The baud rate is wrong | Try 9600 / 38400 / 57600 / 115200 / 460800 / 921600 | 30min |
| UART sees characters but garbled characters | TX/RX reverse connection/level mismatch | 1) Swap TX RX 2) Confirm USB-TTL is 3.3V instead of 5V | 30min |
| login prompt but no password available | has not been broken + the manufacturer's default password has been changed | U-Boot phase key interruption →`setenv bootargs ${bootargs} init=/bin/sh`→ enter single user | 1.5h |
| U-Boot does not respond to key interrupts | The manufacturer has closed the console / changed the prompt | Find`bootdelay`in the firmware, physically short SPI flash manufacturing startup failed and let U-Boot interact | for several hours |
| has entered root but telnetd does not work | There is no dropbear/telnetd in the image | mount usb and copy busybox-static into it | 1h |

## Toolchain discovery

- **unblob** is stronger than binwalk (automatically recognizes more formats and will not get stuck in private headers)
- **firmware-mod-kit** Old but still useful for unpacking/packing
- **firmwalker** automatically scans and extracts "sensitive clues" (credentials/private keys/URL/binary backdoors) in squashfs
- **EMBA** is a comprehensive firmware audit platform (automated version of firmwalker + binary CVE scanning + simulated boot)
- **FirmAE** Use QEMU to simulate starting IoT firmware and dynamically analyze the web interface without the need for a real machine
- **ChirpStack USB-TTL** / **Bus Pirate** / **Tigard** are all fine, the cheap CP2102 is also enough

## Key code/command

One-stop firmware audit:

```bash
# 1. Extract
unblob -k firmware.bin -o extracted/

# 2. Run firmwalker
git clone https://github.com/craigz28/firmwalker
./firmwalker.sh extracted/squashfs-root

# 3. Simulate startup (if supported)
docker run -it --rm -v $(pwd):/firmware firmae:latest \
  /work/run.sh -d 1 /firmware/firmware.bin

# 4. Web has been simulated → use nuclei / nikto / curl to scan directly
```

The UART automatically tries common baud rates:

```bash
for baud in 9600 19200 38400 57600 115200 460800 921600; do
    echo "--- $baud ---"
    timeout 3 sudo cat /dev/ttyUSB0 < <(stty -F /dev/ttyUSB0 $baud cs8 -cstopb -parenb)
done
```

U-Boot single-user bypass classic trick:

```text
# U-Boot phase key interrupt (usually hold down space or Ctrl+C)
=> setenv bootargs "console=ttyS0,115200 root=/dev/mtdblock2 rootfstype=squashfs init=/bin/sh"
=> saveenv
=> boot
# Enter sh directly after startup, no password required
```

## Suggestions for improvements to this package

- `reverse-engineering/platforms.md`already contains the firmware chapter, it is recommended to remove`references/iot-firmware-cheatsheet.md`
- Added`reverse-engineering/references/uart-debug.md`to cover getting started with UART/JTAG/SWD
- bootstrap manifest added unblob / firmwalker

## Reusable patterns/script snippets

**IoT Security Testing 4 Phases**:

```text
Stage 1 - Software
  · Download vendor firmware and extract it with binwalk/unblob
  · Run firmwalker
  · grep for default credentials / private keys / backdoor strings
  · Emulate startup in QEMU and scan the web interface

Stage 2 - Hardware
  · Open the device and locate UART/JTAG pads
  · Identify GND/VCC/TX/RX with a multimeter
  · Connect USB-TTL and confirm 3.3 V logic

Phase 3 - Debugging
  · Listen with screen/minicom
  · Interrupt U-Boot startup to enter its interactive console
  · Use init=/bin/sh to enter single-user mode and bypass the password

Stage 4 - Exploitation
  · After obtaining root → inspect /etc/shadow and crack hashes offline
  · Inspect CGI binaries for the web admin interface → look for command injection / SSRF
  · Inspect UPnP / mDNS / Bluetooth broadcast logic
```

**Default Credentials Quick Check** (common among vendors):

```text
admin / admin
admin / password
root / root
root / 1234
support / support
ubnt / ubnt          # Ubiquiti
admin / 1234         # ZyXEL
```

## evolution action
- [ ] Uninstall iot-firmware-cheatsheet.md
- [ ] Create new uart-debug.md
- [ ] bootstrap-manifest added unblob/firmwalker

## environmental information
- Kali 2026.x（binwalk / unblob / squashfs-tools / firmwalker）
- USB-TTL converter: CP2102 / FT232 (3.3V level)
- Target: ARMv7 / MIPS routers (common with OpenWRT derived firmware)

## redaction requirements
This entry is seed data, written based on public IoT security testing methods, and does not involve any real manufacturer or model.
