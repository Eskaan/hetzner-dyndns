#!/bin/bash
set -u

GET_IP_URL="https://api.ipify.org/"
DOMAIN_NAME="eskaan.de"

UPDATE_SCRIPT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/update.sh
LOGGER_SCRIPT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/logger.sh

DNS_IP="$(dig +short @hydrogen.ns.hetzner.com $DOMAIN_NAME A)"
CURR_IP="$(curl -s $GET_IP_URL)"

if [ "$DNS_IP" != "$CURR_IP" ]; then
	if [ ${#CURR_IP} -lt 15 ]; then
		$LOGGER_SCRIPT continue "Updating $DNS_IP to $CURR_IP"
		$UPDATE_SCRIPT
	else 
		$LOGGER_SCRIPT continue "Error: api result longer than expected."
	fi
else
	echo "Not updating."
fi
