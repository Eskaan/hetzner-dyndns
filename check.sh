#!/bin/bash
GET_IP_URL="https://api.ipify.org/"
UPDATE_SCRIPT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/update.sh
LOGGER_SCRIPT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/logger.sh
source $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/freenom.conf

HOST_RESULT="$(host $freenom_domain_name 80.80.80.80)"
DNS_IP=$(echo $HOST_RESULT | cut -d' ' -f 12)
CURR_IP="$(curl -s $GET_IP_URL)"

$LOGGER_SCRIPT start

$LOGGER_SCRIPT continue "Current IP: $CURR_IP :: DNS IP: $DNS_IP"

if [ $DNS_IP = $CURR_IP ]; then
	$LOGGER_SCRIPT continue "No change is needed, exiting"
else
	if [ ${#CURR_IP} -lt 15 ]; then
		$LOGGER_SCRIPT continue "Change is needed procedeing to execute freenom update script"
		$UPDATE_SCRIPT
	else 
		$LOGGER_SCRIPT continue "Error: api result longer than expected."
	fi
fi
$LOGGER_SCRIPT end
