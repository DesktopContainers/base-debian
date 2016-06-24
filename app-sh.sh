#!/bin/bash
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  SESSION_TYPE=remote/ssh
else
  case $(ps -o comm= -p $PPID) in
    sshd|*/sshd) SESSION_TYPE=remote/ssh;;
  esac
fi

if [ "$SESSION_TYPE" = "remote/ssh" ]; then
	kill $(pstree -p $(pgrep xstartup) | grep app | cut -d "(" -f3 | cut -d ")" -f1) 2> /dev/null > /dev/null
	exec /bin/ssh-app.sh
else
	exec /bin/bash -l
fi
