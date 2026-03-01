#!/bin/bash

# This patch installs the UART-enabled UBoot and boot0 binaries
# The magic to build these live in the uboot/ dir in this repo!

set -e

project_root="$REPOSITORY_ROOT"

# Source the utils.sh file for variables and helper functions
source "$project_root/TOOLS/helpers/utils.sh" "$project_root"

# Check required tools
check_tools "unzip"

# Define paths
uboot_zip_file="$project_root/uboot/uboot.zip"
target_folder="$project_root/unpacked"

# Check the uboot zip file exists
if [ ! -f "$uboot_zip_file" ]; then
  echo -e "${RED}ERROR: Cannot find the file '$uboot_zip_file' ${NC}"
  exit 1
fi

# Check the target folder exists
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
  exit 2
fi

echo -e "${YELLOW}INFO: Installing UART-enabled UBoot and boot0 files ...${NC}"
echo -e "${YELLOW}INFO: Extracting to $target_folder ...${NC}"

# Unzip the uboot package into the target folder
unzip -oq "$uboot_zip_file" -d "$target_folder"

echo -e "${GREEN}INFO: UART-enabled UBoot and boot0 have been installed ${NC}"
