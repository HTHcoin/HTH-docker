#!/bin/bash
set -e

BASECMD="protx register_prepare HASH INDEX IP OWNER PUBLIC OWNER 0 PAYOUT FEE"

bitgreen-cli settxfee 0.0002
## Generate a new payout address or specify you address here
PAYOUT=$(bitgreen-cli getnewaddress Payout p2sh-segwit)
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
  OWNER=$(bitgreen-cli getnewaddress "$(_jq '.node')_OWN")
  COLLATERAL=$(bitgreen-cli getnewaddress "$(_jq '.node')_COL")
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

echo "bitgreen-cli sendmany '' '$TXARR'"
HASH=$(bitgreen-cli sendmany "" "$TXARR")
echo $HASH
sed -i -e "s/HASH/$HASH/g" preps.txt

while read -r item; do
  _jq() {
    echo "$item" | jq -r "${1}"
  }

  sed -i -e "s/$(_jq '.address')_INDEX/$(_jq '.vout')/" preps.txt
done <<<$(bitgreen-cli gettransaction $HASH | jq -c '.details[]')

# Wait for confirmation here
while [ $(bitgreen-cli gettransaction $HASH | jq -r .confirmations) -lt 1  ]; do
  echo "Waiting for confirmations..."
  sleep 10
done

rm -f signs.txt
while read -r item; do
  echo "Signing next..."
  SIGN=$(bitgreen-cli $item)
  RESULT=$(bitgreen-cli signmessage "$(echo $SIGN | jq -r .collateralAddress)" "$(echo $SIGN | jq -r .signMessage)")
  TXID=$(bitgreen-cli protx register_submit "$(echo $SIGN | jq -r .tx)" "$RESULT")
  echo "$TXID" >> signs.txt
  while [ $(bitgreen-cli gettransaction $TXID | jq -r .confirmations) -lt 1 ]; do
    echo "Waiting for confirmations..."
    sleep 10
  done
done <preps.txt
