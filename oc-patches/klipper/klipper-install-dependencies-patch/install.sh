#!/bin/bash

cd /app/deps
mv /opt/var/opkg-lists/entware /tmp/entware
opkg install *.ipk
pip install pyserial-3.4-py2.py3-none-any.whl
mv /tmp/entware /opt/var/opkg-lists/entware