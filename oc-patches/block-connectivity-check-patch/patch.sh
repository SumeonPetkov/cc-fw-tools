#!/bin/bash

if [ $UID -ne 0 ]; then
    echo "Error: Please run as root."
    exit 1
fi

set -e

if [[ "$FW_VER" == "1.1.40" ]]; then
    echo "Applying binary patch for 1.1.40"

    project_root="$REPOSITORY_ROOT"
    source "$project_root/TOOLS/helpers/utils.sh" "$project_root"
    check_tools "bspatch"

    cd "$SQUASHFS_ROOT/app"
    bspatch ./app ./app-patch "$CURRENT_PATCH_PATH/disable-connectivity-checks-1.1.40.bsdiff"
    rm ./app
    mv ./app-patch ./app
else
    echo "Applying universal patch"
    cp "$CURRENT_PATCH_PATH/block-connectivity-checks.sh" "$SQUASHFS_ROOT/app/block-connectivity-checks.sh"
    chmod a+x "$SQUASHFS_ROOT/app/block-connectivity-checks.sh"
    echo "/app/block-connectivity-checks.sh &" >> "$SQUASHFS_ROOT/etc/rc.local"
fi