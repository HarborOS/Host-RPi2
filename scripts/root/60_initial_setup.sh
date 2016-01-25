#!/bin/bash

[[ -e "$RESOURCEDIR/harbor" ]] || exit 0
echo "Adding harbor..."
mkdir -p "$MNTDIR/usr/local/lib/harbor" || exit 1
/bin/cp -rf $RESOURCEDIR/harbor/* "$MNTDIR/usr/local/lib/harbor/" || exit 1



cat > /etc/redhat-release <<EOF
Harbor IoT Host (Fedora 23)
EOF

cat > /etc/os-release <<EOF
NAME=Harbor
VERSION="23 (Twenty Three)"
ID=fedora
VERSION_ID=23
PRETTY_NAME="Harbor IoT Host (Fedora 23)"
ANSI_COLOR="0;34"
CPE_NAME="cpe:/o:fedoraproject:fedora:23"
HOME_URL="http://harboros.net/"
BUG_REPORT_URL="http://harboros.net/"
REDHAT_BUGZILLA_PRODUCT="Fedora"
REDHAT_BUGZILLA_PRODUCT_VERSION=23
REDHAT_SUPPORT_PRODUCT="Fedora"
REDHAT_SUPPORT_PRODUCT_VERSION=23
PRIVACY_POLICY_URL=http://harboros.net/PrivacyPolicy
EOF
