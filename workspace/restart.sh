#!/bin/sh

if [ "$LAUNCHER" = "pm2" ]; then
    pm2 stop "./$MAINFILE"
else
    if [ "$LAUNCHER" = "nodemon" ]; then
        ps -Af | grep nodemon | awk '{print $2}' | xargs -I{} kill {}
    else
        ps -Af | grep node | grep "$MAINFILE" | awk '{print $2}' | xargs -I{} kill {}
    fi
fi
