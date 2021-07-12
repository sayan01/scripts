#!/bin/bash
# dependencies: mpv youtube-dl fzf rofi/dmenu gnu-grep

# NOTE:  if you dont have gnu grep you can replace grep with rg

# explain usage
function usage () {
    echo "usage: yt"
    echo "    -h        help"
    echo "    -c        channels/subscriptions"
    echo "    -s query  search"
    echo "    -g / -r   gui mode (rofi/dmenu)"
    echo "    -m        music mode (audio only) [dont use with -r]"
    echo "  nothing     use defaults (search from prompt)"
	echo
	echo "add channel names to the file $sublistpath to show them"
	echo "in yt -c option. First word should be channel url, optionally"
	echo "followed by tab and then anything else (channel name/description)"
	echo "channels not in sublist can be viewed by typing their url in the prompt"
	echo 
	echo "example file format:"
	echo "markrober       Mark Rober"
	echo "vsauce1         VSauce          Michael Steven's Channel"
	echo "BlackGryph0n    Black Gryph0n   Gabriel Brown signs stuff"
	echo "TomScottGo      Tom Scott"
	echo "danielthrasher  Daniel Thrasher"
    exit 0
}

# dont use defaults
useDefaults="f"

# no args -> use defaults
if [[ ${#} -eq 0 ]]; then
    useDefaults="t"
fi

# available flags
optstring=":s:cgrhm"

defcmd="fzf"
defaction="s"
guicmd="rofi -dmenu -i" #uncomment next line for dmenu
#guicmd="dmenu -i -l 15"

#Defaults
promptcmd="$defcmd"
action="$defaction"
isGui="f"
query=""
mpv_options=""

# subscription list
mkdir -p "${HOME:-}/.config/yt"
sublistpath="${HOME:-}/.config/yt/sublist"
sublist=""
[ -f "$sublistpath" ] && sublist=$(cat "$sublistpath") 

# if not using defaults search for flags
if [[ $useDefaults = "f" ]]; then
    while getopts ${optstring} arg; do
        case "${arg}" in
            s) 
                # search in youtube for a query
                action="s"
                query="${OPTARG}" ;;
            c) 
                # search in subscriptions for specific channel
                action="c"
                query="${OPTARG}" ;;
            g|r) 
                # set gui mode to true and change the prompt to gui prompt
                isGui="t"
                promptcmd="$guicmd" ;;
            m)
               # make the mpv headless
                mpv_options+="--no-video" ;;
            h) 
                # display help / usage
                usage ;;
            \?) 
                # wrong args -> exit with explanation of usage
                echo "invalid option: -${OPTARG}"
                echo
                usage
				exit 1 ;;
            :) 
                # missing args -> exit with explanation of usage
                echo "Option -${OPTARG} needs an argument"
                echo
                usage
				exit 1 ;;

        esac
    done
fi

# if no query is set with flags then ask for one
if [ -z "$query" ]; then
    # ask for a channel
    if [[ $action = "c" ]]; then
        # if in gui mode use gui prompt
        if [[ $isGui = "t" ]]; then 
			query=$($promptcmd -p "Channel: " <<< "$sublist")
            promptcmd="$promptcmd -p Video:"
        else
            query=$($promptcmd --print-query <<< "$sublist" | tail -n1)
        fi
		query=$(echo "$query" | awk '{print $1}')
    else
        # ask for a query
        # if in gui mode use gui prompt
        if [[ $isGui = "t" ]]; then 
            query=$(echo | $promptcmd -p "Search: ")
            promptcmd="$promptcmd -p Video:"
        else
            echo -n "Search: "
            read -r query
        fi
    fi
fi 

# program cancelled -> exit
if [ -z "$query" ]; then exit; fi 

# clean query / channel
query=$(sed \
  -e 's|+|%2B|g'\
  -e 's|#|%23|g'\
  -e 's|&|%26|g'\
  -e 's| |+|g' <<< "$query")


# if channel look for channel vids
if [[ $action = "c" ]]; then
    response=$(curl -s "https://www.youtube.com/c/$query/videos" |\
      sed "s/{\"gridVideoRenderer/\n\n&/g" |\
      sed "s/}]}}}]}}/&\n\n/g" |\
      awk -v ORS="\n\n" '/gridVideoRenderer/')

    # if unable to fetch the youtube results page, inform and exit
    if ! grep -q "gridVideoRenderer" <<< "$response"; then echo "unable to fetch yt"; exit 1; fi

    # regex expression to match video entries from yt channel page
    # get the list of videos and their ids to ids
    ids=$(awk -F '[""]' '{print $6 "\t" $50;}' <<< "$response" | grep "^\S")

    # url prefix for videos
    videolink="https://youtu.be/"

    # prompt the results to user infinitely until they exit (escape)
    while true; do
      choice=$(echo -e "$ids" | cut -d'	' -f2 | $promptcmd) # dont show id
      if [ -z "$choice" ]; then exit; fi	# if esc-ed then exit
      id=$(echo -e "$ids" | grep -Fwm1 "$choice" | cut -d'	' -f1) # get id of choice
      echo -e "$choice\t($id)"
      case $id in
          ???????????) mpv "$videolink$id" "$mpv_options" ;;
          *) exit ;;
      esac
    done
else
    # if in search show query result vids
    response="$(curl -s "https://www.youtube.com/results?search_query=$query" |\
      sed 's|\\.||g')"
    # if unable to fetch the youtube results page, inform and exit
    if ! grep -q "script" <<< "$response"; then echo "unable to fetch yt"; exit 1; fi
    # regex expression to match video and playlist entries from yt result page
    vgrep='"videoRenderer":{"videoId":"\K.{11}".+?"text":".+?[^\\](?=")'
    pgrep='"playlistRenderer":{"playlistId":"\K.{34}?","title":{"simpleText":".+?[^\"](?=")'
    # grep the id and title
    # return them in format id (type) title
    getresults() {
        grep -oP "$1" <<< "$response" |\
          awk -F\" -v p="$2" '{ print $1 "\t" p " " $NF}'
    }
    # get the list of videos/playlists and their ids in videoids and playlistids
    videoids=$(getresults "$vgrep")
    playlistids=$(getresults "$pgrep" "(playlist)")
    # if there are playlists or videos, append them to list
    [ -n "$playlistids" ] && ids="$playlistids\n"
    [ -n "$videoids" ] && ids="$ids$videoids"
    # url prefix for videos and playlists
    videolink="https://youtu.be/"
    playlink="https://youtube.com/playlist?list="
    # prompt the results to user infinitely until they exit (escape)
    while true; do
        choice=$(echo -e "$ids" | cut -d'	' -f2 | $promptcmd) # dont show id
        if [ -z "$choice" ]; then exit; fi	# if esc-ed then exit
        id=$(echo -e "$ids" | grep -Fwm1 "$choice" | cut -d'	' -f1) # get id of choice
        echo -e "$choice\t($id)"
        case $id in
            # 11 digit id = video
            ???????????) mpv "$videolink$id" "$mpv_options" ;;
            # 34 digit id = playlist
            ??????????????????????????????????) mpv "$playlink$id" "$mpv_options" ;;
            *) exit ;;
        esac
    done
fi
