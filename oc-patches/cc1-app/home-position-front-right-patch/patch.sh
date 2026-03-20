#!/bin/bash

if [ $UID -ne 0 ]; then
  echo "Error: Please run as root."
  exit 1
fi

set -e

project_root="$REPOSITORY_ROOT"
source "$project_root/TOOLS/helpers/utils.sh" "$project_root"
check_tools "patch"

cd "$SQUASHFS_ROOT/app/resources/configs"
patch < "$CURRENT_PATCH_PATH/patch.diff"