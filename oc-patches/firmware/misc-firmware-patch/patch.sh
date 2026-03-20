#!/bin/bash
#
# Script to apply the standard patchset for OpenCentauri Firmware Build
#

if [ $UID -ne 0 ]; then
  echo "Error: Please run as root."
  exit 1
fi

project_root="$REPOSITORY_ROOT"

# Source the utils.sh file
source "$project_root/TOOLS/helpers/utils.sh" "$project_root"

# files needed
FILES="sw-description sw-description.sig boot-resource uboot boot0 kernel rootfs dsp0 cpio_item_md5"

# check the required tools
check_tools "grep md5sum openssl wc awk sha256sum mksquashfs git git-lfs"

# Legacy AnyCubic option: Configure centauri carbon for serial UART and uboot shell
#OPTIONS_DIR="./RESOURCES/OPTIONS" ./RESOURCES/OPTIONS/uart/uart.sh . 2.3.9

echo Go into the squashfs-root dir for the rest of the steps!
cd "$SQUASHFS_ROOT"

set -x
set -e

echo Install OpenCentauri banner file
cat "$CURRENT_PATCH_PATH/banner" > ./etc/banner

echo Configure bind-shell for recovery purposes on 4567/tcp
cat "$CURRENT_PATCH_PATH/12-shell" > ./etc/hotplug.d/block/12-shell
chmod 644 ./etc/hotplug.d/block/12-shell

echo Set root password to 'OpenCentauri'
sed -re 's|^root:[^:]+:(.*)$|root:$1$rjtTIZX8$BmFRX/0pY6iP8VemQeOhN/:\1|' -i ./etc/shadow

echo Add mlocate group 
sed -re 's|^(network.+)$|\1\nmlocate:x:102:|' -i ./etc/group

echo Fix fgrep error on login in /etc/profile
sed -re 's|fgrep|grep -F|' -i ./etc/profile

echo Create sshd privilege separation user
echo 'sshd:x:22:65534:OpenSSH Server:/opt/var/empty:/dev/null' >> ./etc/passwd

echo Set hostname to OpenCentauri
sed -re 's|TinaLinux|OpenCentauri|' -i ./etc/config/system

echo Installing SSL certificates
cp "$CURRENT_PATCH_PATH/ca-bundle.crt" ./etc/ca-bundle.crt
sed -i '/^export PS1=/a export SSL_CERT_FILE="\/etc\/ca-bundle.crt"' ./etc/profile

echo Setup uninstaller
cp "$CURRENT_PATCH_PATH/uninstall.sh" ./app/uninstall.sh
chmod 755 ./app/uninstall.sh

# TODO: Fix swupdate_cmd.sh -i /mnt/exUDISK/update/update.swu -e stable,now_A_next_B -k /etc/swupdate_public.pem
# Write log to /mnt/exUDISK/ instead of /mnt/UDISK

cd -
