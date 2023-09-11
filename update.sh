#!/bin/bash
set -u

# load config
# Suplies GET_IP_URL API_TOKEN ZONE_ID DOMAIN_NAME LOG_PATH SUBDOMAINS
source /etc/hetzner-dns/config

logger() {
	if [ ! -e $LOG_PATH ]; then
		touch $LOG_PATH
	fi
	case $1 in
		erase)
			rm $LOG_PATH
			;;
		continue)
			echo "[$(date)]	$2" | tee -a $LOG_PATH
			;;
		*)
			echo "$1 - unknown argument"
			exit 1
			;;
	esac
}

check() {
	DNS_IP4="$(dig +short @hydrogen.ns.hetzner.com $DOMAIN_NAME A)"
	DNS_IP6="$(dig +short @hydrogen.ns.hetzner.com $DOMAIN_NAME AAAA)"
	IP4="$(curl -4s "$GET_IP_URL")"
	IP6="$(curl -6s "$GET_IP_URL")"
	IP4_REGEX='^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$'
	IP6_REGEX='([a-f0-9:]+:+)+[a-f0-9]+'

	if [ "$DNS_IP4" != "$IP4" ]; then
		if echo $IP4 | grep -Pqe $IP4_REGEX; then
			update automatic all "$IP4" "$IP6"
		else
			logger continue "API returned invalid IPv4 '$IP4'"
		fi
	elif [ "$DNS_IP6" != "$IP6" ]; then
		if echo $IP6 | grep -Pqe $IP6_REGEX; then
			update automatic v6 "" "$IP6"
		else
			logger continue "API returned invalid IPv6 '$IP6'"
		fi
	fi
}


# Takes zone-id, record-id, type, name, value
update_record() {
	RES=$(
		curl -s -X "PUT" "https://dns.hetzner.com/api/v1/records/$2" \
			-H 'Content-Type: application/json' \
			-H "Auth-API-Token: $API_TOKEN" \
			-d '{"zone_id": "'$1'", "type": "'$3'", "name": "'$4'", "value": "'$5'", "ttl": 600}'
		)
	if echo "$RES" | jq -e ".error" >> /dev/null; then
		logger continue "Update for $4 $3 failed with code $(echo "$RES" | jq -jr ".error | if type == \"object\" then .code,\": \",.message else . end")"
	fi
}

update() {
	# get current ip address
	IP4="$3"
	IP6="$4"
	
	case $1 in
		manual)
			logger continue "Manual update to $IP4 [$IP6]";;
		automatic)
			logger continue "Update to $IP4 [$IP6] for $2";;
	esac

	zone_id=$(curl -s \
        -H "Auth-API-Token: ${API_TOKEN}" \
        "https://dns.hetzner.com/api/v1/zones?search_name=${DOMAIN_NAME}" | \
        jq -re ".zones[] | select(.name == \"${DOMAIN_NAME}\") | .id")
	
	records=$(curl -s \
        -H "Auth-API-Token: $API_TOKEN" \
        "https://dns.hetzner.com/api/v1/records?zone_id=$zone_id")
	
	# Update record id's
	for domain in "${SUBDOMAINS[@]}"; do
		echo "Updating $domain.$DOMAIN_NAME"
		if [[ "$2" == "all" || "$2" == "v4" ]]; then
			# IPv4 changes
  	  record_id=$(echo $records | jq -re '.records[] | select(.name == "'$domain'") | select(.type == "A") | .id')
			if [ -z "$record_id" ]; then
		    	logger continue "Could not get A record for '$domain'"
		  	  exit 1
			fi
			update_record "$zone_id" "$record_id" "A" "$domain" "$IP4"
		fi

		if [[ "$2" == "all" || "$2" == "v6" ]]; then
			# IPv6 changes
  	  record_id=$(echo $records | jq -re '.records[] | select(.name == "'$domain'") | select(.type == "AAAA") | .id')
			if [ -z "$record_id" ]; then
		    	logger continue "Could not get AAAA record for '$domain'"
		  	  exit 1
			fi
			update_record "$zone_id" "$record_id" "AAAA" "$domain" "$IP6"
		fi
	done
}

# Input processing
case $1 in
	update)
		update manual all "$(curl -4s "$GET_IP_URL")" "$(curl -6s "$GET_IP_URL")"
		;;
	check)
		check
		;;
	*)
		echo "Unkown option '$1'. Valid are 'update' and 'check'"
		exit 1
		;;
esac
exit 0
