#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd $DIR/..

# Unlock the fund account.
FUND_ADDR=$(curl -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"personal_listAccounts","params":[],"id":1}' http://localhost:8551 | jq -r '.result[0]')
echo "FUND_ADDR = $FUND_ADDR"
curl -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"personal_unlockAccount","params":["'$FUND_ADDR'","",99999999],"id":1}' http://localhost:8551

node ./test/init_accounts.js

popd