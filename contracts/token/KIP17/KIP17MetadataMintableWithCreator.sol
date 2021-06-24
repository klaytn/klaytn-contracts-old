pragma solidity ^0.5.0;

import "./KIP17MetadataMintable.sol";
import "../../access/roles/MinterRole.sol";
import "../../introspection/KIP13.sol";
import "../../access/roles/CreatorRole.sol";


/**
 * @title KIP17MetadataMintableWithCreator
 * @dev KIP17 minting logic with metadata.
 */
contract KIP17MetadataMintableWithCreator is KIP17MetadataMintable, CreatorRole {
    /*
     *     bytes4(keccak256('mintWithTokenURI(address,uint256,string)')) == 0x50bb4e7f
     *     bytes4(keccak256('creatorOf(uint256)')) == 0x589a1743
     *     bytes4(keccak256('isCreator(uint256,address)')) == 0xdf03ee7a
     *
     *     => 0x50bb4e7f ^ 0x589a1743 ^ 0xdf03ee7a == 0xd722b746
     */
    bytes4 private constant _INTERFACE_ID_KIP17_METADATA_MINTABLE_WITH_CREATOR = 0xd722b746;

    /**
     * @dev Constructor function.
     */
    constructor () public {
        // register the supported interface to conform to KIP17Mintable via KIP13
        _registerInterface(_INTERFACE_ID_KIP17_METADATA_MINTABLE_WITH_CREATOR);
    }

    /**
     * @dev Function to mint tokens.
     * @param to The address that will receive the minted tokens.
     * @param tokenId The token id to mint.
     * @param tokenURI The token URI of the minted token.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) public onlyMinter returns (bool) {
        _setCreator(tokenId, to);
        return KIP17MetadataMintable.mintWithTokenURI(to, tokenId, tokenURI);
    }
}
