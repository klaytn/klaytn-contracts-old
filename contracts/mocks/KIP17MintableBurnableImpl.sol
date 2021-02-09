pragma solidity ^0.5.0;

import "../token/KIP17/KIP17Full.sol";
import "../token/KIP17/KIP17Mintable.sol";
import "../token/KIP17/KIP17MetadataMintable.sol";
import "../token/KIP17/KIP17Burnable.sol";

/**
 * @title KIP17MintableBurnableImpl
 */
contract KIP17MintableBurnableImpl is KIP17Full, KIP17Mintable, KIP17MetadataMintable, KIP17Burnable {
    constructor () public KIP17Mintable() KIP17Full("Test", "TEST") {
        // solhint-disable-previous-line no-empty-blocks
    }
}
