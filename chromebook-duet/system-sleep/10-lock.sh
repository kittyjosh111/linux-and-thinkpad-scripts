#!/bin/bash
case $1/$2 in
  pre/*)
    loginctl lock-sessions
    sleep 1
    echo "locked before suspension..." > /tmp/kj111-system-sleep
    ;;
  post/*)
    #rm -rf /home/*/.config/pulse #if you want to use this, set it up manually
    echo "...woke from suspension" >> /tmp/kj111-system-sleep
esac
