#!/opt/bin/bash

echo 201 > /sys/class/gpio/unexport
echo 201 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio201/direction
echo "Turning off bed..."
echo 0 > /sys/class/gpio/gpio201/value
sleep 3
echo "Turning on bed..."
echo 1 > /sys/class/gpio/gpio201/value
echo 201 > /sys/class/gpio/unexport
sleep 3

MAJOR=$((1 + $RANDOM % 10))
MINOR=$((1 + $RANDOM % 10))
PATCH=$((1 + $RANDOM % 10))
VERSION="${MAJOR}.${MINOR}.${PATCH}"
echo "Flashing bed firmware version ${VERSION}..."
/app/mcu-flasher --firmware-version ${VERSION} --firmware ../firmware/bed.bin --no-wait /dev/ttyS4
exit 0