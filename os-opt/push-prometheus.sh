#!/bin/sh

# DATE 		2020-03-02


UPDAY=$(uptime | awk '{ print $3 }')
UPHOUR=$( uptime |awk -F, '{ print $2 }' | cut -d':' -f1)

#echo "uptime ${UPTIME}" | curl --data-binary @- http://localhost:9091/metrics/job/uptime/instance/rpi2

cat <<EOF | curl --data-binary @- http://localhost:9091/metrics/job/uptime/instance/rpi2
# TYPE upday counter
upday{label="uptime"} $UPDAY
# TYPE uptime gauge
uptime{label="hour"} $UPHOUR
EOF
