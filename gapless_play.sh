#!/bin/bash

# Gaples playback of the audio album
#
# input file format:
#   mm:ss | yt-id | artist | title

soc1=/tmp/soc1
soc2=/tmp/soc2
curr=/tmp/soc_used

# Run the xterm with the title display for the currently played song
monitor=$(ps aux | grep -v grep | grep xterm | grep monitor_ | tr -s " " | cut -d" " -f2 | xargs)

if [[ "$monitor" != "" ]]; then
    kill $monitor
    sleep 1
fi

xterm -n "GAPLESS_PLAY" -T "GAPLESS_PLAY" -geometry 119x6+0+2 -e bash $HOME/Batch/monitor_gapless_play.sh "$1" &

touch $soc1 $soc2
#---------------------------------------
get_pause() {
    if [[ $1 == 0 ]]; then
        echo ""
    else
        echo "--pause"
    fi
}

#---------------------------------------
get_soc() {
    if [[ $(( $1 % 2 )) == 1 ]]; then
        echo $3
    else 
        echo $2
    fi
}

#---------------------------------------
i=0

cat "$1" | while IFS=\| read -r f1 f2 f3 f4
do
    id=${f2% }
    id=${id# }

    socket=$( get_soc $i $soc1 $soc2 )
    pause=$( get_pause $i )

    mpv --input-ipc-server="$socket" --no-video $pause "https://www.youtube.com/watch?v=$id" & 
    pids[$i]=$!

    if [[ $i > 0 ]]; then
        prev_idx=$(($i - 1))
        prev_pid=${pids[$prev_idx]}

        tail --pid=$prev_pid -f /dev/null
        echo '{ "command": ["set_property", "pause", false] }' | socat - $socket
    fi
    echo $socket > $curr

    i=$((i + 1))
done

#rm $soc1 $soc2 $curr
