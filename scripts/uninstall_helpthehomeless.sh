#!/bin/bash
set -e

if [ $# -lt 1 ]; then
  echo 1>&2 "$0: Supply the node id to uninstall!"
  exit 2
fi

id=$(printf '%03d' "${1}")

systemctl disable "helpthehomeless-${id}"
systemctl stop "helpthehomeless-${id}"
rm -r "/mnt/helpthehomeless/${id}"
rm "/etc/systemd/system/helpthehomeless-${id}.service"
