#!/bin/sh
# Create a RAM disk with same perms as mountpoint
# Script based on http://itux.idev.pro/2012/04/iservice-speed-up-your-xcode-%D0%BD%D0%B5%D0%BA%D0%BE%D1%82%D0%BE%D1%80%D1%8B%D0%B5-%D1%81%D0%BF%D0%BE%D1%81%D0%BE%D0%B1%D1%8B/ with some additions
# Usage: sudo ./xcode_ramdisk.sh start

USERNAME=$(logname)

TMP_DIR="/private/tmp"
RUN_DIR="/var/run"
SYS_CACHES_DIR="/Library/Caches"
USER_CACHES_DIR="/Users/$USERNAME/Library/Caches"
DEV_CACHES_DIR="/Users/$USERNAME/Library/Developer/Xcode/DerivedData"
DEV_IPHONE_DIR="/Users/$USERNAME/Library/Application Support/iPhone Simulator"

RAMDisk() {
mntpt="$1"
rdsize=$(($2*1024*1024/512))
echo "Creating RamFS for $mntpt $rdsize"
# Create the RAM disk.
dev=`hdik -drivekey system-image=yes -nomount ram://$rdsize`
# Successfull creation...
if [ $? -eq 0 ] ; then
# Create HFS on the RAM volume.
newfs_hfs $dev
# Store permissions from old mount point.
eval `/usr/bin/stat -s "$mntpt"`
# Mount the RAM disk to the target mount point.
mount -t hfs -o union -o nobrowse -o nodev -o noatime $dev "$mntpt"
# Restore permissions like they were on old volume.
chown $st_uid:$st_gid "$mntpt"
chmod $st_mode "$mntpt"
fi
}

# Test for arguments.
if [ -z $1 ]; then
echo "Usage: $0 [start|stop|restart] "
exit 1
fi

# Source the common setup functions for startup scripts
test -r /etc/rc.common || exit 1 
. /etc/rc.common

StartService () {
ConsoleMessage "Starting RamFS disks..."

RAMDisk "$TMP_DIR" 128
RAMDisk "$RUN_DIR" 64
RAMDisk "$SYS_CACHES_DIR" 64
RAMDisk "$USER_CACHES_DIR" 1024
RAMDisk "$DEV_CACHES_DIR" 1024
RAMDisk "$DEV_IPHONE_DIR" 1024

#RAMDisk /var/db 1024
#mkdir -m 1777 /var/db/mds
}
StopService () {
ConsoleMessage "Stopping RamFS disks, nothing will be done here..."
# diskutil unmount /private/tmp /private/var/run
# diskutil unmount /private/var/run
}

RestartService () {
ConsoleMessage "Restarting RamFS disks, nothing will be done here..."
}

RunService "$1"