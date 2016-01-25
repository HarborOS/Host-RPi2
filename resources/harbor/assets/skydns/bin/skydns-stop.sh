#!/bin/bash
source /etc/os-common/common.env
source /etc/skydns/skydns.env

UPSTREAM_DNS=$SKYDNS_UPSTREAM_DNS
# Configure the host to use default dns
cp -f /etc/resolv.conf /etc/resolv.conf.pre-skydns
sed -i '/Managed by HarborOS/d' /etc/resolv.conf
sed -i '/nameserver/d' /etc/resolv.conf
echo "# Managed by HarborOS: skydns" >> /etc/resolv.conf
echo "nameserver $UPSTREAM_DNS" >> /etc/resolv.conf
