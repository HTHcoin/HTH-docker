#!/bin/bash
set -e

BASECMD="protx register_prepare HASH INDEX IP OWNER PUBLIC OWNER 0 PAYOUT FEE"

helpthehomeless-cli settxfee 0.0002
## Generate a new payout address or specify you address here
PAYOUT=$(helpthehomeless-cli getnewaddress Payout p2sh-segwit)
FEE=$PAYOUT
#PAYOUT="3..."
#FEE="3... or G..."

rm -f preps.txt
TXARR="{}"
while read -r item; do
  _jq() {
    echo "$item" | jq -r "${1}"
  }
  IP=$(_jq ".ip")
  PUBLIC=$(_jq ".public")
  OWNER=$(helpthehomeless-cli getnewaddress "$(_jq '.node')_OWN")
  COLLATERAL=$(helpthehomeless-cli getnewaddress "$(_jq '.node')_COL")
  PREPCOMMAND=${BASECMD}
  PREPCOMMAND=${PREPCOMMAND//OWNER/$OWNER}
  PREPCOMMAND=${PREPCOMMAND//PUBLIC/$PUBLIC}
  PREPCOMMAND=${PREPCOMMAND//PAYOUT/$PAYOUT}
  PREPCOMMAND=${PREPCOMMAND//FEE/$FEE}
  PREPCOMMAND=${PREPCOMMAND//IP/$IP}
  PREPCOMMAND=${PREPCOMMAND//INDEX/${COLLATERAL}_INDEX}

  TXARR=$(echo "${TXARR}" | jq -c '.'"${COLLATERAL}"'=2500')
  echo "$PREPCOMMAND" >>preps.txt
done <<<$(cat params.json | jq -r -c '.[]')

TXARR=$(echo "${TXARR}" | jq -c '."'"${FEE}"'"=1')
#TXARR=$(echo "${TXARR}" | jq -c '."'"${PAYOUT}"'"=1')

echo "helpthehomeless-cli sendmany '' '$TXARR'"
HASH=$(helpthehomeless-cli sendmany "" "$TXARR")
echo $HASH
sed -i -e "s/HASH/$HASH/g" preps.txt

while read -r item; do
  _jq() {
    echo "$item" | jq -r "${1}"
  }

  sed -i -e "s/$(_jq '.address')_INDEX/$(_jq '.vout')/" preps.txt
done <<<$(helpthehomeless-cli gettransaction $HASH | jq -c '.details[]')

# Wait for confirmation here
while [ $(helpthehomeless-cli gettransaction $HASH | jq -r .confirmations) -lt 1  ]; do
  echo "Waiting for confirmations..."
  sleep 10
done

rm -f signs.txt
while read -r item; do
  echo "Signing next..."
  SIGN=$(helpthehomeless-cli $item)
  RESULT=$(helpthehomeless-cli signmessage "$(echo $SIGN | jq -r .collateralAddress)" "$(echo $SIGN | jq -r .signMessage)")
  TXID=$(helpthehomeless-cli protx register_submit "$(echo $SIGN | jq -r .tx)" "$RESULT")
  echo "$TXID" >> signs.txt
  while [ $(helpthehomeless-cli gettransaction $TXID | jq -r .confirmations) -lt 1 ]; do
    echo "Waiting for confirmations..."
    sleep 10
  done
done <preps.txt
