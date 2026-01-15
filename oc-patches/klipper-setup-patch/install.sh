#!/opt/bin/bash

pid=$(pgrep -f "/app/app")
[ -n "$pid" ] && kill "$pid"

/app/klipper/recovery/flash-hotend.sh
/app/klipper/recovery/flash-bed.sh

dd if=/app/klipper/firmware/mod.elf of=/dev/mmcblk0p6
dd if=/app/klipper/firmware/mod.elf of=/dev/mmcblk0p9

touch /user-resource/OpenCentauri/klipper
reboot