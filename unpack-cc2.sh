#!/bin/bash
if [ $UID -ne 0 ]; then
  echo "Error: Please run as root."
  exit 1
fi
python3 TOOLS/cc2_swu_decrypt.py FW/cc2-01.03.01.89-18d82e89afe354a5801102751e838fcb-release-abroad.zip.sig FW/cc2-01.03.01.89-18d82e89afe354a5801102751e838fcb-release-abroad.bin
rm -Rf unpacked2 && mkdir -p unpacked2/tmp unpacked2/update
unzip ./FW/cc2-01.03.01.89-18d82e89afe354a5801102751e838fcb-release-abroad.zip -d ./unpacked2/tmp/
./TOOLS/cc2_swu_decrypt.py ./unpacked2/tmp/ec_eeb001_01.03.01.89_20251226194334.swu.sig ./unpacked2/update/update.swu
./TOOLS/cc2_swu_decrypt.py ./unpacked2/tmp/ota-package-list.json.sig ./unpacked2/tmp/ota-package-list.json
cd ./unpacked2
cpio -idv <./update/update.swu
unsquashfs rootfs
