#!/bin/bash
set -e
# Source the ipa environment variables
source /etc/ipa/master-ip.generated.env
source /etc/os-common/common.env
source /etc/skydns/skydns.env

IPA_SERVER_IP=${IPA_MASTER_IP}
IPA_HOSTNAME=ipa.${OS_DOMAIN}
UPSTREAM_DNS=$SKYDNS_UPSTREAM_DNS

etcdctl set /${OS_DISTRO}/freeipa/status DOWN
etcdctl set /skydns/config "{\"dns_addr\":\"0.0.0.0:53\",\"ttl\":3600, \"nameservers\": [\"$UPSTREAM_DNS:53\"]}"
systemctl restart skydns.service

IPA_DNS_INACTIVE="1"
while true
do
  DNS_RESPONSE=$(dig @$IPA_SERVER_IP $IPA_HOSTNAME | awk '/ANSWER SECTION/ { getline; print }' | awk -F' ' '{print $5}')
  if [ "$DNS_RESPONSE" != "$IPA_SERVER_IP" ]; then
    echo "HarborOS IPA: DOWN"
    etcdctl set /${OS_DISTRO}/freeipa/status DOWN
    etcdctl set /skydns/config "{\"dns_addr\":\"0.0.0.0:53\",\"ttl\":3600, \"nameservers\": [\"$UPSTREAM_DNS:53\"]}"
    if [ "$IPA_DNS_INACTIVE" != "1" ]; then
      systemctl restart skydns.service
      echo "HarborOS IPA: Skydns Restarted"
      IPA_DNS_INACTIVE="1"
    fi
    sleep 5s
  else
    echo "HarborOS IPA: OK"
    etcdctl set /${OS_DISTRO}/freeipa/status UP
    etcdctl set /skydns/config "{\"dns_addr\":\"0.0.0.0:53\",\"ttl\":3600, \"nameservers\": [\"$IPA_SERVER_IP:53\"]}"
    if [ "$IPA_DNS_INACTIVE" != "0" ]; then
      systemctl restart skydns.service
      echo "HarborOS IPA: Skydns Restarted"
      IPA_DNS_INACTIVE="0"
    fi
    DNS_RESPONSE=$(dig $IPA_HOSTNAME | awk '/ANSWER SECTION/ { getline; print }' | awk -F' ' '{print $5}')
    if [ "$DNS_RESPONSE" != "$IPA_SERVER_IP" ]; then
      systemctl restart skydns.service
      echo "HarborOS IPA: Skydns Restarted"
    fi
    sleep 30s
  fi
done
