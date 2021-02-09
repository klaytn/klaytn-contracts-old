// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "../token/KIP37/KIP37Burnable.sol";

contract KIP37BurnableMock is KIP37Burnable {
    constructor(string memory uri) public KIP37(uri) { }

    function mint(address to, uint256 id, uint256 value, bytes memory data) public {
        _mint(to, id, value, data);
    }
}
