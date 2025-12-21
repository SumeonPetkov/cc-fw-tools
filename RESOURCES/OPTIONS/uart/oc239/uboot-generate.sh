#!/bin/bash

set -e

cd $(dirname $0)
rm -f repacked_boot.bin
set -x

./repack.py
./check.sh
cp repacked_boot.bin uboot
rm -f uart.zip
zip uart.zip boot0 uboot
