# klaytn-contracts

This repository contains contracts that are helpful to building blockchain applications on Klaytn.

Some files were derived from [openzeppelin contracts v2.3.0](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v2.3.0).

# Security

WARNING: Please take special care when you use this code in production. We take no responsibility for any security problems you might experience.
If you find any security problems in the source code, please report it to developer@klaytn.com.

# Prerequisites

The following packages should be installed before using this source code.

* git
* docker
* Node v10.21.0
* Truffle v5.1.61
* ganache-cli v6.12.1

# Package Installation

Please install node packages first.

```bash
$ npm install
$ npm install -g truffle@v5.1.61
$ npm install -g ganache-cli@v6.12.1
```

# How to run Ganache

[Ganache](https://www.trufflesuite.com/ganache) is a local blockchain environment for easy testing.
Klaytn is a fork of Ethereum and compatible with Constantinople EVM, so you can use Ganache for testing.
To run a Ganache, execute the following command:

```bash
$ npm run run:ganache
```

This ganache network is defined as "development" network in [truffle-config.js](truffle-config.js)

# How to run a Local Klaytn Network

You can easily deploy a local Klaytn network via the following command:

```bash
$ npm run run:klaytn
```

To see the execution logs, run `npm run run:klaytn:log`.
To stop the network, run `npm run run:klaytn:stop`.
To resume the network, run `npm run run:klaytn:resume`.
To completely terminate the network, run `npm run run:klaytn:terminate`.
To remove log files, run `npm run run:klaytn:cleanlog`.

# How to Test Contracts

Just execute the command as follows:

```bash
$ npm run test:ganache

# To run a specific test, execute the below.
$ npm run test:ganache -- ./test/token/KIP7/KIP7.test.js

# To run a test on a local klaytn network, execute the below.
$ npm run test:klaytn
$ npm run test:klaytn -- ./test/token/KIP7/KIP7.test.js
```

# How to Deploy Contracts


## Deploying a contract to the local network

1. To deploy a contract, please modify [2_contract_migration.js](./contracts/migrations/2_contract_migration.js). The file deploys a KIP7 contract currently.
2. Execute the following command to deploy the local network.

```bash
$ npm run deploy:klaytn
```

## Deploying a contract to Baobab

### Using an EN

Update `privateKey` and `EN URL` in `baobab` of [truffle-config.js](./truffle-config.js).

```js
    baobab: {
      provider: () => {
        return new HDWalletProvider(privateKey, "https://your.baobab.en:8651");
      },
      network_id: '1001', //Klaytn baobab testnet's network id
      gas: '8500000',
      gasPrice: null
    },
```

### Using KAS

Also, you can use [KAS](http://www.klaytnapi.com) instead of your own EN. Please refer to `kasBaobab` as shown below.
In this case, you need to update `privateKey`, `accessKeyId`, and `secretAccessKey`.

**NOTE**: As of Feb 2021, "Using KAS" is not supported yet.

```js
const accessKeyId = "ACCESS_KEY";
const secretAccessKey = "SECRET_KEY";

...

    kasBaobab: {
      provider: () => {
        option.headers['x-chain-id'] = '1001';
        return new HDWalletProvider(privateKey, new Caver.providers.HttpProvider("https://node-api.klaytnapi.com/v1/klaytn", option))
      },
      network_id: '1001', //Klaytn baobab testnet's network id
      gas: '8500000',
      gasPrice:'25000000000'
    },
```

## Deploying a contract to Cypress

### Using an EN
Update `privateKey` and `EN URL` in `baobab` of [truffle-config.js](./truffle-config.js).

```js
    cypress: {
      provider: () => new HDWalletProvider(privateKey, "https://your.cypress.en:8651"),
      network_id: '8217', //Klaytn mainnet's network id
      gas: '8500000',
      gasPrice: null
    }
```

### Using KAS

Also, you can use [KAS](http://www.klaytnapi.com) instead of your own EN. Please refer to `kasBaobab` as shown below.
In this case, you need to update `privateKey`, `accessKeyId`, and `secretAccessKey`.

**NOTE**: As of Feb 2021, "Using KAS" is not supported yet.

```js
const accessKeyId = "ACCESS_KEY";
const secretAccessKey = "SECRET_KEY";

...

    kasCypress: {
      provider: () => {
        option.headers['x-chain-id'] = '8217';
        return new HDWalletProvider(privateKey, new Caver.providers.HttpProvider("https://node-api.klaytnapi.com/v1/klaytn", option))
      },
      network_id: '8217', //Klaytn baobab testnet's network id
      gas: '8500000',
      gasPrice:'25000000000'
    },
```