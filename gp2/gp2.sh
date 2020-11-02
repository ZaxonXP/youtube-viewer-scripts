#!/bin/bash
export PATH=$PATH:$HOME/Batch

if [[ "$1" == "-o" ]]; then
    gvim_minimal.sh -o $2 > /dev/null 2>&1 
    shift
else
    gvim_minimal.sh $1 > /dev/null 2>&1 
fi

name=$(echo "$1" | cut -d'.' -f1 | rev | cut -d"/" -f1 | rev)
main=$((xdotool search --class xterm ; xdotool search --name $name) | sort | uniq -d)
wid=$((xdotool search --class Gvim ; xdotool search --name $name) | sort | uniq -d)

xdotool windowmove $wid 960 120
# resize terminal window when run from the "show_list.sh" script
if [ "$main" != "" ]; then
    wmctrl -ir $main -b remove,maximized_vert,maximized_horz
    xdotool windowsize $main 958 1056
fi
gapless_play2.sh $1
