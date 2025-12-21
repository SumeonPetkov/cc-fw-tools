#!/bin/bash
# Check offset of the ELF magic "ELF" in the original and new files
set -x
grep -aob "ELF" original_dump.bin
grep -aob "ELF" repacked_boot.bin
set +x
diff <(grep -aob "ELF" original_dump.bin) <(grep -aob "ELF" repacked_boot.bin)
ret=$?
if [ $ret -eq 0 ]; then 
    echo "HAPPY: Files follow the same elf map"
    exit 0
else
    echo "BAD BAD: Files diverge in ELF map, fix me"
    exit 1
fi
