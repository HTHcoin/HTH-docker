#!/bin/bash

command=$1
id=1
idstring=$(printf '%03d' ${id})
while [ -f "/etc/systemd/system/bitcorn-${idstring}.service" ]; do
  echo "bitcorn-${idstring}:"
  bitcorncli-${idstring} masternode status
  id=$((id + 1))
  idstring=$(printf '%03d' ${id})
done