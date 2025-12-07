#!/bin/bash

if [ $UID -ne 0 ]; then
    echo "Error: Please run as root."
    exit 1
fi

set -e

echo "Install Ethernet kmod(s) and rc.local init"
cp "$CURRENT_PATCH_PATH/kmod/"*.ko "$SQUASHFS_ROOT/lib/modules/5.4.61/"

cat <<EOF >>"$SQUASHFS_ROOT/etc/rc.local"
# Load Realtek kmod and start DHCPD for eth0 network interface if available! If not then don't try.
modprobe r8152
ifconfig eth0 && udhcpc -i eth0 -b -p /tmp/eth0_udhcpc.pid -s /usr/share/udhcpc/default.script -x hostname:Centauri-Carbon &
EOF

