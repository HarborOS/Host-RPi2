#!/bin/bash

source /etc/etcd/etcd.env
source /etc/docker/docker.env
source /etc/flanneld/flanneld.env
source /etc/skydns/skydns.env
source /etc/kubernetes/kubernetes.env
source /etc/kubernetes/deploy.env

ETCD_IP=$(ip -f inet -o addr show $ETCD_DEV|cut -d\  -f 7 | cut -d/ -f 1)
DOCKER_IP=$(ip -f inet -o addr show $DOCKER_DEV|cut -d\  -f 7 | cut -d/ -f 1)
SKYDNS_IP=$(ip -f inet -o addr show $DOCKER_DEV|cut -d\  -f 7 | cut -d/ -f 1)
KUBE_IP=$(ip -f inet -o addr show $KUBE_DEV|cut -d\  -f 7 | cut -d/ -f 1)
KUBELET_IP=$(ip -f inet -o addr show $KUBELET_DEV|cut -d\  -f 7 | cut -d/ -f 1)




docker run -d \
  --net='host'
  --name kube2sky \
  ${KUBESKY_IMAGE} \
    -domain="${KUBE_DOMAIN}" \
    -etcd-server="http://${ETCD_IP}:4001" \
    -kube_master_url="http://${KUBE_IP}:${KUBE_PORT}"
