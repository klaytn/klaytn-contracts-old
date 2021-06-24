pragma solidity ^0.5.0;

import "../Roles.sol";

contract CreatorRole {
    mapping (uint256 => address) private _creator;

    modifier onlyCreator(uint256 tokenId) {
        require(isCreator(tokenId, msg.sender), "CreatorRole: not a creator for the tokenId");
        _;
    }

    function isCreator(uint256 tokenId, address creatorAddress) public view returns (bool) {
        return _creator[tokenId] == creatorAddress;
    }

    function creatorOf(uint256 tokenId) public view returns (address) {
        return _creator[tokenId];
    }

    function _setCreator(uint256 tokenId, address creatorAddress) internal {
        _creator[tokenId] = creatorAddress;
    }
}
