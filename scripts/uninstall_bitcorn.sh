#!/bin/bash
set -e

if [ $# -lt 1 ]; then
  echo 1>&2 "$0: Supply the node id to uninstall!"
  exit 2
fi

id=$(printf '%03d' "${1}")

systemctl disable "bitcorn-${id}"
systemctl stop "bitcorn-${id}"
rm -r "/mnt/bitcorn/${id}"
rm "/etc/systemd/system/bitcorn-${id}.service"