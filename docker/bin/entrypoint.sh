#!/bin/bash

X=$(cat /root/.bitcorn/bitcorn.conf | grep masternodeblsprivkey=)
## If no BLS key build one first!
if [ ! ${X} ]; then
  ./bitcornd -daemon
  until ./bitcorn-cli bls generate >/root/.bitcorn/bls.json 2>/dev/null; do
    echo "Waiting for daemon to start.."
    sleep 5
  done
  ./bitcorn-cli stop
  KEY=$(cat /root/.bitcorn/bls.json | grep secret | sed 's/\( "secret": "\)\|"\|,\| //g')
  echo "masternode=1" >>/root/.bitcorn/bitcorn.conf
  echo "masternodeblsprivkey=${KEY}" >>/root/.bitcorn/bitcorn.conf
fi

## Start daaemon again and be busy - if startup fails do reindex.
./bitcornd || ./bitcornd -reindex