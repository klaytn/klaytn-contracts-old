pragma solidity ^0.5.0;

import "../token/KIP17/KIP17Pausable.sol";
import "./PauserRoleMock.sol";

/**
 * @title KIP17PausableMock
 * This mock just provides a public mint, burn and exists functions for testing purposes
 */
contract KIP17PausableMock is KIP17Pausable, PauserRoleMock {
    function mint(address to, uint256 tokenId) public {
        super._mint(to, tokenId);
    }

    function burn(uint256 tokenId) public {
        super._burn(tokenId);
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return super._exists(tokenId);
    }
}
