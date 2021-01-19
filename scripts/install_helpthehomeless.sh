#!/bin/bash

set -e

## GET IPv4/6 Address
IP=$(curl -s ipinfo.io/ip)
echo "####### Your IP: $IP"

## check for nodes now
# Get current helpthehomeless node number
id=1
idstring=$(printf '%03d' ${id})
while [ -f "/etc/systemd/system/helpthehomeless-${idstring}.service" ]; do
  id=$((id + 1))
  idstring=$(printf '%03d' ${id})
done
rpcport=18${idstring}
port=42${idstring}
rpcport=10${idstring}

echo "####### creating /etc/systemd/system/helpthehomeless-${idstring}.service"
IMAGE=docker.pkg.github.com/HTHcoin/HTH-docker/corn:latest
cat <<EOF >/etc/systemd/system/helpthehomeless-${idstring}.service
[Unit]
Description=HTH Daemon Container ${idstring}
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=10m
Restart=always
ExecStartPre=-/usr/bin/docker stop helpthehomeless-${idstring}
ExecStartPre=-/usr/bin/docker rm  helpthehomeless-${idstring}
# Always pull the latest docker image
ExecStartPre=/usr/bin/docker pull ${IMAGE}
ExecStop=/usr/bin/docker exec helpthehomeless-${idstring} /opt/app/hellthehomeless-cli stop
ExecStart=/usr/bin/docker run --rm -p ${port}:${port} -p ${rpcport}:${rpcport} -v /mnt/HelpTheHomessCoin/${idstring}:/root/.helpthehomeless --name helpthehomeless-${idstring} ${IMAGE}
[Install]
WantedBy=multi-user.target
EOF
systemctl enable helpthehomeless-${idstring}.service
systemctl daemon-reload

echo "####### creating /mnt/HelpTheHomessCoin/${idstring}/helpthehomeless.conf"
mkdir -p /mnt/HelpTheHomessCoin/${idstring}
cat <<EOF >/mnt/HelpTheHomessCoin/${idstring}/helpthehomeless.conf
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
port=${port}
externalip=${IP}
EOF

systemctl start helpthehomeless-${idstring}

echo "####### adding control scripts"
cat <<EOF >/opt/helpthehomeless/helpthehomeless-cli-${idstring}
#!/bin/bash
docker exec helpthehomeless-${idstring} /opt/app/helpthehomeless-cli \$@
EOF
chmod +x /opt/helpthehomeless/helpthehomeless-cli-${idstring}

cat <<EOF >/opt/helpthehomeless/chainparams-${idstring}.sh
#!/bin/bash
echo
echo "### YOUR PARAMETERS!"
cat /mnt/HelpTheHomessCoin/${idstring}/bls.json |  jq '. += {"ip":"${IP}:${port}", "node":"$(hostname)-helpthehomeless-${idstring}"}'
EOF
chmod +x /opt/helpthehomeless/chainparams-${idstring}.sh

count=1

sleep 30

sh /opt/helpthehomeless/chainparams-${idstring}.sh

echo "You can now use the helpthehomeless-cli for your nodes. For instance 'helpthehomeless-cli-${idstring} masternode status'"
source ~/.bashrc
