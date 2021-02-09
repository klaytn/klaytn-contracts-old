pragma solidity ^0.5.0;

import "../token/KIP7/KIP7Burnable.sol";

contract KIP7BurnableMock is KIP7Burnable {
    constructor (address initialAccount, uint256 initialBalance) public {
        _mint(initialAccount, initialBalance);
    }
}
