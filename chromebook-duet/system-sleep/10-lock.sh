#!/bin/bash
case $1/$2 in
  pre/*)
    loginctl lock-sessions
    sleep 1
    #echo "locked, now suspending" >> /tmp/kj111-system-sleep
    ;;
  post/*)
    #echo "I slept, thank you very much" >> /tmp/kj111-system-sleep
esac
