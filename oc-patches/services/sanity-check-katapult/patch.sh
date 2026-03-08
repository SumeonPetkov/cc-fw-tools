#!/bin/bash

if [ $UID -ne 0 ]; then
  echo "Error: Please run as root."
  exit 1
fi

project_root="$REPOSITORY_ROOT"
source "$project_root/TOOLS/helpers/utils.sh" "$project_root"
check_tools "git"

set -e

cd "$SQUASHFS_ROOT"

curl -L -o ./app/bed-official-deployer.bin https://github.com/OpenCentauri/katapult-cc/releases/latest/download/bed-official-deployer.bin
curl -L -o ./app/toolhead-official-deployer.bin https://github.com/OpenCentauri/katapult-cc/releases/latest/download/toolhead-official-deployer.bin

git clone --depth 1 https://github.com/Arksine/katapult /tmp/katapult
cp /tmp/katapult/scripts/flashtool.py ./sbin/katapult-flashtool
chmod a+x ./sbin/katapult-flashtool
rm -rf /tmp/katapult

cp "$CURRENT_PATCH_PATH/oc-check-katapult" ./etc/init.d/oc-check-katapult
chmod a+x ./etc/init.d/oc-check-katapult
ln -s ../init.d/oc-check-katapult ./etc/rc.d/S83oc-check-katapult
chmod a+x ./etc/rc.d/S83oc-check-katapult
