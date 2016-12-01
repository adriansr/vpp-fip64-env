#!/bin/bash -x

neutron router-create provider-router
neutron net-create uplink --provider:network_type uplink
neutron subnet-create --disable-dhcp --ip-version 6 --name uplink-subnet uplink 2001::/64
PORTID1=$(neutron port-create uplink --binding:host_id midolman1 --binding:profile type=dict interface_name=bgp0 --fixed-ip ip_address=2001::2 -c id -f value | tail -1)
neutron router-interface-add provider-router port=$PORTID1
neutron net-create public --router:external true
neutron subnet-create --name public-subnet --ip-version 6 public 1000::/120
neutron router-create tenant-router
neutron router-gateway-set tenant-router public
neutron net-create tenant
neutron subnet-create --name tenant-subnet tenant 192.168.0.0/24
neutron router-interface-add tenant-router tenant-subnet
#PORTID2=$(neutron port-create tenant --binding:host_id midolman2 --binding:profile type=dict interface_name=bgp0 --fixed-ip ip_address=192.168.0.100 --mac-address 7e:1f:05:55:36:64 -c id -f value | tail -1)
#neutron floatingip-create --port-id $PORTID2 public

