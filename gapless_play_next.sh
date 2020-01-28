#!/bin/bash
echo '{ "command": ["set_property", "percent-pos", "100"] }' | socat - $(cat /tmp/soc_used) > /dev/null
