# Harbor Image Builder for Raspberry Pi 2

This repo contains a script and assets that produces a disk image, with docker, kubernetes and cockpit for the Rasberry Pi 2. It is intended for use as part of the Harbor IoT platform but can also be used to form a stand alone Kubernetes Cluster.

## Usage

By default, mkimage.sh will create an image with a 50MB boot filesystem and a 900MB root filesystem.  If you wish to change these defaults, create a ```settings.conf``` file using ```settings.conf.example``` as a template.

```bash
IMAGEURL="http://mirror.pnl.gov/fedora/linux/releases/23/Images/armhfp/Fedora-Minimal-armhfp-23-10-sda.raw.xz"

# size in MB size of the boot partition (vfat) in MB
BOOTSIZE=100

# size of the root partition (ext4) in MB
#
# NOTE
# The rootfs on the minimal image is ext4. On the server image, it is XFS.
# Because the upstream raspberrypi/linux prebuilt kernel does not
# build-in XFS support (it compiles it as a module), an XFS rootfs is
# currently not supported.
ROOTSIZE=1800

# create compressed image
COMPRESS=0

# don't run initial-setup on first boot
# https://fedoraproject.org/wiki/InitialSetup
DISABLE_INITIAL_SETUP=1
```

Then simply run the script as root (root privileges are needed to mount filesystem images as loop block devices)

```bash
sudo ./build.sh
```

The script
* Downloads the official image from IMAGEURL
* Decompresses the official image
* Strips the root filesystem image out of the official image (root.img)
* Creates a vfat boot partition image (boot.img) of size BOOTSIZE
* Clones the raspberrypi/firmware repository from Github
* Copies the boot files into the boot filesystem
* Resizes the root filesystem to ROOTSIZE
* Copies the kernel modules into the root filesystem
* Generates an /etc/fstab
* Creates a disk image file, partitions it, and copies the boot and root filesystem images into the created partitions

NOTE: This will take a considerable amount of disk space and time depending on your disk and internet speeds.  If default settings are used, the disk space requirement is 4.4GB.

To remove all temporary resources needed for building, use the ```clean.sh``` script
