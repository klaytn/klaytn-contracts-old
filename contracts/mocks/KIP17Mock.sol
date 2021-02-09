pragma solidity ^0.5.0;

import "../token/KIP17/KIP17.sol";

/**
 * @title KIP17Mock
 * This mock just provides a public mint and burn functions for testing purposes
 */
contract KIP17Mock is KIP17 {
    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function burn(address owner, uint256 tokenId) public {
        _burn(owner, tokenId);
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }
}
