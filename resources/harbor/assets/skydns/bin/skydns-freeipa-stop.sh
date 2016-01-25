#!/bin/bash

source /etc/os-common/common.env
source /etc/skydns/skydns.env

etcdctl set /skydns/config "{\"dns_addr\":\"0.0.0.0:53\",\"ttl\":3600, \"nameservers\": [\"$UPSTREAM_DNS:53\"]}"
systemctl restart skydns.service
