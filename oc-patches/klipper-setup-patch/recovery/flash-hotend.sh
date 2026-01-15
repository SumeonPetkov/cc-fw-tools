#!/opt/bin/bash

echo 140 > /sys/class/gpio/unexport
echo 140 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio140/direction
echo "Turning off hotend..."
echo 0 > /sys/class/gpio/gpio140/value
sleep 3
echo "Turning on hotend..."
echo 1 > /sys/class/gpio/gpio140/value
echo 140 > /sys/class/gpio/unexport
sleep 3

MAJOR=$((1 + $RANDOM % 10))
MINOR=$((1 + $RANDOM % 10))
PATCH=$((1 + $RANDOM % 10))
VERSION="${MAJOR}.${MINOR}.${PATCH}"
echo "Flashing hotend firmware version ${VERSION}..."
/app/mcu-flasher --firmware-version ${VERSION} --firmware ../firmware/hotend.bin --no-wait /dev/serial/by-id/usb-ShenZhenCBD_STM32_Virtual_ComPort_367935503233-if00 2>&1
exit 0