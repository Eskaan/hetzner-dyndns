#!/bin/bash
set -u

GET_IP4_URL="https://api.ipify.org/"
GET_IP6_URL="https://api64.ipify.org/"
API_TOKEN="FpDjj9AaN82FD4Pz8KqL8TedxxpYURzN"
ZONE_ID="ox7nRCQ49bhNBDgsLQC7J3"

LOGGER_SCRIPT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/logger.sh

# get current ip address
IP4="$(curl -s "$GET_IP4_URL")"
IP6="$(curl -s "$GET_IP6_URL")"

if [ -z "$IP4" ]; then
        $LOGGER_SCRIPT continue "Could not get current IP address."
    exit 1
fi

update_record() {
	RES=$(
		curl -sX "PUT" "https://dns.hetzner.com/api/v1/records/$1" \
			-H 'Content-Type: application/json' \
			-H "Auth-API-Token: $API_TOKEN" \
			-d '{"value":"'$3'","type":"'$2'","name":"'$4'","zone_id":"'$ZONE_ID'","ttl":600}'
	)
	if echo "$RES" | jq -e ".error" >> /dev/null; then
		$LOGGER_SCRIPT continue "Update failed with '$RES'"
	fi
}
update_record 58179801307df4acfda2a8be8a1d4c0b A $IP4 @
update_record 071954c2f1b4c34efb461834ff7b8c68 A $IP4 mail
update_record 423ec165bc6f34b2e4ec0b3a90b3d633 A $IP4 www
update_record d6d7c78e2d8b54b99a2363f7e4148bfb AAAA $IP6 @
update_record 5483ce578918b2d77e37eb8add0d8788 AAAA $IP6 mail
update_record c68ca41f8b4e84ec9d216a8627f1822a AAAA $IP6 www

exit 0
