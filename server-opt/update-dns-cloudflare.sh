#!/bin/bash
# FILE		update DNS records for Cloudflare.
# Update	2020-03-16

ret=1
PWD=$(dirname $0)
source $PWD/.env
#### sourced from .env ####
#TOKEN=
#ZONEID=
#RECORDID=
#CIDFILE=

CID=$(cat $CIDFILE 2>/dev/null)
if [ -z "$CID" ]; then
	echo "> No IPFS cid obtained. Quit."
	exit 1
fi

# Get the record
	curl -s -S -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONEID}/dns_records/${RECORDID}" \
		-H "Authorization: Bearer ${TOKEN}" \
		-H "Content-Type:application/json" \
		| jq '.'


# Update the record
while [ "$ret" -eq 1 ]; do
	n=1

	echo -e "\n> Updating the TXT record..."

	curl -s -S -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONEID}/dns_records/${RECORDID}" \
		-H "Authorization: Bearer ${TOKEN}" \
		-H "Content-Type:application/json" \
		--data '{"type":"TXT","name":"_dnslink.ipfs.XXX","content":"dnslink=/ipfs/'${CID}'/","ttl":600,"proxied":false}' \
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
