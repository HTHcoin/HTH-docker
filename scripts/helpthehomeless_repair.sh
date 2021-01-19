#!/bin/bash
set -e

if [ $# -lt 1 ]; then
  echo 1>&2 "$0: Supply the node id to repair!"
  exit 2
fi

id=$(printf '%03d' "${1}")

systemctl stop "helpthehomeless-${id}"

# Create a temporary directory and store its name in a variable ...
TMPDIR=$(mktemp -d)

# Bail out if the temp directory wasn't created successfully.
if [ ! -e $TMPDIR ]; then
    >&2 echo "Failed to create temp directory"
    exit 1
fi

# Make sure it gets removed even if the script exits abnormally.
trap "exit 1"           HUP INT PIPE QUIT TERM
trap 'rm -rf "$TMPDIR"' EXIT

mv "/mnt/HelpTheHomessCoin/${id}/helpthehomeless.conf" "/mnt/HelpTheHomessCoin/${id}/bls.json" "$TMPDIR/"
rm -rf "/mnt/HelpTheHomessCoin/${id}/*"
mv $TMPDIR/* "/mnt/HelpTheHomessCoin/${id}/"

systemctl start "bitcorn-${id}"
echo "Repaired your node check the logs with:"
echo "journalctl -fu helpthehomeless-${id}"
