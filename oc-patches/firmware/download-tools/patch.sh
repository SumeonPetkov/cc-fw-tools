#!/bin/bash

if [ $UID -ne 0 ]; then
  echo "Error: Please run as root."
  exit 1
fi

cd "$SQUASHFS_ROOT/bin"

curl -L -o ./utf8-fix https://github.com/OpenCentauri/OpenCentauri/releases/latest/download/utf8-fix-linux-armv7
curl -L -o ./bind-shell https://github.com/OpenCentauri/OpenCentauri/releases/latest/download/bind-shell-linux-armv7
curl -L -o ./wifi-network-config-tool https://github.com/OpenCentauri/OpenCentauri/releases/latest/download/wifi-network-config-tool-linux-armv7
curl -L -o ./mcu-flasher https://github.com/OpenCentauri/OpenCentauri/releases/latest/download/mcu-flasher-linux-armv7
curl -L -o ./serial-multiplexer https://github.com/OpenCentauri/OpenCentauri/releases/latest/download/serial-multiplexer-linux-armv7
curl -L -o ./dsp-to-serial https://github.com/OpenCentauri/OpenCentauri/releases/latest/download/dsp-to-serial-linux-armv7
curl -L -o ./recovery https://github.com/OpenCentauri/OpenCentauri/releases/download/v0.0.0/recovery

chmod 755 ./utf8-fix
chmod 755 ./bind-shell
chmod 755 ./wifi-network-config-tool
chmod 755 ./mcu-flasher
chmod 755 ./serial-multiplexer
chmod 755 ./dsp-to-serial
chmod 755 ./recovery