#!/bin/bash
PATH=$PATH:~/scripts
percent=$(cat /sys/class/power_supply/BAT0/capacity)
ac=$(cat /sys/class/power_supply/AC0/online)

if [ "$ac" = 0 ] # if not charging, set emoji according to battery level
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
	elif [[ $percent -ge 5 ]]
	then
		emoji=" "		# 5 - 15
	else
		emoji="$(colr red) " # 0 - 5
	fi
else # if charging
	ind=$(($(~/scripts/sec)%5))
	emos=(" " " " " " " " " ")
	emoji="$(colr green)${emos[$ind]} "
fi
echo "$emoji $percent%$(colr default)"

