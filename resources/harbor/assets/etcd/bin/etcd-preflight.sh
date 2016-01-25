#!/bin/bash

source /etc/etcd/etcd.env

ETCD_IP=$(ip -f inet -o addr show $ETCD_DEV|cut -d\  -f 7 | cut -d/ -f 1)
ETCD_NAME=$(hostname --fqdn)




echo "----------------------------------------------------------------------------------------------------------------------------------------------"
echo "${OS_DISTRO}: ETCD: Creating Master discovery url if required"
echo "----------------------------------------------------------------------------------------------------------------------------------------------"
while grep -q "{{MASTER_ETCD_DISCOVERY_TOKEN}}" /etc/etcd/etcd.env; do
    # This is needed as sometimes DNS breaks down momentarity during inital boot.
    until [[ $ETCD_DISCOVERY_TOKEN == https://discovery.etcd.io* ]] ;
    do
        ETCD_DISCOVERY_TOKEN=$(curl -w "\n" "https://discovery.etcd.io/new?size=${ETCD_INITIAL_NODES}")
    done
    sed -i "s,{{MASTER_ETCD_DISCOVERY_TOKEN}},$ETCD_DISCOVERY_TOKEN,g" /etc/etcd/etcd.env
    source /etc/etcd/etcd.env
done



echo "----------------------------------------------------------------------------------------------------------------------------------------------"
echo "${OS_DISTRO}: ETCD"
echo "----------------------------------------------------------------------------------------------------------------------------------------------"

cat > /etc/etcd/etcd.conf << EOF
# [member]
ETCD_NAME="$ETCD_NAME"
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://127.0.0.1:2380,http://$ETCD_IP:7001"
ETCD_LISTEN_CLIENT_URLS="http://127.0.0.1:2379,http://$ETCD_IP:4001"
#
# [cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://$ETCD_IP:7001"
ETCD_ADVERTISE_CLIENT_URLS="http://$ETCD_IP:4001"
ETCD_DISCOVERY="${ETCD_DISCOVERY_TOKEN}"
EOF
