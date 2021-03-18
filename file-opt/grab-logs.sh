#!/bin/bash
#Grab the logs occured during specific time duration.
#

oldTime=$(date -d "" +%H:%M:%S)
now=$(date +%H:%M:%S)

cat /var/log/****.log | awk -v oldTime=$oldTime -v now=$now '{ if($3>oldTime && $3<now) print $0 }'

## Or, e.g. printf("%s %s", $2, $3) 
