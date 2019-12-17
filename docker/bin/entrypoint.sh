#!/bin/bash

X=$(cat /root/.bitgreen/bitgreen.conf | grep masternodeblsprivkey=)
## If no BLS key build one first!
if [ ! ${X} ]; then
  ./bitgreend -daemon
  until ./bitgreen-cli bls generate >/root/.bitgreen/bls.json 2>/dev/null; do
    echo "Waiting for daemon to start.."
    sleep 5
  done
  ./bitgreen-cli stop
  KEY=$(cat /root/.bitgreen/bls.json | grep secret | sed 's/\( "secret": "\)\|"\|,\| //g')
  echo "masternode=1" >>/root/.bitgreen/bitgreen.conf
  echo "masternodeblsprivkey=${KEY}" >>/root/.bitgreen/bitgreen.conf
fi

## Start daaemon again and be busy - if startup fails do reindex.
./bitgreend || ./bitgreend -reindex