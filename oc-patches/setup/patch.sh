#!/bin/bash

set -e
cd "$SQUASHFS_ROOT"

# Empty the file so all the patches can add their own code to rc.local
rm ./etc/rc.local
cp "$CURRENT_PATCH_PATH/rc.local" ./etc/rc.local
chmod 774 ./etc/rc.local
chown root:root ./etc/rc.local