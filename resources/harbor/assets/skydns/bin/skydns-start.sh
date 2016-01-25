#!/bin/bash
set -e

source /etc/os-common/common.env
source /etc/skydns/skydns.env
source /etc/etcd/etcd.env

UPSTREAM_DNS=$SKYDNS_UPSTREAM_DNS
SKYDNS_IP=$(ip -f inet -o addr show $SKYDNS_DEV|cut -d\  -f 7 | cut -d/ -f 1)
ETCD_IP=$(ip -f inet -o addr show $ETCD_DEV|cut -d\  -f 7 | cut -d/ -f 1)


# Configure the host to use skydns
cp -f /etc/resolv.conf /etc/resolv.conf.pre-skydns
sed -i '/Managed by HarborOS/d' /etc/resolv.conf
sed -i '/nameserver/d' /etc/resolv.conf
echo "# Managed by HarborOS: skydns" >> /etc/resolv.conf
echo "nameserver ${SKYDNS_IP}" >> /etc/resolv.conf



exec /bin/skydns -addr=${SKYDNS_IP}:53 -machines=http://${ETCD_IP}:4001 -nameservers=$UPSTREAM_DNS:53
