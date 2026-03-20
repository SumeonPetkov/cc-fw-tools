#!/bin/bash

if [ $UID -ne 0 ]; then
  echo "Error: Please run as root."
  exit 1
fi

project_root="$REPOSITORY_ROOT"
source "$project_root/TOOLS/helpers/utils.sh" "$project_root"

check_tools "grep md5sum openssl wc awk sha256sum mksquashfs git git-lfs"

echo Go into the squashfs-root dir for the rest of the steps!
cd "$SQUASHFS_ROOT"

set -x
set -e

echo Check MD5sum on OpenCentauri bootstrap
BOOTSTRAP_PATH="$CURRENT_PATCH_PATH/OpenCentauri-bootstrap.tar.gz"
MD5_SUM="$(md5sum "$BOOTSTRAP_PATH" | awk '{print $1}')"
if [[ ! "$MD5_SUM" = "$OC_BOOTSTRAP_MD5" ]]; then
  printf "MD5 hash of %s (%s) does not match expected %s, aborting...\n" "$BOOTSTRAP_PATH" "$MD5_SUM" "$OC_BOOTSTRAP_MD5"
  exit 1
fi

echo Copy over the OpenCentauri bootstrap tarball to /app
cp "$CURRENT_PATCH_PATH/OpenCentauri-bootstrap.tar.gz" ./app
chmod 644 ./app/OpenCentauri-bootstrap.tar.gz

echo 'Add symlink for /lib/modules/ for the 1.1.40 FW w/ new kernel ver 5.4.61-ab1175 (harmless for earlier revs)'
cd ./lib/modules
ln -sf 5.4.61 5.4.61-ab1175
cd -

echo "Install Ethernet kmod(s)"
cp "$CURRENT_PATCH_PATH/kmod/r8152.ko" "$SQUASHFS_ROOT/lib/modules/5.4.61/"
cp "$CURRENT_PATCH_PATH/kmod/ax88179_178a.ko" "$SQUASHFS_ROOT/lib/modules/5.4.61/"

echo Installing automatic wifi scripts/automation to run on boot
# Install oc-startwifi.sh script to /app:
cat "$CURRENT_PATCH_PATH/oc-startwifi.sh" > ./app/oc-startwifi.sh
chmod 755 ./app/oc-startwifi.sh

echo Installing automatic NTP date/time sync to run on boot
cat "$CURRENT_PATCH_PATH/ntpdate" > ./usr/sbin/ntpdate
chmod 755 ./usr/sbin/ntpdate

# Install 'mount_usb' script in /usr/sbin
cat "$CURRENT_PATCH_PATH/mount_usb" > ./usr/sbin/mount_usb
chmod 755 ./usr/sbin/mount_usb

# Install 'mount_usb_daemon' script in /usr/sbin
cat "$CURRENT_PATCH_PATH/mount_usb_daemon" > ./usr/sbin/mount_usb_daemon
chmod 755 ./usr/sbin/mount_usb_daemon

cp "$CURRENT_PATCH_PATH/oc-bootstrap" ./etc/init.d/oc-bootstrap
sed -re "s|%OC_NTP_SERVER%|$OC_NTP_SERVER|g" -i ./etc/init.d/oc-bootstrap
chmod 755 ./etc/init.d/oc-bootstrap
ln -s ../init.d/oc-bootstrap ./etc/rc.d/S81oc-bootstrap
chmod 755 ./etc/rc.d/S81oc-bootstrap

