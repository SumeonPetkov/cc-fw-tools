#!/bin/bash

set -e

cd "$SQUASHFS_ROOT"
mkdir ./app/packages

cp "$CURRENT_PATCH_PATH/oc-install-extra-packages" ./etc/init.d/oc-install-extra-packages
chmod a+x ./etc/init.d/oc-install-extra-packages
ln -s ../init.d/oc-install-extra-packages ./etc/rc.d/S82oc-install-extra-packages
chmod a+x ./etc/rc.d/S82oc-install-extra-packages

cd "$CURRENT_PATCH_PATH"
cp ./packages/* "$SQUASHFS_ROOT/app/packages"