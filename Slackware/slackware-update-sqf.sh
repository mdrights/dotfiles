#!/bin/bash
# BRIEF     This script is to update my sqf file when there is newer tagfiles in the official Slackware repo.
# AUTHOR    mdrights


TAG_DIR='/mnt/hd/user/slackware-repo/slackware64-current/slackware64'

ALL_PKG=$(cat $TAG_DIR/*/tagfile |awk -F: '{ print $1 }')

SQF_DIR='/mnt/hd/user/repo/LiveSlak/sbopkg-queues'

SQF=$(cat $SQF_DIR/liveslak-full.sqf | egrep -v '^#|^$' |awk '{print $1}')

for pkg in $SQF; do
	#echo ">> $pkg: "
	# Non exhaustive search
	#ret=$(egrep -i $pkg < <(echo "$ALL_PKG") >/dev/null; echo $?)
	ret=$(egrep -i ^$pkg$ < <(echo "$ALL_PKG") >/dev/null; echo $?)
	if [[ $ret -eq 0 ]]; then
		echo "@@ $pkg is there!"
	fi
done
