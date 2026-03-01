#!/bin/bash

if [ $UID -ne 0 ]; then
  echo "Error: Please run as root."
  exit 1
fi

set -e

cd "$EXTRACTED_FW_ROOT"
cp -r "$CURRENT_PATCH_PATH/bootlogos" ./squashfs-root/bootlogos
mkdir /mnt/bootimg
mount -o loop,rw boot-resource /mnt/bootimg
cp "$CURRENT_PATCH_PATH/bootlogos/lines1.bmp" /mnt/bootimg/bootlogo.bmp
umount /mnt/bootimg
rm -rf /mnt/bootimg