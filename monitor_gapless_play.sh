#!/bin/bash

# Shows currently played song when used with gapless_play.sh
source="$1"
tracks=$(wc -l "$source" | cut -d" " -f1)

clear
while [ 1 ]; do

    # get oldest mpv process, youtube ID and process ID
    mpv_proc=$(ps aux --sort start_time | grep -v grep | grep -v "youtube-viewer" | grep mpv | head -1)

    if [[ "$mpv_proc" != "" ]]; then

        yt_id=$(echo $mpv_proc | cut -d= -f3)
        mpv_id=$(echo $mpv_proc | tr -s " " | cut -d" " -f2)

        first=${yt_id:0:1}

        if [[ "$first" == "-" ]]; then

            info=$(grep \\$yt_id "$source")
            track=$(grep -n \\$yt_id "$source" | cut -d: -f1)
        else
            info=$(grep $yt_id "$source")
            track=$(grep -n $yt_id "$source" | cut -d: -f1)
        fi

        if [ -v DEBUG ]; then
            echo "YT ID  = \"$yt_id\""
            echo "MPV ID = \"$mpv_id\""
            echo "INFO   = \"$info\""
        fi

        echo "Artist : $(echo $info | cut -d\| -f3)"
        echo "Title  : $(echo $info | cut -d\| -f4)"
        echo "Time   :  $(echo $info | cut -d\| -f1)"
        echo "Track  :  $track / $tracks"
        echo "YT ID  : $(echo $info | cut -d\| -f2)"

        # wait until the process exit to iterate
        tail --pid=$mpv_id -f /dev/null
        clear
    else
        clear
        sleep 3
    fi
done
