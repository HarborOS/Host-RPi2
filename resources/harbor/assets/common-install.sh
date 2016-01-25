#!/bin/bash


MODULE=os-common
mkdir -p ${SYS_ROOT}/etc/${MODULE}/
/bin/cp -rf ./assets/${MODULE}/etc/* ${SYS_ROOT}/etc/${MODULE}/
mkdir -p ${SYS_ROOT}/var/usrlocal/bin/
chmod +x ./assets/${MODULE}/bin/*
/bin/cp -rf ./assets/${MODULE}/bin/* ${SYS_ROOT}/var/usrlocal/bin/
/bin/cp -rf ./assets/${MODULE}/*.service ${SYS_ROOT}/etc/systemd/system/



MODULE=harbor-network

mkdir -p ${SYS_ROOT}/etc/${MODULE}/
/bin/cp -rf ./assets/${MODULE}/etc/* ${SYS_ROOT}/etc/${MODULE}/
mkdir -p ${SYS_ROOT}/var/usrlocal/bin/
chmod +x ./assets/${MODULE}/bin/*
/bin/cp -rf ./assets/${MODULE}/bin/* ${SYS_ROOT}/var/usrlocal/bin/
/bin/cp -rf ./assets/${MODULE}/*.service ${SYS_ROOT}/etc/systemd/system/


MODULE=etcd
mkdir -p ${SYS_ROOT}/etc/${MODULE}/
/bin/cp -rf ./assets/${MODULE}/etc/* ${SYS_ROOT}/etc/${MODULE}/
mkdir -p ${SYS_ROOT}/var/usrlocal/bin/
chmod +x ./assets/${MODULE}/bin/*
/bin/cp -rf ./assets/${MODULE}/bin/* ${SYS_ROOT}/var/usrlocal/bin/
/bin/cp -rf ./assets/${MODULE}/*.service ${SYS_ROOT}/etc/systemd/system/


MODULE=flanneld
mkdir -p ${SYS_ROOT}/etc/${MODULE}/
/bin/cp -rf ./assets/${MODULE}/etc/* ${SYS_ROOT}/etc/${MODULE}/
mkdir -p ${SYS_ROOT}/var/usrlocal/bin/
chmod +x ./assets/${MODULE}/bin/*
/bin/cp -rf ./assets/${MODULE}/bin/* ${SYS_ROOT}/var/usrlocal/bin/
/bin/cp -rf ./assets/${MODULE}/*.service ${SYS_ROOT}/etc/systemd/system/
/bin/cp -rf ./assets/${MODULE}/*.path ${SYS_ROOT}/etc/systemd/system/
mkdir -p ${SYS_ROOT}/etc/systemd/system/docker.service.d
/bin/cp -rf ./assets/${MODULE}/docker.service.d/10-flanneld-network.conf ${SYS_ROOT}/etc/systemd/system/docker.service.d/10-flanneld-network.conf


MODULE=docker
mkdir -p ${SYS_ROOT}/etc/${MODULE}/
/bin/cp -rf ./assets/${MODULE}/etc/* ${SYS_ROOT}/etc/${MODULE}/
mkdir -p ${SYS_ROOT}/var/usrlocal/bin/
chmod +x ./assets/${MODULE}/bin/*
/bin/cp -rf ./assets/${MODULE}/bin/* ${SYS_ROOT}/var/usrlocal/bin/
/bin/cp -rf ./assets/${MODULE}/*.service ${SYS_ROOT}/etc/systemd/system/


MODULE=skydns
mkdir -p ${SYS_ROOT}/etc/${MODULE}/
/bin/cp -rf ./assets/${MODULE}/etc/* ${SYS_ROOT}/etc/${MODULE}/
mkdir -p ${SYS_ROOT}/var/usrlocal/bin/
chmod +x ./assets/${MODULE}/bin/*
/bin/cp -rf ./assets/${MODULE}/bin/* ${SYS_ROOT}/var/usrlocal/bin/
/bin/cp -rf ./assets/${MODULE}/*.service ${SYS_ROOT}/etc/systemd/system/

firewall-cmd --permanent --zone=public --add-port=53/tcp
firewall-cmd --permanent --zone=public --add-port=53/udp





MODULE=kubernetes

mkdir -p ${SYS_ROOT}/etc/${MODULE}/
/bin/cp -rf ./assets/${MODULE}/etc/* ${SYS_ROOT}/etc/${MODULE}/

mkdir -p ${SYS_ROOT}/var/usrlocal/bin/
chmod +x ./assets/${MODULE}/bin/*
/bin/cp -rf ./assets/${MODULE}/bin/* ${SYS_ROOT}/var/usrlocal/bin/

/bin/cp -rf ./assets/${MODULE}/*.service ${SYS_ROOT}/etc/systemd/system/



MODULE=cockpit

mkdir -p ${SYS_ROOT}/etc/${MODULE}/
/bin/cp -rf ./assets/${MODULE}/etc/* ${SYS_ROOT}/etc/${MODULE}/

mkdir -p ${SYS_ROOT}/var/usrlocal/bin/
chmod +x ./assets/${MODULE}/bin/*
/bin/cp -rf ./assets/${MODULE}/bin/* ${SYS_ROOT}/var/usrlocal/bin/

/bin/cp -rf ./assets/${MODULE}/*.service ${SYS_ROOT}/etc/systemd/system/
/bin/cp -rf ./assets/${MODULE}/kubernetes ${SYS_ROOT}/usr/share/cockpit/

firewall-cmd --permanent --zone=public --add-port=9090/tcp

action=enable

systemctl ${action} os-update
systemctl ${action} harbor-network
systemctl ${action} NetworkManager-wait-online.service

systemctl ${action} etcd-manager
systemctl ${action} etcd

systemctl ${action} skydns-reset
systemctl ${action} skydns-preflight
systemctl ${action} skydns

systemctl ${action} docker-manager
systemctl ${action} docker


(
systemctl ${action} kubernetes-manager
systemctl ${action} kubelet
systemctl ${action} kube-apiserver
systemctl ${action} kube-controller-manager

systemctl ${action} kube-scheduler
systemctl ${action} kubernetes-skydns
systemctl ${action} kube-proxy
)
