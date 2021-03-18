#!/bin/sh

/usr/sbin/openvpn --dev tun0 \
--port 65530 \
--proto tcp-server \
--ifconfig 10.9.8.1 10.9.8.3 \
--secret /home/linus/static.key \
--keepalive 10 600 \
--comp-lzo \
--user openvpn \
--group openvpn \
--persist-tun \
--persist-key \
--push "dhcp-option DNS 8.8.8.8" \
--status /var/log/openvpn-status.log \
--log-append /var/log/openvpn.log \
--script-security 2 \
--verb 4
