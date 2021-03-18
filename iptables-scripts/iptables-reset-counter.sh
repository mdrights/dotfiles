#!/bin/bash

# Reset Iptables OUTPUT counter. Monthly.

echo " Reset Iptables OUTPUT counter...on `date`." 
echo " Reset Iptables OUTPUT counter...on `date`." >> /home/linus/reset-ipt-count.log 
/sbin/iptables -Z OUTPUT 
echo ""

exit
