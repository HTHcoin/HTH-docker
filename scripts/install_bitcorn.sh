#!/bin/bash

set -e

## GET IPv4/6 Address
IP=$(curl -s ipinfo.io/ip)
echo "####### Your IP: $IP"

## check for nodes now
# Get current bitcorn node number
id=1
idstring=$(printf '%03d' ${id})
while [ -f "/etc/systemd/system/bitcorn-${idstring}.service" ]; do
  id=$((id + 1))
  idstring=$(printf '%03d' ${id})
done
rpcport=18${idstring}
port=9${idstring}
rpcport=10${idstring}

echo "####### creating /etc/systemd/system/bitcorn-${idstring}.service"
IMAGE=docker.pkg.github.com/bitcornproject/bitcorn-docker/corn:test1
cat <<EOF >/etc/systemd/system/bitcorn-${idstring}.service
[Unit]
Description=BITCORN Daemon Container ${idstring}
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=10m
Restart=always
ExecStartPre=-/usr/bin/docker stop bitcorn-${idstring}
ExecStartPre=-/usr/bin/docker rm  bitcorn-${idstring}
# Always pull the latest docker image
ExecStartPre=/usr/bin/docker pull ${IMAGE}
ExecStop=/usr/bin/docker exec bitcorn-${idstring} /opt/app/bitcorn-cli -testnet stop
ExecStart=/usr/bin/docker run --rm -p ${port}:${port} -p ${rpcport}:${rpcport} -v /mnt/bitcorn/${idstring}:/root/.bitcorn --name bitcorn-${idstring} ${IMAGE}
[Install]
WantedBy=multi-user.target
EOF
systemctl enable bitcorn-${idstring}.service
systemctl daemon-reload

echo "####### creating /mnt/bitcorn/${idstring}/bitcorn.conf"
mkdir -p /mnt/bitcorn/${idstring}
cat <<EOF >/mnt/bitcorn/${idstring}/bitcorn.conf
rpcuser=user
rpcpassword=asdd3rascsar
rpcport=${rpcport}
rpcallowip=127.0.0.1
server=1
# Docker doesn't run as daemon
daemon=0
listen=1
txindex=1
logtimestamps=1
#
[test]
port=${port}
externalip=${IP}
addnode=78.141.209.14
addnode=45.63.77.163
addnode=104.156.231.87
addnode=69.90.132.181

EOF

systemctl start bitcorn-${idstring}

echo "####### adding control scripts"
cat <<EOF >/opt/bitcorn/bitcorn-cli-${idstring}
#!/bin/bash
docker exec bitcorn-${idstring} /opt/app/bitcorn-cli -testnet \$@
EOF
chmod +x /opt/bitcorn/bitcorn-cli-${idstring}

cat <<EOF >/opt/bitcorn/chainparams-${idstring}.sh
#!/bin/bash
echo
echo "### YOUR PARAMETERS!"
cat /mnt/bitcorn/${idstring}/bls.json |  jq '. += {"ip":"${IP}:${port}", "node":"$(hostname)-bitcorn-${idstring}"}'
EOF
chmod +x /opt/bitcorn/chainparams-${idstring}.sh

count=1

sleep 30

sh /opt/bitcorn/chainparams-${idstring}.sh

echo "#--# type 'source ~/.bashrc' after that you can use the bitcorn-cli-${idstring} i.E. 'bitcorn-cli-${idstring} masternode status'"
