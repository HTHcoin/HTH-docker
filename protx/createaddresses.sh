#!/bin/bash
set -e

BASECMD="protx register_prepare HASH INDEX IP OWNER PUBLIC OWNER 0 PAYOUT FEE"

bitcorn-cli -testnet settxfee 0.0002
## Generate a new payout address or specify you address here
PAYOUT=$(bitcorn-cli -testnet getnewaddress Payout p2sh-segwit)
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
  OWNER=$(bitcorn-cli -testnet getnewaddress "$(_jq '.node')_OWN")
  COLLATERAL=$(bitcorn-cli -testnet getnewaddress "$(_jq '.node')_COL")
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

echo "bitcorn-cli -testnet sendmany '' '$TXARR'"
HASH=$(bitcorn-cli -testnet sendmany "" "$TXARR")
echo $HASH
sed -i -e "s/HASH/$HASH/g" preps.txt

while read -r item; do
  _jq() {
    echo "$item" | jq -r "${1}"
  }

  sed -i -e "s/$(_jq '.address')_INDEX/$(_jq '.vout')/" preps.txt
done <<<$(bitcorn-cli -testnet gettransaction $HASH | jq -c '.details[]')

# Wait for confirmation here
while [ $(bitcorn-cli -testnet gettransaction $HASH | jq -r .confirmations) -lt 1  ]; do
  echo "Waiting for confirmations..."
  sleep 10
done

rm -f signs.txt
while read -r item; do
  echo "Signing next..."
  SIGN=$(bitcorn-cli -testnet $item)
  RESULT=$(bitcorn-cli -testnet signmessage "$(echo $SIGN | jq -r .collateralAddress)" "$(echo $SIGN | jq -r .signMessage)")
  TXID=$(bitcorn-cli -testnet protx register_submit "$(echo $SIGN | jq -r .tx)" "$RESULT")
  echo "$TXID" >> signs.txt
  while [ $(bitcorn-cli -testnet gettransaction $TXID | jq -r .confirmations) -lt 1 ]; do
    echo "Waiting for confirmations..."
    sleep 10
  done
done <preps.txt
