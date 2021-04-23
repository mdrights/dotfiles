#!/bin/ash


# https://lists.alpinelinux.org/~alpine/users/%3CCAEhkKgV-OdZ8y406_yynrH7tcxjgXkKzSc6dCSZ_a6CUPUfBiA%40mail.gmail.com%3E
# Remount kernel module dir /.modloop as an overlay, to allow writing

modprobe overlay
mkdir -p /.modloop.lower /.modloop.upper /.modloop.workdir
mount /dev/loop0 /.modloop.lower
umount /.modloop/
mount -t overlay -o lowerdir=/.modloop.lower,upperdir=/.modloop.upper,workdir=/.modloop.workdir none /.modloop
lbu include /.modloop.upper
lbu commit -d

# Manually get the Wireguard kernel module to avoid installing
# the wireguard-rpi2 which does not work with diskless systems

cd /tmp
pkgname=$(apk list | grep wireguard-rpi2 | cut -d " " -f 1)
wget http://dl-cdn.alpinelinux.org/alpine/v3.12/community/armhf/$pkgname.apk
mkdir /tmp/$pkgname
tar -xzf $pkgname.apk -C /tmp/$pkgname
mkdir -p /lib/modules/$(uname -r)/extra/
cp /tmp/$pkgname/lib/modules/$(uname -r)/extra/wireguard.ko \
   /lib/modules/$(uname -r)/extra/
rm -fr /tmp/$pkgname /tmp/$pkgname.apk
depmod

===========================

# Create an init script to remount the /.modloop overlay on next boot
cat > /etc/init.d/modloopoverlay <<EOF
#!/sbin/openrc-run

depend() {
     before networking
     need modules
}

start() {
     ebegin "Starting modloop overlay"
     modprobe overlay
     mkdir -p /.modloop.lower /.modloop.upper /.modloop.workdir
     if [ ! -d /.modloop.lower/modules ]; then
         mount /dev/loop0 /.modloop.lower
     fi
     umount /.modloop
     mount -t overlay -o 
lowerdir=/.modloop.lower,upperdir=/.modloop.upper,workdir=/.modloop.workdir 
none /.modloop
     eend 0
}
EOF
chmod +x /etc/init.d/modloopoverlay
/etc/init.d/modloopoverlay restart
rc-update add modloopoverlay boot
lbu include /etc/init.d/modloopoverlay
lbu commit -d
