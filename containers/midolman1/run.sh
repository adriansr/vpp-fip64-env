#!/bin/bash -xe
chmod +x create_veth_pair
chmod +x hexinject
ip netns del vm || true
./create_veth_pair -n vm -i 192.168.0.100/24
ip netns exec vm ip r add default via 192.168.0.1
MAC=$(ip netns exec vm ip link show vmns | awk '/\/ether/ { print $2 }')
test $? -eq 0
echo MAC=$MAC
