#!/bin/bash
# copied from Archwiki's chroot page.

echo "You must in the directory which you want to chroot into. Your current dir is: $(pwd) "

mount -t proc proc proc/
mount --rbind /sys sys/
mount --rbind /dev dev/
mount --rbind /run run/


chroot $(pwd) /bin/bash

#source /etc/profile
#source ~/.bashrc

#export PS1="(chroot) $PS1"
#PS1='(chroot:debian)\w:# '

# cp /etc/resolv.conf etc/ # doesn't work on my Debian (maybe due to NM)
# rm the symlink and re-create /etc/resolv.conf

# If you have done,
# umount --recursive /location/of/new/root

# run graphical apps:
# xhost +local:
# export DISPLAY=:0
