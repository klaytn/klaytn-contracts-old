pragma solidity ^0.5.0;

import "./KIP37.sol";
import "./KIP37Burnable.sol";
import "./KIP37Pausable.sol";
import "./KIP37Mintable.sol";

contract KIP37Token is KIP37, KIP37Burnable, KIP37Pausable, KIP37Mintable {
    constructor(string memory uri) public KIP37(uri) {}
}
