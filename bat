#!/bin/bash

percent=$(cat /sys/class/power_supply/BAT0/capacity)
ac=$(cat /sys/class/power_supply/AC0/online)

if [ "$ac" = 0 ]
then
	if [[ $percent -ge 90 ]]
	then
		emoji=" "		# 90 - 100
	elif [[ $percent -ge 60 ]]
	then
		emoji=" "		# 60 - 90
	elif [[ $percent -ge 35 ]]
	then
		emoji=" "		# 35 - 60
	elif [[ $percent -ge 15 ]]
	then
		emoji=" "		# 15 - 35
	else
		emoji=" "		# 0 - 15
	fi
else
	ind=$(($(~/scripts/sec)%5))
	emos=(" " " " " " " " " ")
	emoji="${emos[$ind]} "
fi
echo "$emoji $percent"

