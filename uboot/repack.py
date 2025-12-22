#!/usr/bin/env python3

import struct
import os
import subprocess
import shutil

# --- CONFIGURATION ---
INPUT_FILE = "original_dump.bin"
OUTPUT_FILE = "repacked_boot.bin"

# Device Tree Sources
DTS_FILE_1 = "board_config.dts"       # Source for SPL DTB
DTS_FILE_2 = "kernel_config.dts"      # Source for Main DTB

# Layout Constants (From your analysis)
HEADER_SIZE = 0x800  # 2048 bytes

# Slot 1: SPL Device Tree
SLOT1_OFFSET = 0xD4914
SLOT1_SIZE   = 32492  # 0x7EF0

# Slot 2: Main Device Tree
SLOT2_OFFSET = 0x120000
SLOT2_SIZE   = 65535  # 0xFFFF

# Checksum Constants
CHECKSUM_OFFSET = 0x14
CHECKSUM_STAMP  = 0x5F0A6C39

def compile_dts(dts_path):
    """Compiles a .dts file to .dtb bytes using the system 'dtc' tool."""
    if not os.path.exists(dts_path):
        raise FileNotFoundError(f"DTS file not found: {dts_path}")
    
    dtc_executable = shutil.which("dtc")
    if not dtc_executable:
        raise RuntimeError("The 'dtc' tool is not found. Please install it (e.g., sudo apt-get install device-tree-compiler).")

    print(f"Compiling {dts_path}...")
    try:
        # Compile to a temporary filename
        tmp_dtb = dts_path + ".tmp.dtb"
        subprocess.check_call([dtc_executable, "-I", "dts", "-O", "dtb", "-o", tmp_dtb, dts_path])
        
        with open(tmp_dtb, 'rb') as f:
            dtb_data = f.read()
        
        os.remove(tmp_dtb)
        return dtb_data
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Failed to compile {dts_path}. Error: {e}")

def get_padded_payload(data, target_size, name="Slot"):
    """Pads the data with 0x00 to match target_size exactly."""
    current_len = len(data)
    if current_len > target_size:
        raise ValueError(f"{name} is too large! Size: {current_len}, Limit: {target_size}")
    
    padding_len = target_size - current_len
    print(f" - {name}: Data {current_len} bytes, Padding {padding_len} bytes -> Total {target_size}")
    return data + (b'\x00' * padding_len)

def checksum_update(data):
    """Calculates and applies the Allwinner checksum."""
    b = bytearray(data)
    # 1. Write Stamp
    struct.pack_into('<I', b, CHECKSUM_OFFSET, CHECKSUM_STAMP)
    
    # 2. Sum
    chksum = 0
    for i in range(0, len(b), 4):
        val = struct.unpack_from('<I', b, i)[0]
        chksum = (chksum + val) & 0xFFFFFFFF
        
    # 3. Update
    struct.pack_into('<I', b, CHECKSUM_OFFSET, chksum)
    print(f"Checksum Updated: 0x{chksum:08X}")
    return b

def repack():
    if not os.path.exists(INPUT_FILE):
        print(f"Error: {INPUT_FILE} not found.")
        return

    # 1. Compile DTS files
    try:
        new_dtb1_raw = compile_dts(DTS_FILE_1)
        new_dtb2_raw = compile_dts(DTS_FILE_2)
    except Exception as e:
        print(f"Compilation Error: {e}")
        return

    # 2. Read Original Binary
    with open(INPUT_FILE, 'rb') as f:
        original = f.read()

    # 3. Extract Static Code Chunks based on FIXED SLOTS
    # Chunk 1: Header -> Slot 1
    chunk1 = original[HEADER_SIZE : SLOT1_OFFSET]
    
    # Chunk 2: End of Slot 1 -> Slot 2
    # This preserves the ELF binary location relative to the slots
    chunk2_start = SLOT1_OFFSET + SLOT1_SIZE
    chunk2 = original[chunk2_start : SLOT2_OFFSET]
    
    # Chunk 3: End of Slot 2 -> End of File
    chunk3_start = SLOT2_OFFSET + SLOT2_SIZE
    chunk3 = original[chunk3_start :]

    print(f"Chunk sizes preserved: C1={len(chunk1)}, C2={len(chunk2)}, C3={len(chunk3)}")

    # 4. Prepare Padded DTBs
    slot1_data = get_padded_payload(new_dtb1_raw, SLOT1_SIZE, "Slot 1 (SPL DTB)")
    slot2_data = get_padded_payload(new_dtb2_raw, SLOT2_SIZE, "Slot 2 (Main DTB)")

    # 5. Assemble Payload (Header will be attached later)
    # Order: Chunk1 -> Slot1 -> Chunk2 -> Slot2 -> Chunk3
    payload = chunk1 + slot1_data + chunk2 + slot2_data + chunk3

    # 6. Prepare Header
    header = bytearray(original[0:HEADER_SIZE])
    
    # Update "u-boot" Item Size at 0x84 (Total payload size)
    new_payload_size = len(payload)
    struct.pack_into('<I', header, 0x84, new_payload_size)
    print(f"Updated header payload size: {new_payload_size} bytes")

    # 7. Final Assembly & Checksum
    full_image = header + payload
    
    # Align to 4 bytes if necessary (though fixed slots should ensure this)
    while len(full_image) % 4 != 0:
        full_image += b'\x00'
        
    final_image = checksum_update(full_image)

    # 8. Write Output
    with open(OUTPUT_FILE, 'wb') as f:
        f.write(final_image)
        
    print(f"Success! {OUTPUT_FILE} generated.")
    print(f"Total size: {len(final_image)} bytes (Original: {len(original)})")

if __name__ == "__main__":
    repack()

