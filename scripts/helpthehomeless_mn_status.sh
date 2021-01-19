#!/bin/bash

command=$1
id=1
idstring=$(printf '%03d' ${id})
while [ -f "/etc/systemd/system/helpthehomeless-${idstring}.service" ]; do
  echo "helpthehomeless-${idstring}:"
  helpthehomelesscli-${idstring} masternode status
  id=$((id + 1))
  idstring=$(printf '%03d' ${id})
done
