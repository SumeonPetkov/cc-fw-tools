#!/opt/bin/bash

dd if=../firmware/official.elf of=/dev/mmcblk0p6
dd if=../firmware/official.elf of=/dev/mmcblk0p9

rm /user-resource/OpenCentauri/klipper