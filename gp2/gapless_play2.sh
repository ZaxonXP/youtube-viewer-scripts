#!/bin/bash

# Gaples playback of the audio album
#
# input file format:
#   mm:ss | yt-id | artist | title

soc1=/tmp/soc1
soc2=/tmp/soc2
curr=/tmp/soc_used
tdir=/tmp/gp_tmp

mkdir "$tdir"

# Run the xterm with the title display for the currently played song
monitor=$(ps aux | grep -v grep | grep xterm | grep monitor_ | tr -s " " | cut -d" " -f2 | xargs)

if [[ "$monitor" != "" ]]; then
    kill $monitor
    sleep 1
fi

xterm -n "GAPLESS_PLAY" -T "GAPLESS_PLAY" -geometry 119x7-0+0 -e bash $HOME/Batch/monitor_gapless_play2.sh "$1" &

touch $soc1 $soc2
#---------------------------------------
prefix_echo () {
  if [[ "$(($1 % 2))" == "0" ]]; then
      color=green
  else
      color=cyan
  fi
  perl -sne 'use Term::ANSIColor;$|=1; print colored("[$pre]\t$_", $col)' -- -col="$color" -pre="$2"
}

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
cache_id() {
    local dir=$1
    local id=$2

    echo -ne "Caching '$id'"
    
    youtube-viewer -q --no-wget-dl --no-ytdl -noI -A -d --resolution=audio --downloads-dir=$dir --filename=*ID* "https://www.youtube.com/watch?v=$id" 2>&1 > /dev/null &

    # wait for the file to get cached
    while true
    do
        if [ -f $dir/$id ]; then
            echo "done"
            break
        fi
        echo -ne "."
        sleep 1
    done

}

#---------------------------------------
cleanup() {
    if [ -d $tdir ]; then
        rm -r "$tdir"
    fi
}

trap 'cleanup' SIGINT

#---------------------------------------
i=0

cat "$1" | while IFS=\| read -r f1 f2 f3 f4
do
    id=${f2% }
    id=${id# }

    socket=$( get_soc $i $soc1 $soc2 )
    pause=$( get_pause $i )

    cache_id $tdir $id
    mpv --term-playing-msg="ID:${id}" --input-ipc-server="$socket" --no-video $pause "$tdir/${id}" | prefix_echo $i "$id" & 
    
    pids[$i]=$!
    ids[$i]=$id

    if [[ $i > 0 ]]; then
        prev_idx=$(($i - 1))
        prev_pid=${pids[$prev_idx]}
        prev_id=${ids[$prev_idx]}

        tail --pid=$prev_pid -f /dev/null
        echo '{ "command": ["set_property", "pause", false] }' | socat - $socket
        rm $tdir/$prev_id
    fi
    echo $socket > $curr

    i=$((i + 1))
done

cleanup

#rm $soc1 $soc2 $curr

