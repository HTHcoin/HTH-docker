#!/bin/bash

id=1
idstring=$(printf '%03d' ${id})
while [ -f "/etc/systemd/system/bitcorn-${idstring}.service" ]; do
  echo "bitcorn-${idstring}:"
  bitcorn-cli-${idstring} "$@"
  id=$((id + 1))
  idstring=$(printf '%03d' ${id})
done