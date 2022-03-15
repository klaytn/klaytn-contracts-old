pragma solidity 0.5.6;

import "./KIP17Full.sol";
import "./KIP17MetadataMintable.sol";
import "./KIP17Mintable.sol";
import "./KIP17Burnable.sol";
import "./KIP17Pausable.sol";
import "./KIP17ServiceChain.sol";

contract ServiceChainTokenKIP17 is KIP17Full, KIP17Mintable, KIP17MetadataMintable, KIP17Burnable, KIP17Pausable, KIP17ServiceChain {
    string public constant NAME = "KIP17ServiceChain";
    string public constant SYMBOL = "KIP17SCT";

    constructor(address _bridge) public KIP17Full(NAME, SYMBOL) KIP17ServiceChain(_bridge) {
    }
}
