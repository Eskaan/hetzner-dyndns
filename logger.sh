#!/bin/bash
FULL_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/log.log
if [ ! -e $FULL_PATH ]; then
	touch $FULL_PATH
fi
case $1 in
	erase)
		rm $FULL_PATH
		;;
	continue)
		echo "[$(date)]	$2" >> $FULL_PATH
		echo $2
		;;
	*)
		echo "$1 - unknown argument"
		exit 1
		;;
esac
