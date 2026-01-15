#!/opt/bin/bash

echo 201 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio201/direction
echo "Turning off bed..."
echo 0 > /sys/class/gpio/gpio201/value
echo 201 > /sys/class/gpio/unexport

echo 140 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio140/direction
echo "Turning off hotend..."
echo 0 > /sys/class/gpio/gpio140/value
echo 140 > /sys/class/gpio/unexport

sleep 2

echo 201 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio201/direction
echo "Turning on bed..."
echo 1 > /sys/class/gpio/gpio201/value
echo 201 > /sys/class/gpio/unexport

echo 140 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio140/direction
echo "Turning on hotend..."
echo 1 > /sys/class/gpio/gpio140/value
echo 140 > /sys/class/gpio/unexport

sleep 2

echo "Booting firmware on hotend..."
/app/mcu-flasher --skip --no-wait /dev/serial/by-id/usb-ShenZhenCBD_STM32_Virtual_ComPort_367935503233-if00

echo "Booting firmware on bed..."
/app/mcu-flasher --skip --no-wait /dev/ttyS4

# TODO: Remove log
/app/dsp-to-serial > /user-resource/dsptoserial.log 2>&1 &

sleep 2

# TODO: Remove log
/app/serial-multiplexer --with-real-ports /dev/serial/by-id/usb-Linux_6.12.25+rpt-rpi-v8_with_3f980000.usb_Gadget_Serial_v2.4-if00 /app/klipper/runtime/config.toml > /user-resource/serialmultiplexer.log 2>&1 &