#!/bin/bash

command=$1
id=1
idstring=$(printf '%03d' ${id})
while [ -f "/etc/systemd/system/bitcorn-${idstring}.service" ]; do
  echo "bitcorn-${idstring}:"
  systemctl $1 bitcorn-${idstring}.service
  id=$((id + 1))
  idstring=$(printf '%03d' ${id})
done