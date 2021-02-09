#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd $DIR

if [ ! -e "local-klaytn-deploy" ];then
  echo "local-klaytn-deploy not exist! cloning..."
  git clone https://github.com/klaytn/local-klaytn-deploy.git
fi

pushd local-klaytn-deploy
./1.prepare.sh
./2.start.sh

popd
popd