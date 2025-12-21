#!/bin/bash

# Note: This patch currently disables the scree on the Elegoo CC making it un-usable for printing
# We are working on an updated uBoot binary that will enable UART and also allow screen use!
# For now this is only useful for devs doing DSP or Kernel development.

set -e
cd "$REPOSITORY_ROOT"
# AnyCubic variant (works for UART but /app/app no worky because DT is wrong)
#OPTIONS_DIR="./RESOURCES/OPTIONS" ./RESOURCES/OPTIONS/uart/uart.sh . 2.3.9
# OpenCentauri patched uBoot (AnyCubic + our CC board_config.dts and kernel_config.dts with a few mods for UART!)
OPTIONS_DIR="./RESOURCES/OPTIONS" ./RESOURCES/OPTIONS/uart/uart.sh . oc239
