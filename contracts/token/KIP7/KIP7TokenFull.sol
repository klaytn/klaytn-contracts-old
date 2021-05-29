pragma solidity ^0.5.0;

import "./KIP7Mintable.sol";
import "./KIP7Burnable.sol";
import "./KIP7Pausable.sol";
import "./KIP7Metadata.sol";
import "../../lifecycle/SelfDestructible.sol";
import "../../ownership/Ownable.sol";

contract KIP7TokenFull is KIP7Mintable, KIP7Burnable, KIP7Pausable, KIP7Metadata, Ownable, SelfDestructible {
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply) KIP7Metadata(name, symbol, decimals) public {
        _mint(msg.sender, initialSupply);
    }
}
