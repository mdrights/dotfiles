#!/bin/bash 

CHROOT_PATH="/home/$USER/gentoo" 

echo "Entering gentoo's root dir: $CHROOT_PATH ..."
cd $CHROOT_PATH 
mount | grep $CHROOT_PATH/dev || sudo mount --bind /dev dev 
mount | grep $CHROOT_PATH/sys || sudo mount --bind /sys sys 
mount | grep $CHROOT_PATH/proc || sudo mount -t proc proc proc 
mount | grep $CHROOT_PATH/dev/pts || sudo mount -t devpts devpts dev/pts -o gid=5,nosuid,noexec
mount | grep $CHROOT_PATH/dev/shm || sudo mount -t tmpfs -o mode=1777 /dev/shm dev/shm

cp /etc/resolv.conf etc 
#sudo chroot --userspec=$USER:users . /bin/bash 
sudo chroot --userspec=root:root . /bin/bash 
echo "You must manually unmount $CHROOT_PATH/dev, $CHROOT_PATH/sys, $CHROOT_PATH/proc." 
