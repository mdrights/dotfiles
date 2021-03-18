#! /bin/sh
# Modified by root based on lowe's.

set -e

IPT="/usr/sbin/iptables"
#lan="10.1.0.0/16"
#dmz="192.168.100.0/24"
#dns1="192.168.100.2/32"
#mail="192.168.100.10/32"
#exch="10.1.0.10/32"
#local="192.168.100.10"
#bcast1="192.168.100.255"
#bcast2="255.255.255.255"
#mcast="224.0.0.0/8"

case "$1" in
  start)
        echo "Setting iptables policies..."
        # Flush old rules, delete chains
        $IPT -F
        $IPT -X

        # Construct the default policy -- drop everything
        echo "    Setting policies..."
        $IPT -P INPUT DROP
        $IPT -P OUTPUT ACCEPT
        $IPT -P FORWARD DROP

        $IPT -N local
        $IPT -N stateful
        $IPT -N inbound
        $IPT -N outbound
        $IPT -N log

        # Statefullness
        echo "    Setting stateful inspection..."
        $IPT -A stateful -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
        $IPT -A stateful -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT

        $IPT -A INPUT  -p tcp -j stateful
        $IPT -A INPUT  -p udp -j stateful
        $IPT -A OUTPUT -p tcp -j stateful
        $IPT -A OUTPUT -p udp -j stateful
        ########

        # Accept loopback traffic
        echo "    Accepting loopback traffic..."
        $IPT -A local  -s 127.0.0.1/8 -d 127.0.0.1/8 -j ACCEPT
        $IPT -A local  -j DROP

        $IPT -A INPUT  -s 127.0.0.1/8 -j local
        $IPT -A OUTPUT -s 127.0.0.1/8 -j local
        ########

        # Inbound traffic to accept
        echo "    Setting rules for inbound traffic..."

        # Rate limiting rules: 
        #      Set rates with burst for new conns, then log/drop the excess
        #$IPT -A inbound -p tcp --syn -m limit --limit 4/s --limit-burst 10 -j ACCEPT
        $IPT -A inbound -p tcp --dport 22 -m limit --limit 4/s --limit-burst 10       -j ACCEPT
		$IPT -A inbound -p tcp -m tcp --dport 80 -j LOG --log-prefix "[WEB-in] "
		$IPT -A inbound -p tcp -m tcp --dport 443 -j LOG --log-prefix "[WEB-in] "
        $IPT -A inbound -p tcp --dport 80 -m limit --limit 4/s --limit-burst 10       -j ACCEPT
        $IPT -A inbound -p tcp --dport 443 -m limit --limit 4/s --limit-burst 10      -j ACCEPT
        $IPT -A inbound -p tcp --syn -j LOG
        $IPT -A inbound -p tcp --syn -j DROP

        $IPT -A inbound -p udp -m state --state NEW -m limit --limit 1/s --limit-burst 5 -j ACCEPT
        $IPT -A inbound -p udp -m state --state NEW                                      -j LOG
        $IPT -A inbound -p udp -m state --state NEW                                      -j DROP
        $IPT -A inbound -p icmp           --icmp-type 8 -m limit --limit 1/s --limit-burst 5  -j ACCEPT
        $IPT -A inbound -p icmp           --icmp-type 11 -m limit --limit 1/s --limit-burst 5  -j ACCEPT

        $IPT -A INPUT -p tcp  -j inbound
        $IPT -A INPUT -p icmp -j inbound

        # Drop these to avoid logging them
        #$IPT -A INPUT -p udp  -d $bcast1                   -j DROP
        #$IPT -A INPUT -p udp  -d $bcast2   --dport 67      -j DROP
        #$IPT -A INPUT         -d $mcast                    -j DROP
        ########

        # Outbound traffic to allow
        echo "    Setting rules for outbound traffic..."
        #$IPT -A OUTPUT -p tcp -d $lan     --dport 80    -j REJECT
        ########

        # Log all dropped packets
        echo "    Setting logging rules..."
        $IPT -A log -j LOG -m limit --limit 4/minute --limit-burst 3 --log-level info --log-prefix "IPTABLES: "
        $IPT -A log -j DROP

        $IPT -A INPUT  -j log
        #$IPT -A OUTPUT -j log
        ########
        ;;

  stop)
        echo "Flushing iptables..."
        echo "    WARNING: system security will be diminished!"
        $IPT -F
        $IPT -X

        $IPT -P INPUT ACCEPT
        $IPT -P OUTPUT ACCEPT
        $IPT -P FORWARD ACCEPT

        ;;

  restart)
	$0 stop
	sleep 1
	$0 start
	;;

  *)
        echo "Usage: /etc/init.d/iptables.rules {start|stop}"
        exit 1
esac

exit 0
