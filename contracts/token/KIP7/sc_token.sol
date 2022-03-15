pragma solidity 0.5.6;

import "./KIP7Mintable.sol";
import "./KIP7Burnable.sol";
import "./KIP7Pausable.sol";
import "./KIP7Metadata.sol";
import "./KIP7ServiceChain.sol";

contract ServiceChainTokenKIP7 is KIP7, KIP7Mintable, KIP7Burnable, KIP7Pausable, KIP7Metadata, KIP7ServiceChain {
    string public constant NAME = "KIP7ServiceChain";
    string public constant SYMBOL = "KIP7SCT";
    uint8 public constant DECIMALS = 18;

    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(DECIMALS));

    constructor(address _bridge) KIP7Metadata(NAME, SYMBOL, DECIMALS) KIP7ServiceChain(_bridge) public {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
