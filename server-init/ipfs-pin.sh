#!/bin/sh


IPFS='/opt/kubo/ipfs'

CID=$(curl -sS https://ipfs.ngocn2.org/ipfs.txt)
echo ">> Latest CID:" $CID

OLD_CID=$($IPFS pin ls --type=recursive | awk '{ print $1 }')

echo ">> Current CID:" $OLD_CID

#read -p "xxxx" YES

if [ -n "$OLD_CID" ]; then  $IPFS pin rm $OLD_CID ; fi

$IPFS pin add --progress $CID
