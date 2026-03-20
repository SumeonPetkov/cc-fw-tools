#!/bin/sh

set -e

echo "Removing OpenCentauri remanants..."
echo "Warning: ONLY run this script via the nc backdoor, not via ssh!"

pid=$(pgrep -f "/opt/sbin/sshd")
[ -n "$pid" ] && kill "$pid"

pid=$(pgrep -f "mount_usb_daemo")
[ -n "$pid" ] && kill "$pid"

sleep 1

umount /opt
umount /root

rm -rf /user-resource/OpenCentauri
cp /etc/swupdate_public_cc.pem /etc/swupdate_public.pem
md5sum /etc/swupdate_public.pem
echo "Done. Install an official update to restore your system."