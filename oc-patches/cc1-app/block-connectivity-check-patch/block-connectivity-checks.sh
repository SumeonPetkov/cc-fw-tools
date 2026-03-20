#!/opt/bin/bash

for run in {1..20}; do 
    echo "Block connectivity checks ${run}"

    iptables -A OUTPUT -d detectportal.firefox.com -j REJECT
    iptables -A OUTPUT -d www.msftconnecttest.com -j REJECT
    iptables -A OUTPUT -d www.apple.com -j REJECT
    iptables -A OUTPUT -d captive.apple.com -j REJECT
    iptables -A OUTPUT -d connectivitycheck.gstatic.com -j REJECT
    iptables -A OUTPUT -d www.google.com -j REJECT
    iptables -A OUTPUT -d google.com -j REJECT
    iptables -A OUTPUT -d www.google-analytics.com -j REJECT
    iptables -A OUTPUT -d wifi.vivo.com.cn -j REJECT
    iptables -A OUTPUT -d connectivitycheck.platform.hicloud.com -j REJECT
    iptables -A OUTPUT -d connect.rom.miui.com -j REJECT

    sleep 60
done