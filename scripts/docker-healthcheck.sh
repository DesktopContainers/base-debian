#!/bin/sh
[[ $(ps aux | grep '[X]vfb\|[s]shd:\|[w]ebsockify 4443\|[w]ebsockify 8080\|[x]11vnc -localhost\|[h]aproxy -f' | wc -l) -ge '6' ]]
exit $?
