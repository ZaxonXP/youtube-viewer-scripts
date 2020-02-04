#!/bin/bash

if [[ $1 != "" ]]; then

    title="YTPL:\ $1"

    xterm -title "$title" -geometry "239x64+0+0" -e "vim + $1 -c \"set titlestring=$title guioptions-=m guioptions-=r lines=66 columns=239 cursorline\" -c \":source .vim_map\" -c \"sp\" -c \"view .help.txt\" -c \":wincmd j\"" &

    sleep 1
    file=$(mktemp)
    echo "(if (contains (application_name) \"YTPL\" ) (begin (undecorate) (maximize)))" > $file
    devilspie $file &
    sleep 3
    pgrep devilspie | xargs kill
    rm $file
fi
