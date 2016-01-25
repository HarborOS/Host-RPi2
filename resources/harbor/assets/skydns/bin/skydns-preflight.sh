#!/bin/bash
while ! echo 'HarborOS: ETCD: now up' | etcdctl member list ; do sleep 1; done
source /etc/os-common/common.env
source /etc/skydns/skydns.env

etcdctl set /${OS_DISTRO}/freeipa/status DOWN
UPSTREAM_DNS=$SKYDNS_UPSTREAM_DNS
etcdctl set /skydns/config "{\"dns_addr\":\"0.0.0.0:53\",\"ttl\":3600, \"nameservers\": [\"$UPSTREAM_DNS:53\"]}"
