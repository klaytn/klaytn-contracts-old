pragma solidity ^0.5.0;

import "../token/KIP17/KIP17Full.sol";
import "../token/KIP17/KIP17Mintable.sol";
import "../token/KIP17/KIP17MetadataMintable.sol";
import "../token/KIP17/KIP17Burnable.sol";

/**
 * @title KIP17FullMock
 * This mock just provides public functions for setting metadata URI, getting all tokens of an owner,
 * checking token existence, removal of a token from an address
 */
contract KIP17FullMock is KIP17Full, KIP17Mintable, KIP17MetadataMintable, KIP17Burnable {
    constructor (string memory name, string memory symbol) public KIP17Mintable() KIP17Full(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        return _tokensOfOwner(owner);
    }

    function setTokenURI(uint256 tokenId, string memory uri) public {
        _setTokenURI(tokenId, uri);
    }
}
