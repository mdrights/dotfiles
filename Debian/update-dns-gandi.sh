#!/bin/sh
# FILE		update DNS records for Gandi.
# Update	2020-02-20

ret=1
APIKEY=
UUID=
CIDFILE=

CID=$(cat $CIDFILE 2>/dev/null)
if [ -z "$CID" ]; then
	echo "> No IPFS cid obtained. Quit."
	exit 1
fi

# Get records
#curl -H "X-Api-Key: $APIKEY" https://dns.api.gandi.net/api/v5/zones/$UUID/records # |jq '.'

# Create a snapshot
#curl -X POST -H "Content-Type: application/json" -H "X-Api-Key: $APIKEY" https://dns.api.gandi.net/api/v5/zones/$UUID/snapshots

# List snapshots
#curl -H "X-Api-Key: $APIKEY" https://dns.api.gandi.net/api/v5/zones/$UUID/snapshots

while [ "$ret" -eq 1 ]; do
	n=1

	echo "> Delete a TXT record"
	curl -s -S -X DELETE -H "Content-Type: application/json" -H "X-Api-Key: $APIKEY" https://dns.api.gandi.net/api/v5/zones/$UUID/records/_dnslink.ipfs/TXT

	echo "\n> Add a new TXT record"
	curl -s -S -X POST -H "Content-Type: application/json" \
				 -H "X-Api-Key: $APIKEY" \
				 -d '{"rrset_ttl": 600, "rrset_values": ["\"dnslink=/ipfs/'${CID}'/\""]}' \
				 https://dns.api.gandi.net/api/v5/zones/$UUID/records/_dnslink.ipfs/TXT \
				 && ret=0

	n=$(( n + 1 ))
	if [ "$n" -ge 3 ]; then
		break
	fi
done

if [ "$ret" -eq 0 ]; then
	exit 0
else
	exit 1
fi
