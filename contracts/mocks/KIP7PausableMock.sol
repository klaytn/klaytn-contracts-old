pragma solidity ^0.5.0;

import "../token/KIP7/KIP7Pausable.sol";
import "./PauserRoleMock.sol";

// mock class using KIP7Pausable
contract KIP7PausableMock is KIP7Pausable, PauserRoleMock {
    constructor (address initialAccount, uint initialBalance) public {
        _mint(initialAccount, initialBalance);
    }
}
