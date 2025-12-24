#!/bin/bash

if [ $UID -ne 0 ]; then
  echo "Error: Please run as root."
  exit 1
fi

set -e

cd "$SQUASHFS_ROOT"

curl -L -o "./app/utf8-fix" https://github.com/OpenCentauri/OpenCentauri/releases/latest/download/utf8-fix-linux-armv7
chmod 755 "./app/utf8-fix"
echo "/app/utf8-fix /user-resource/file_info/file_info.txt" >> "./etc/rc.local"