# AnyCubic Centauri Carbon - UART Bootloader Patch (OC2.3.9)

This directory contains tools and configuration for enabling UART serial console support on the AnyCubic Centauri Carbon 3D printer running firmware OC2.3.9 (based on Allwinner R528).

## Overview

This patch enables **full UART serial console support** in both U-Boot bootloader and Linux kernel while maintaining compatibility with the Centauri Carbon device tree for normal 3D printing operations. The solution merges UART-enabled device tree configurations with the AnyCubic 2.3.9 U-Boot binary.

## Background

The stock AnyCubic firmware does not enable UART0 for serial console access, making debugging and system analysis difficult. This patch:

1. **Adds UART0 configuration** to both SPL (board) and kernel device trees
2. **Enables serial console** at 115200 baud on UART0
3. **Preserves the Centauri Carbon device tree** for LCD, PWM, I2C, and other peripherals
4. **Maintains bootloader integrity** through proper checksum and slot management

## Hardware Connection

UART0 is available on the SD card pins:
- **TX (Transmit)**: PF2 (SD Card DAT0)
- **RX (Receive)**: PF4 (SD Card DAT2)
- **Ground**: SD Card Shield/GND

Use a 3.3V TTL serial adapter. Connect at **115200 8N1**.

## Files

### Device Tree Sources (DTS)

- **`board_config.dts`** - SPL/U-Boot board configuration
  - Configures clocks, pinmux, storage controllers
  - **UART0 injection** at lines 825-839 with aliases and chosen stdout
  
- **`kernel_config.dts`** - Main Linux kernel device tree
  - Complete R528 device tree with all peripherals
  - **UART0 enabled** at lines 1165-1182 (status = "okay")
  - Serial console configured in bootargs and aliases

### Tools

- **`repack.py`** - Python script to rebuild U-Boot image
  - Compiles `.dts` files to `.dtb` using `dtc` compiler
  - Injects DTBs at fixed offsets in U-Boot binary
  - Updates checksums and size headers
  - Preserves ELF binary placement for bootloader integrity

- **`uboot-generate.sh`** - Master build script
  - Executes `repack.py` to build new U-Boot
  - Runs validation with `check.sh`
  - Packages `boot0` and `uboot` into `uart.zip`

- **`check.sh`** - Validation script
  - Verifies ELF magic offsets match between original and patched
  - Ensures binary structure integrity

### Binary Files

- **`original_dump.bin`** - Original AnyCubic 2.3.9 U-Boot dump
- **`repacked_boot.bin`** - Generated patched U-Boot (after running scripts)
- **`boot0`** - SPL bootloader (preserved from original)
- **`uboot`** - Final patched U-Boot image
- **`uart.zip`** - Flashable package containing `boot0` and `uboot`

## Usage

### Prerequisites

Install device tree compiler:
```bash
sudo apt-get install device-tree-compiler
```

### Building

Run the generation script:
```bash
./uboot-generate.sh
```

This will:
1. Compile both DTS files to DTB format
2. Inject them into the U-Boot binary at fixed slots
3. Update checksums and headers
4. Validate binary integrity
5. Create `uart.zip` ready for flashing

### Flashing

1. Extract the original AnyCubic firmware update
2. Replace `boot0` and `uboot` with files from `uart.zip`
3. Flash using standard AnyCubic update procedure

**Note**: Boot0 is typically unchanged, but included for completeness.

### Verification

After flashing, connect a serial adapter to UART0 pins and monitor at 115200 8N1. You should see:
- U-Boot boot messages
- Kernel boot log
- Linux login prompt

## Technical Details

### U-Boot Binary Structure

The U-Boot binary has a fixed structure:

```
+-------------------+
| Header (0x800)    |  <-- Checksums, sizes
+-------------------+
| SPL Code          |
+-------------------+
| Slot 1: SPL DTB   |  <-- Offset 0xD4914, Size 32492 bytes
+-------------------+
| ELF Binary        |
+-------------------+
| Slot 2: Main DTB  |  <-- Offset 0x120000, Size 65535 bytes
+-------------------+
| Trailing Data     |
+-------------------+
```

**Critical**: DTBs must be injected at **exact fixed offsets** to preserve relative ELF binary position. Shifting these offsets corrupts the bootloader.

### Checksum Algorithm

Allwinner bootloaders use a simple additive checksum:
1. Write stamp value `0x5F0A6C39` at offset `0x14`
2. Sum all 32-bit words in the binary
3. Write final checksum at offset `0x14`

The `repack.py` script handles this automatically.

### Device Tree Patches

#### Board Config (SPL)
```dts
uart0: uart@2500000 {
    compatible = "snps,dw-apb-uart";
    reg = <0x00 0x02500000 0x00 0x400>;
    reg-shift = <2>;
    status = "okay";
};

chosen {
    stdout-path = "serial0:115200n8";
};

aliases {
    serial0 = &uart0;
};
```

#### Kernel Config
```dts
uart@2500000 {
    compatible = "allwinner,sun8i-uart";
    status = "okay";  /* Changed from "disabled" */
    pinctrl-0 = <0x14>;
    pinctrl-1 = <0x15>;
    ...
};

chosen {
    bootargs = "...console=ttyS0...";
};
```

## Troubleshooting

### No Serial Output
- Check wiring: TX ↔ RX, Ground connected
- Verify 3.3V TTL levels (not RS-232!)
- Confirm 115200 8N1 settings
- Test adapter with another device

### Boot Fails After Flashing
- Verify `check.sh` passed before flashing
- Compare file sizes: repacked should match original ±100 bytes
- Re-extract original firmware and try again

### DTC Compilation Errors
- Check `.dts` syntax (no missing braces, semicolons)
- Verify phandle references are valid
- Use `dtc -I dts -O dts -o /dev/null <file>` to validate

## Credits

- Based on AnyCubic OC 2.3.9 firmware for Centauri Carbon
- Allwinner R528 (sun8iw20) platform
- Device tree modifications by cc-fw-tools contributors

## License

These tools are provided as-is for educational and development purposes. Use at your own risk. Always maintain backups of original firmware.

## See Also

- [Allwinner R528 Datasheet](https://linux-sunxi.org/R528)
- [U-Boot Device Tree Documentation](https://u-boot.readthedocs.io/en/latest/develop/devicetree/intro.html)
- [Linux Serial Console Setup](https://www.kernel.org/doc/html/latest/admin-guide/serial-console.html)
