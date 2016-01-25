#!/bin/bash

source /etc/etcd/etcd.env
source /etc/flanneld/flanneld.env

ETCD_IP=$(ip -f inet -o addr show $ETCD_DEV|cut -d\  -f 7 | cut -d/ -f 1)
FLANNELD_IP=$(ip -f inet -o addr show $FLANNELD_DEV|cut -d\  -f 7 | cut -d/ -f 1)



echo "${OS_DISTRO}: Flanneld networking configuration"
cat > /etc/sysconfig/flanneld-conf.json << EOF
{
  "Network": "${FLANNELD_NETWORK}",
  "SubnetLen": 24,
  "Backend": {
    "Type": "udp"
  }
}
EOF

/bin/curl -L http://$ETCD_IP:4001/v2/keys/flanneld/network/config -XPUT --data-urlencode value@/etc/sysconfig/flanneld-conf.json


echo "${OS_DISTRO}: Flanneld: Service"
cat > /etc/sysconfig/flanneld << EOF
# Flanneld configuration options
# etcd url location.  Point this to the server where etcd runs
FLANNEL_ETCD="http://${ETCD_IP}:4001"

# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
FLANNEL_ETCD_KEY="/flanneld/network"

# Any additional options that you want to pass
FLANNEL_OPTIONS="-iface=${FLANNELD_IP}"
EOF
