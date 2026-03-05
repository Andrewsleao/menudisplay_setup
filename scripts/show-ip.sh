#!/bin/bash

export DISPLAY=:0
export XAUTHORITY=/home/mila/.Xauthority

IP=$(hostname -I | awk '{print $1}')

echo "IP: $IP" | osd_cat \
  --pos=top \
  --align=left \
  --offset=10 \
  --delay=30 \
  --color=green \
  --font="-*-fixed-*-*-*-*-34-*-*-*-*-*-*-*"
