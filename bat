#!/bin/bash
for bat in /sys/class/power_supply/BAT*; do
	level=$(cat $bat/capacity)
	status=$(cat $bat/status)
	if [ "$status" == "Charging" ]; then
		echo "`colr green` $level%`colr default`"
		continue
	fi
	case $level in
		?) echo -n "`colr red`  ";;
		1?) echo -n "`colr yellow` ";;
		[23]?) echo -n " ";;
		[456]?) echo -n " ";;
		[78]?) echo -n " ";;
		[9]?|???) echo -n " ";;
		*) echo -n "";;
	esac
	echo -n "$level%"
	colr default
done
