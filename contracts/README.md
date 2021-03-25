# @klaytn/contracts

Repository contains smart contracts of Klaytn.

## Getting Started

To import @klaytn/contracts, run the following commands:

```
$ truffle init
$ npm init -y
$ npm install @klaytn/contracts
```

Place the below code at contracts/MyKIP37Token.sol

```solidity
pragma solidity 0.5.6;
import "@klaytn/contracts/token/KIP37/KIP37Token.sol";

contract MyKIP37Token is KIP37Token {
  constructor() public KIP37Token("https://my/kip37/token/uri") {
  }
}
```

Please make sure that `truffle-config.js` is set properly. Especially, make sure the compiler version is set to 0.5.6.
Please refer to https://github.com/klaytn/klaytn-contracts/blob/master/truffle-config.js to check out the full version of `truffle-config.js` for Klaytn networks.
```js
  // Configure your compilers
  compilers: {
    solc: {
       version: "0.5.6",    // Fetch exact version from solc-bin (default: truffle's version)
       //docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
       settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: false,
          runs: 200
        },
        evmVersion: "constantinople"
       }
    }
```

Now, let's compile the code!
```
$ truffle compile
```

All done. To figure out how to deploy the contract, please refer to https://github.com/klaytn/klaytn-contracts.

Thanks.