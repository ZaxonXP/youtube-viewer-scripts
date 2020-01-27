#!/bin/bash

if [ "$(echo '{ "command": ["get_property", "core-idle"] }' | socat - $(cat /tmp/soc_used))" == '{"data":false,"error":"success"}' ]; then

    echo '{ "command": ["set_property", "pause", true] }' | socat - $(cat /tmp/soc_used) > /dev/null
else
    echo '{ "command": ["set_property", "pause", false] }' | socat - $(cat /tmp/soc_used) > /dev/null
fi
