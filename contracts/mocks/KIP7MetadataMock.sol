pragma solidity ^0.5.0;

import "../token/KIP7/KIP7.sol";
import "../token/KIP7/KIP7Metadata.sol";

contract KIP7MetadataMock is KIP7, KIP7Metadata {
    constructor (string memory name, string memory symbol, uint8 decimals)
        public
        KIP7Metadata(name, symbol, decimals)
    {
        // solhint-disable-previous-line no-empty-blocks
    }
}
