#!/bin/bash

set -e
cp "$CURRENT_PATCH_PATH/block-update-checks.sh" "$SQUASHFS_ROOT/app/block-update-checks.sh"
chmod a+x "$SQUASHFS_ROOT/app/block-update-checks.sh"
echo "/app/block-update-checks.sh &" >> "$SQUASHFS_ROOT/etc/rc.local"