#!/bin/bash

if [ $UID -ne 0 ]; then
  echo "Error: Please run as root."
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="${REPOSITORY_ROOT:-$(cd "$script_dir/../../.." && pwd)}"

if [ ! -f "$project_root/TOOLS/helpers/utils.sh" ]; then
  echo "Error: utils.sh not found at $project_root/TOOLS/helpers/utils.sh"
  echo "Set REPOSITORY_ROOT to the repo root or run from within the repo."
  exit 1
fi

source "$project_root/TOOLS/helpers/utils.sh" "$project_root"

CURRENT_PATCH_PATH="${CURRENT_PATCH_PATH:-$script_dir}"

if [ -z "$SQUASHFS_ROOT" ]; then
  echo "Error: SQUASHFS_ROOT is not set."
  echo "Run via patch_planner.py or export SQUASHFS_ROOT to your squashfs-root."
  exit 1
fi

if [ ! -d "$SQUASHFS_ROOT" ]; then
  echo "Error: SQUASHFS_ROOT does not exist: $SQUASHFS_ROOT"
  exit 1
fi

for required_file in tailscale tailscaled tailscaled.state tailscale.init; do
  if [ ! -f "$CURRENT_PATCH_PATH/$required_file" ]; then
    echo "Error: Missing required file: $CURRENT_PATCH_PATH/$required_file"
    exit 1
  fi
done

set -x
set -e

echo "Installing Tailscale binaries"
cp "$CURRENT_PATCH_PATH/tailscale" "$SQUASHFS_ROOT/root/tailscale"
cp "$CURRENT_PATCH_PATH/tailscaled" "$SQUASHFS_ROOT/root/tailscaled"
chmod 755 "$SQUASHFS_ROOT/root/tailscale"
chmod 755 "$SQUASHFS_ROOT/root/tailscaled"

if command -v strip >/dev/null 2>&1; then
  echo "Stripping debug symbols from Tailscale binaries"
  strip --strip-debug "$SQUASHFS_ROOT/root/tailscale" || echo "Warning: strip failed for tailscale"
  strip --strip-debug "$SQUASHFS_ROOT/root/tailscaled" || echo "Warning: strip failed for tailscaled"
else
  echo "strip not found; skipping binary stripping"
fi

echo "Installing Tailscale state file"
cp "$CURRENT_PATCH_PATH/tailscaled.state" "$SQUASHFS_ROOT/root/tailscaled.state"
chmod 600 "$SQUASHFS_ROOT/root/tailscaled.state"  

echo "Installing Tailscale init script"
cp "$CURRENT_PATCH_PATH/tailscale.init" "$SQUASHFS_ROOT/etc/init.d/tailscale"
chmod 755 "$SQUASHFS_ROOT/etc/init.d/tailscale"

echo "Enabling Tailscale on boot"
ln -sf /etc/init.d/tailscale "$SQUASHFS_ROOT/etc/rc.d/S99tailscale"
