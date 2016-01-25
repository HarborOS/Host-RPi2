#!/bin/sh

if [ ! -f /usr/bin/docker ]; then
dnf install -y docker
fi

if [ ! -f /usr/bin/flanneld ]; then
dnf install -y flannel
fi

if [ ! -f /usr/bin/etcd ]; then
dnf install -y etcd
fi

if [ ! -f /usr/bin/cockpit-bridge ]; then
dnf install -y cockpit-bridge cockpit-docker cockpit
fi

if [ ! -f /usr/sbin/brctl ]; then
dnf install -y bridge-utils
fi

if [ ! -f /usr/bin/skydns ]; then
dnf install -y skydns
fi
