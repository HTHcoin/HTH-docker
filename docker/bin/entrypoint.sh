#!/bin/bash

X=$(cat /root/.helpthehomeless/helpthehomeless.conf | grep masternodeblsprivkey=)
## If no BLS key build one first!
if [ ! ${X} ]; then
  ./helpthehomelessd -daemon
  until ./helpthehomeless-cli bls generate >/root/.helpthehomeless/bls.json 2>/dev/null; do
    echo "Waiting for daemon to start.."
    sleep 5
  done
  ./helpthehomeless-cli stop
  KEY=$(cat /root/.helpthehomeless/bls.json | grep secret | sed 's/\( "secret": "\)\|"\|,\| //g')
  echo "masternode=1" >>/root/.helpthehomeless/helpthehomeless.conf
  echo "masternodeblsprivkey=${KEY}" >>/root/.helpthehomeless/helpthehomeless.conf
fi

## Start daaemon again and be busy - if startup fails do reindex.
./helpthehomelessd || ./helpthehomelessd -reindex
