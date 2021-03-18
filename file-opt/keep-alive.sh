#!/bin/bash
## Monitoring the process and restart it if it quits.
## Released by Mdrights under BSD two-clauses Licenses.

while true
do
	if ps -ef | grep -v 'grep' | grep 'python ****'
	then
		echo
	else
		echo "It is not running. Restarting. "
		$HOME/shadowsocksr/shadowsocks/logrun.sh &
	fi

sleep 10m

done
exit
