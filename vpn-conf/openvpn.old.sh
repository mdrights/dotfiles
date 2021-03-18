#!/bin/sh

/usr/sbin/openvpn --dev tun0 --port 65530 --proto tcp-server --ifconfig 10.9.8.1 10.9.8.2 --secret /etc/openvpn/static.key --keepalive 10 120 --status openvpn-status.log -log openvpn.log --verb 4
