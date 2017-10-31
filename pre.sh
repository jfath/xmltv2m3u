#!/bin/bash

echo "IPTVproxy pre.sh" `date` >>/home/hts/tvh/dbg.log
echo "Args: $1, $2, $3, $4" >>/home/hts/tvh/dbg.log

#Change  cable box channel
CHAN=$2
CHAN=${CHAN:1:${#CHAN}}
echo "Channel: $CHAN" >>/home/hts/tvh/dbg.log


/home/hts/tvh/changechannel "$CHAN"

exit 0
