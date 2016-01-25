#!/bin/bash

source /etc/etcd/etcd.env
source /etc/docker/docker.env
source /etc/flanneld/flanneld.env
source /etc/skydns/skydns.env
source /etc/kubernetes/kubernetes.env
source /etc/kubernetes/deploy.env

docker pull $KUBERNETES_IMAGE
docker pull $KUBESKY_IMAGE

ETCD_IP=$(ip -f inet -o addr show $ETCD_DEV|cut -d\  -f 7 | cut -d/ -f 1)
DOCKER_IP=$(ip -f inet -o addr show $DOCKER_DEV|cut -d\  -f 7 | cut -d/ -f 1)
SKYDNS_IP=$(ip -f inet -o addr show $DOCKER_DEV|cut -d\  -f 7 | cut -d/ -f 1)
KUBE_IP=$(ip -f inet -o addr show $KUBE_DEV|cut -d\  -f 7 | cut -d/ -f 1)
KUBELET_IP=$(ip -f inet -o addr show $KUBELET_DEV|cut -d\  -f 7 | cut -d/ -f 1)

KUBELET_HOSTNAME=${KUBE_IP}

KUBE_MASTER_HOST=${KUBE_IP}



cat > /etc/kubernetes/config <<EOF
###
# kubernetes system config
#
# The following values are used to configure various aspects of all
# kubernetes services, including
#
#   kube-apiserver.service
#   kube-controller-manager.service
#   kube-scheduler.service
#   kubelet.service
#   kube-proxy.service
# logging to stderr means we get it in the systemd journal
KUBE_LOGTOSTDERR="--logtostderr=true"

# journal message level, 0 is debug
KUBE_LOG_LEVEL="--v=3"

# Should this cluster be allowed to run privileged docker containers
KUBE_ALLOW_PRIV="--allow_privileged=true"

# How the controller-manager, scheduler, and proxy find the apiserver
KUBE_MASTER="--master=http://${KUBE_MASTER_HOST}:${KUBE_PORT}"
EOF

cat > /etc/kubernetes/apiserver <<EOF
###
# kubernetes system config
#
# The following values are used to configure the kube-apiserver
#

# The address on the local server to listen to.
KUBE_API_ADDRESS="--address=0.0.0.0"

# The port on the local server to listen on.
KUBE_API_PORT="--port=${KUBE_PORT}"

# Port minions listen
KUBELET_PORT="--kubelet_port=${KUBELET_PORT}"

# Comma separated list of nodes in the etcd cluster
KUBE_ETCD_SERVERS="--etcd_servers=http://${ETCD_IP}:4001"

# Address range to use for services
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=${FLANNELD_NETWORK}"

# default admission control policies
#KUBE_ADMISSION_CONTROL="--admission_control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota"

# Add your own!
KUBE_API_ARGS="--service-node-port-range=80-30000 --runtime-config=extensions/v1beta1/daemonsets=true"
EOF

cat > /etc/kubernetes/controller-manager <<EOF
###
# The following values are used to configure the kubernetes controller-manager

# defaults from config and apiserver should be adequate

# Add your own!
KUBE_CONTROLLER_MANAGER_ARGS=""
EOF





cat > /etc/kubernetes/scheduler <<EOF
###
# kubernetes scheduler config

# default config should be adequate

# Add your own!
KUBE_SCHEDULER_ARGS=""
EOF







cat > /etc/kubernetes/kubelet <<EOF
###
# kubernetes kubelet (minion) config

# The address for the info server to serve on (set to 0.0.0.0 or "" for all interfaces)
KUBELET_ADDRESS="--address=${KUBELET_IP}"

# The port for the info server to serve on
# KUBELET_PORT="--port=${KUBELET_PORT}"

# You may leave this blank to use the actual hostname
KUBELET_HOSTNAME="--hostname_override=${KUBELET_HOSTNAME}"

# location of the api-server
KUBELET_API_SERVER="--api_servers=http://${KUBE_MASTER_HOST}:${KUBE_PORT}"

# Add your own!
KUBELET_ARGS="--cluster-dns=${SKYDNS_IP} --cluster-domain=${KUBE_DOMAIN}"
EOF
