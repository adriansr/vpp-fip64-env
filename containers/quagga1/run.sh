#!/bin/bash -xe
ip -6 r del default || true
ip -6 a add 2001::10/64 dev bgp1
ip -6 r add default via 2001::2
# ping vpp
ping6 -c 5 2001::2
# ping fip
ping6 -c 10 1000::3

