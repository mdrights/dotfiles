#!/bin/bash

#FILE    ipfs-add-my-hash.sh
#DATE    2020-06-06

set -euxo pipefail

HASH='ipfs/QmNm45RagXiktLp7C46rnFKsjGTNKatTRLfEM4BEKmeXsJ'

GW_LIST='/tmp/ipfs-gw.list'
OUTPUT='/tmp/ipfs-gw-hash.list'

for gw in $(cat ${GW_LIST}); do
	URL="${gw}/${HASH}"
	echo "$URL" |tee -a $OUTPUT
done

exit
