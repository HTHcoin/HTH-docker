#!/bin/bash

id=1
idstring=$(printf '%03d' ${id})
while [ -f "/etc/systemd/system/helpthehomeless-${idstring}.service" ]; do
  echo "helpthehomeless-${idstring}:"
  helpthehomeless-cli-${idstring} "$@"
  id=$((id + 1))
  idstring=$(printf '%03d' ${id})
done
