#!/bin/bash

SD_DEV=sdf

echo "Resizing Disc Image"
echo -e "d\n2\nn\np\n2\n\n\nw" | fdisk /dev/${SD_DEV}
e2fsck -f /dev/${SD_DEV}2
resize2fs /dev/${SD_DEV}2
