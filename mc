#!/bin/bash
# media control script using playerctl
# the player is chosen from ~/.config/mc.conf if $2 is not passed
# editing ~/.config/mc.conf directly is discouraged, use mc-config instead
# if file is absent then -p is not used while calling playerctl
# Usage:
# mc play
# mc pause
# mc pp
# mc stat / status
# mc stop
# mc next / n
# mc prev / p  / previous
# mc meta / metadata
# mc title / tit / t
# mc artist / art / a
# mc titart / ta
# mc arttit / at

confpath="${HOME}/.config/mc.conf"
if [ "$2" != "" ]; then
	player="-p $2"
elif [ -r $confpath ]; then
	player="-p $(cat $confpath | head -n1)"
else
	player=""
fi
c="playerctl $player"
m="metadata"
mf="metadata --format"
tf="{{title}}"
af="{{artist}}"
case $1 in
	play) ;&
	pause) ;&
	status) ;&
	stop) ;&
	next) ;&
	previous) ;&
	$m) $c $1;;
	pp) $c play-pause;;
	stat) $c status;;
	n) $c next;;
	p) ;&
	prev) $c previous;;
	meta) $c $m;;
	t) ;&
	tit) ;&
	title) $c $m title;;
	a) ;&
	art) ;&
	artist) $c $m artist;;
	ta) ;&
	titart) $c $mf "$tf - $af";;
	at) ;&
	arttit) $c $mf "$af - $tf";;
	*) echo "invalid argument";;
esac
