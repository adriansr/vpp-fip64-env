#!/bin/bash -xe
MAC=${1?}
echo "Using MAC = $MAC"

. keystonerc

for GROUP in $(neutron security-group-list -c id -f value)
do
	neutron security-group-rule-create --direction ingress --ethertype ipv4 $GROUP
done

neutron router-create edge
neutron net-create uplink-net --tenant_id admin --provider:network_type uplink
neutron subnet-create --tenant_id admin --disable-dhcp --ip-version 6 --name uplink-subnet-6 uplink-net 2001::0/64
neutron subnet-create --tenant_id admin --disable-dhcp --ip-version 4 --name uplink-subnet-4 uplink-net 200.0.0.0/24
PORT=$(neutron port-create uplink-net --binding:host_id midolman1 --binding:profile type=dict interface_name=bgp0 --fixed-ip ip_address=2001::2 --fixed-ip ip_address=200.0.0.1 -c id -f value | tail -1)
test ! -z "${PORT?}"
neutron router-interface-add edge port=$PORT

neutron router-update --route destination=::/0,nexthop=2001::1 edge

neutron net-create public-network --router:external true
SID=$(neutron subnet-create --name public-subnet-6 --ip-version 6 public-network 1000::/120 -c id -f value | tail -1)
test ! -z "${SID?}"
neutron subnet-create --name public-subnet-4 --ip-version 4 public-network 1.0.0.0/24

neutron router-create tenant-router
neutron router-gateway-set tenant-router public-network

neutron net-create tenant-network
neutron subnet-create --name tenant-subnet tenant-network 192.168.0.0/24
neutron router-interface-add tenant-router tenant-subnet

PORT2=$(neutron port-create tenant-network --binding:host_id midolman1 --binding:profile type=dict interface_name=vmdp --fixed-ip ip_address=192.168.0.100 --mac-address $MAC -c id -f value | tail -1)
test ! -z "${PORT2?}"
neutron floatingip-create --port-id $PORT2 --subnet $SID public-network
