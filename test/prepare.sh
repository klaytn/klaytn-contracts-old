#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DATE=$(date +%Y%m%d_%H%M%S)

pushd $DIR

./deploy_local_network.sh &> tee.$DATE.log &
sleep 10
./init_accounts.sh

popd
