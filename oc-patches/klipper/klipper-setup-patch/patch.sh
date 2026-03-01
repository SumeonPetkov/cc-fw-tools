#!/bin/bash

set -e

cd "$SQUASHFS_ROOT"
mkdir ./app/klipper/firmware -p

# Copy files
cp -r "$CURRENT_PATCH_PATH/recovery" ./app/klipper
cp -r "$CURRENT_PATCH_PATH/runtime" ./app/klipper
cp "$CURRENT_PATCH_PATH/install.sh" ./app/klipper

# Make sure we can run them
chmod a+x ./app/klipper/recovery/*
chmod a+x ./app/klipper/runtime/*
chmod a+x ./app/klipper/install.sh

# Download firmwares
cp ../dsp0 ./app/klipper/firmware/official.elf
curl -L -o ./app/klipper/firmware/bed.bin https://github.com/OpenCentauri/kalico/releases/download/0.0.1/bed.bin
curl -L -o ./app/klipper/firmware/hotend.bin https://github.com/OpenCentauri/kalico/releases/download/0.0.1/hotend.bin
curl -L -o ./app/klipper/firmware/mod.elf https://github.com/OpenCentauri/kalico/releases/download/0.0.1/mod.elf

# Set up hook
cat "$CURRENT_PATCH_PATH/rc.local" >> ./etc/rc.local
sed -re "s|%OC_APP_GADGET%|$OC_APP_GADGET|g" -i ./etc/rc.local