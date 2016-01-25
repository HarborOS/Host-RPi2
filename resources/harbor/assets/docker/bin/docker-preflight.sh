#!/bin/bash

source /etc/etcd/etcd.env
source /etc/docker/docker.env
source /etc/skydns/skydns.env

ETCD_IP=$(ip -f inet -o addr show $ETCD_DEV|cut -d\  -f 7 | cut -d/ -f 1)
ETCD_NAME=$(hostname --fqdn)

DOCKER_IP=$(ip -f inet -o addr show $DOCKER_DEV|cut -d\  -f 7 | cut -d/ -f 1)
SKYDNS_IP=$(ip -f inet -o addr show $SKYDNS_DEV|cut -d\  -f 7 | cut -d/ -f 1)

cat > /etc/sysconfig/docker <<EOF
# /etc/sysconfig/docker

# Modify these options if you want to change the way the docker daemon runs
OPTIONS='--dns ${SKYDNS_IP} -H tcp://${DOCKER_IP}:2375 -H unix:///var/run/docker.sock -s overlay'

DOCKER_CERT_PATH=/etc/docker

# If you want to add your own registry to be used for docker search and docker
# pull use the ADD_REGISTRY option to list a set of registries, each prepended
# with --add-registry flag. The first registry added will be the first registry
# searched.
ADD_REGISTRY='$ADD_REGISTRY'

# If you want to block registries from being used, uncomment the BLOCK_REGISTRY
# option and give it a set of registries, each prepended with --block-registry
# flag. For example adding docker.io will stop users from downloading images
# from docker.io
# BLOCK_REGISTRY='--block-registry'

# If you have a registry secured with https but do not have proper certs
# distributed, you can tell docker to not look for full authorization by
# adding the registry to the INSECURE_REGISTRY line and uncommenting it.
INSECURE_REGISTRY='$INSECURE_REGISTRY'

# On an SELinux system, if you remove the --selinux-enabled option, you
# also need to turn on the docker_transition_unconfined boolean.
# setsebool -P docker_transition_unconfined 1

# Location used for temporary files, such as those created by
# docker load and build operations. Default is /var/lib/docker/tmp
# Can be overriden by setting the following environment variable.
# DOCKER_TMPDIR=/var/tmp

# Controls the /etc/cron.daily/docker-logrotate cron job status.
# To disable, uncomment the line below.
# LOGROTATE=false
EOF
