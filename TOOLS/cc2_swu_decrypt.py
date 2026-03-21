#!/usr/bin/env python3
"""
Elegoo OTA Package Decryptor
Decrypts .sig files from Elegoo firmware updates using AES-256-CBC
"""

from Cryptodome.Cipher import AES
import sys
import struct

# AES-256 Key (extracted from daemon-000/aes_key.key)
AES_KEY = bytes.fromhex('D14E150843E9D16893890756D8F77F674E161A8BEBB8F720737EE60E7F8C7E68')

def parse_header(header_data):
    """Parse the Elegoo package header (512 bytes)"""
    if len(header_data) < 512:
        raise ValueError("Header must be 512 bytes")
    
    # Magic is stored as "ELEG" in ASCII (big-endian)
    magic = struct.unpack('>I', header_data[0:4])[0]  # Use big-endian
    if magic != 0x454C4547:  # "ELEG"
        raise ValueError(f"Invalid magic number: {magic:#x} (expected 0x454C4547 'ELEG')")
    
    # Read as 32-bit values (ARM architecture)
    # 0x04: Package type (1 byte; bits 0-6=type, bit 7=encrypted)
    package_type = struct.unpack('<B', header_data[0x04:0x05])[0]
    
    # 0x05-0x06: Version (major.minor)
    version_major = struct.unpack('<B', header_data[0x05:0x06])[0]
    version_minor = struct.unpack('<B', header_data[0x06:0x07])[0]
    
    # 0x08: File size (64-bit little-endian) - actual decrypted file size
    filesize = struct.unpack('<Q', header_data[0x08:0x10])[0]  # 64-bit at offset 16
    
    # 0x10-0x40: Filename (null-terminated, 48 bytes, possibly up to 0x8F)
    filename = struct.unpack('48s', header_data[0x10:0x40])[0].split(b'\x00', 1)[0].decode('ascii', errors='ignore')
    
    # 0x90: Encrypt offset (8 bytes)
    encrypt_offset = struct.unpack('<Q', header_data[0x90:0x98])[0]
    
    # 0x98: Encrypt length (8 bytes)
    encrypt_length = struct.unpack('<Q', header_data[0x98:0xA0])[0]
    
    # 0xA0: IV (16 bytes)
    iv = header_data[0xA0:0xB0]
    
    # 0xB0: Encrypted file size (8 bytes)
    encrypt_filesize = struct.unpack('<Q', header_data[0xB0:0xB8])[0]
    
    # 0xE0: SHA256 hash (32 bytes)
    sha256_hash = header_data[0xE0:0x100]
    
    # Extract encryption flag and type
    is_encrypted = (package_type & 0x80) != 0
    pkg_type = package_type & 0x7F
    
    """   
    Package Types (bits 0-6, bit 7=encryption):
      Type 3: Mode 2 validation only
      Type 4: Mode 1 validation 
      Type 5: Default/Mode 0-1 validation
    All require version 1.2
    """
    
    return {
        'magic': magic,
        'package_type': pkg_type,
        'is_encrypted': is_encrypted,
        'version': f"{version_major}.{version_minor}",
        'filesize': filesize,
        'filename': filename,
        'encrypt_offset': encrypt_offset,
        'encrypt_length': encrypt_length,
        'encrypt_filesize': encrypt_filesize,
        'iv': iv,
        'sha256': sha256_hash.hex(),
    }

def decrypt_package(input_file, output_file=None, debug=False):
    """Decrypt an Elegoo .sig package file"""
    
    # Read the file
    with open(input_file, 'rb') as f:
        header_data = f.read(512)
        encrypted_data = f.read()
    
    if debug:
        print(f"\n[DEBUG] First 16 bytes of header: {header_data[0x00:0x10].hex()}")
        print(f"[DEBUG] IV bytes (0xA0-0xAF): {header_data[0xA0:0xB0].hex()}")
    
    # Parse header
    header = parse_header(header_data)
    
    print(f"Package Info:")
    print(f"  Type: {header['package_type']}")
    print(f"  Version: {header['version']}")
    print(f"  Encrypted: {header['is_encrypted']}")
    print(f"  File size: {header['filesize']} bytes")
    print(f"  File name: {header['filename']} ")
    print(f"  Encrypted size: {header['encrypt_filesize']} bytes")
    print(f"  IV: {header['iv'].hex()}")
    print(f"  SHA256: {header['sha256']}")
    
    if not header['is_encrypted']:
        print("\n[!] File is not encrypted, just extracting...")
        decrypted = encrypted_data
    else:
        print(f"\n[*] Decrypting with AES-256-CBC...")
        
        # Decrypt
        cipher = AES.new(AES_KEY, AES.MODE_CBC, header['iv'])
        decrypted = cipher.decrypt(encrypted_data)
        
        # Calculate and remove padding
        padding_len = header['encrypt_filesize'] - header['filesize']
        if padding_len > 0:
            decrypted = decrypted[:-padding_len]
            print(f"[*] Removed {padding_len} bytes of padding")
    
    # Determine output filename
    if output_file is None:
        if input_file.endswith('.sig'):
            output_file = input_file[:-4]  # Remove .sig extension
        else:
            output_file = input_file + '.decrypted'
    
    # Write decrypted data
    with open(output_file, 'wb') as f:
        f.write(decrypted)
    
    print(f"\n[+] Decrypted {len(decrypted)} bytes")
    print(f"[+] Output saved to: {output_file}")
    
    return decrypted

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python decrypt_elegoo.py <input.sig> [output_file] [--debug]")
        print("\nExample:")
        print("  python decrypt_elegoo.py ota-package-list.json.sig")
        print("  python decrypt_elegoo.py firmware.bin.sig firmware.bin")
        print("  python decrypt_elegoo.py package.sig --debug")
        sys.exit(1)
    
    input_file = sys.argv[1]
    debug = '--debug' in sys.argv
    output_file = None
    
    for arg in sys.argv[2:]:
        if arg != '--debug':
            output_file = arg
            break
    
    try:
        decrypt_package(input_file, output_file, debug=debug)
    except Exception as e:
        print(f"\n[!] Error: {e}")
        import traceback
        if debug:
            traceback.print_exc()
        sys.exit(1)
