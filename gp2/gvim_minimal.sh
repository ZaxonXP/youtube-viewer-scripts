#!/bin/bash

if [[ "$1" == "-o" ]]; then
    opt=-n
    shift
fi

server=$(basename $1)
gvim $opt --servername $server -c "set guicursor+=a:blinkon0 guioptions-=m guioptions-=r cursorline" -geometry 118x54-0-22 $1
