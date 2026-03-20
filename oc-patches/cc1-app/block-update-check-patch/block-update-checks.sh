#!/opt/bin/bash

for run in {1..20}; do 
    echo "Block update checks ${run}"

    iptables -A OUTPUT -d mms.chituiot.com -j REJECT

    sleep 10
done