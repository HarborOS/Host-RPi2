#!/bin/bash

source /etc/os-common/common.env
source /etc/harbor-network/harbor-network.env



DOMAIN=${OS_DOMAIN}

if [[ "${ROLE}" == "master" ]]
  then
  FIXED_IP_START=${FIXED_IP_START}
  HOSTNAME=master
elif [[ "${ROLE}" == "node" ]]
  then
  FIXED_IP_START=$(ip -f inet -o addr show $INITIAL_DEV|cut -d\  -f 7 | cut -d/ -f 1)
fi
echo $FIXED_IP_START


N=1; IP_1=$(echo $FIXED_IP_START | awk -F'.' -v N=$N '{print $N}')
N=2; IP_2=$(echo $FIXED_IP_START | awk -F'.' -v N=$N '{print $N}')
N=3; IP_3=$(echo $FIXED_IP_START | awk -F'.' -v N=$N '{print $N}')
N=4; IP_4=$(echo $FIXED_IP_START | awk -F'.' -v N=$N '{print $N}')
N=1; IP_STEP_1=$(echo $FIXED_IP_STEP | awk -F'.' -v N=$N '{print $N}')
N=2; IP_STEP_2=$(echo $FIXED_IP_STEP | awk -F'.' -v N=$N '{print $N}')
N=3; IP_STEP_3=$(echo $FIXED_IP_STEP | awk -F'.' -v N=$N '{print $N}')
N=4; IP_STEP_4=$(echo $FIXED_IP_STEP | awk -F'.' -v N=$N '{print $N}')




if [ ! -f /etc/harbor-network/status ]; then
    echo "Config Starting"
    echo "CONFIG STARTED">> /etc/harbor-network/status


    echo "${OS_DISTRO}: Network Configuration"
    # initscripts don't like this file to be missing.
    cat > /etc/sysconfig/network << EOF
NETWORKING=yes
NOZEROCONF=yes
EOF

    echo "${OS_DISTRO}: HOSTNAME"
    if [[ "${ROLE}" == "master" ]]
      then
      HOSTNAME=master
    elif [[ "${ROLE}" == "node" ]]
      then
      HOSTNAME=$(cat /etc/machine-id | cksum | awk '{print $1}')
    fi
    echo $HOSTNAME.$DOMAIN > /etc/hostname
    echo "$FIXED_IP_START $HOSTNAME.$DOMAIN $HOSTNAME" >> /etc/hosts


    echo "${OS_DISTRO}: INTERFACES"

    ETHERNET_DEVICES=$(nmcli -t -f GENERAL.TYPE,GENERAL.DEVICE -m tabular device show | sed -n '/ethernet/{n;p;}')



    COUNT=0
    COUNT_EXT=0
    NETWORK_SCRIPTS_LOC=/etc/sysconfig/network-scripts
    for ETHERNET_DEVICE in $ETHERNET_DEVICES; do
      ETHERNET_DEVICE_IP=$(ip -f inet -o addr show $ETHERNET_DEVICE|cut -d\  -f 7 | cut -d/ -f 1)
      if [[ ! $ETHERNET_DEVICE_IP ]]; then
        ETHERNET_DEVICE_IP=$(echo "$(expr $IP_1 + $(expr $IP_STEP_1 \* $COUNT)).$(expr $IP_2 + $(expr $IP_STEP_2 \* $COUNT)).$(expr $IP_3 + $(expr $IP_STEP_3 \* $COUNT)).$(expr $IP_4 + $(expr $IP_STEP_4 \* $COUNT))")
        ETHERNET_DEVICE_PREFIX=$FIXED_IP_PREFIXES
        ETHERNET_DEVICE_PROTO='none'
        BRIDGE_DEVICE=br${COUNT}
        COUNT=$(expr 1 + $COUNT)
      else
        ETHERNET_DEVICE_PROTO=$(ip -f inet -o addr show $ETHERNET_DEVICE|cut -d\  -f 12)
        ETHERNET_DEVICE_PREFIX=$(ip -f inet -o addr show $ETHERNET_DEVICE|cut -d\  -f 7 | cut -d/ -f 2)
        if [[ "${ROLE}" == "master" ]]; then
          if [[ "${ETHERNET_DEVICE_PROTO}" == "dynamic" ]]; then
            ETHERNET_DEVICE_PROTO='dhcp'
            BRIDGE_DEVICE=brex${COUNT_EXT}
            COUNT_EXT=$(expr 1 + $COUNT_EXT)
          else
            ETHERNET_DEVICE_PROTO='none'
            BRIDGE_DEVICE=br${COUNT}
            COUNT=$(expr 1 + $COUNT)
          fi
        elif [[ "${ROLE}" == "node" ]]; then
          if [[ "${ETHERNET_DEVICE_PROTO}" == "dynamic" ]]; then
            ETHERNET_DEVICE_PROTO='dhcp'
          else
            ETHERNET_DEVICE_PROTO='none'
          fi
          BRIDGE_DEVICE=br${COUNT}
          COUNT=$(expr 1 + $COUNT)
        fi
      fi

      if [[ "${ETHERNET_DEVICE_PROTO}" == "dhcp" ]]; then
        echo "${BRIDGE_DEVICE}: DHCP (Currently: ${ETHERNET_DEVICE_IP})"
        cat > ${NETWORK_SCRIPTS_LOC}/ifcfg-${BRIDGE_DEVICE} << EOF
DEVICE="${BRIDGE_DEVICE}"
TYPE="Bridge"
ONBOOT="yes"
DELAY=0
BOOTPROTO="${ETHERNET_DEVICE_PROTO}"
IPV6INIT="no"
IPV6_AUTOCONF="no"
IPV6_DEFROUTE="no"
IPV6_FAILURE_FATAL="no"
IPV6_PRIVACY="no"
EOF
      else
        echo "${BRIDGE_DEVICE}: Static: ${ETHERNET_DEVICE_IP}"
        cat > ${NETWORK_SCRIPTS_LOC}/ifcfg-${BRIDGE_DEVICE} << EOF
DEVICE="${BRIDGE_DEVICE}"
TYPE="Bridge"
ONBOOT="yes"
BOOTPROTO="${ETHERNET_DEVICE_PROTO}"
IPADDR="${ETHERNET_DEVICE_IP}"
PREFIX="${ETHERNET_DEVICE_PREFIX}"
IPV6INIT="no"
IPV6_AUTOCONF="no"
IPV6_DEFROUTE="no"
IPV6_FAILURE_FATAL="no"
IPV6_PRIVACY="no"
EOF
      fi

      echo "${ETHERNET_DEVICE}: Config device to use ${BRIDGE_DEVICE}"
      cat > ${NETWORK_SCRIPTS_LOC}/ifcfg-${ETHERNET_DEVICE} << EOF
DEVICE="${ETHERNET_DEVICE}"
ONBOOT="yes"
TYPE="Ethernet"
BOOTPROTO="none"
BRIDGE="${BRIDGE_DEVICE}"
EOF
    done
    echo "CONFIG WRIITEN">> /etc/harbor-network/status
    nmcli connection reload
    systemctl restart network || nmcli connection reload
    nmcli connection reload
    systemctl restart network
    echo "CONFIG COMPLETE">> /etc/harbor-network/status
fi
