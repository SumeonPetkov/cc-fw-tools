#!/bin/bash

set -e

cd "$SQUASHFS_ROOT"
mkdir ./app/deps

cp "$CURRENT_PATCH_PATH/install.sh" ./app/deps/install.sh
chmod a+x ./app/deps/install.sh
cd "$CURRENT_PATCH_PATH"
cp ./packages/* "$SQUASHFS_ROOT/app/deps"

cat ./rc.local >> "$SQUASHFS_ROOT/etc/rc.local"