#!/bin/bash

# This patch enables UART on the Linux side via edits to the rootfs!

set -e

project_root="$REPOSITORY_ROOT"

# Source the utils.sh file for ROOTFS_DIR and other variables
source "$project_root/TOOLS/helpers/utils.sh" "$project_root"

# Overwrite the inittab file to enable UART console
echo -e "${YELLOW}INFO: Overwriting the inittab file for UART console ...${NC}"

cat <<EOF >"$ROOTFS_DIR/etc/inittab"
::sysinit:/etc/init.d/rcS S boot
::shutdown:/etc/init.d/rcS K shutdown
::askconsole:/bin/ash --login
EOF

echo -e "${GREEN}INFO: UART console has been enabled in inittab ${NC}"
