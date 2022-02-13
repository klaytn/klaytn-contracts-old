pragma solidity ^0.5.0;

import "./KIP17.sol";
import "./IKIP17Metadata.sol";
import "../../drafts/Counters.sol";
import "../../introspection/KIP13.sol";

contract KIP17Metadata is KIP13, KIP17, IKIP17Metadata {
    using Counters for Counters.Counter;
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;
    
    // owner of contract
    address private _creater;

    // start time of DEFI
    mapping (uint => uint) private _defiStartTime;

    // defi count of address
    mapping (address => Counters.Counter) private _Deficount;

    // return list of defied nft tokens
    mapping (address => uint256[] ) private _DefiList;

    // get defi original owner of nft
    mapping (uint => address) private _defiOwner;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_KIP17_METADATA = 0x5b5e139f;

    /**
     * @dev Constructor function
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        
        _creater = msg.sender;

        // register the supported interfaces to conform to KIP17 via KIP13
        _registerInterface(_INTERFACE_ID_KIP17_METADATA);
    }

    /**
     * @dev Gets the token name.
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol.
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns an URI for a given token ID.
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "KIP17Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Internal function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign
     */
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_exists(tokenId), "KIP17Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    function getcreater() external view returns (address) {
        return _creater;
    }

    function defiStartTime(uint tokenId) external view returns (uint) {
        return _defiStartTime[tokenId];
    }

    function getDEFICount(address owner) public view returns (uint256) {
        require(owner != address(0), "KIP17: balance query for the zero address");

        return _Deficount[owner].current();
    }
    
    function getDEFIOwner(uint tokenId) external view returns (address) {
        return _defiOwner[tokenId];
    }

    function DefiMyToken(uint256 tokenId) public {
        // uint deficnt;
        require( ownerOf(tokenId) == msg.sender, "only owner of token can Defi");
        _defiOwner[tokenId] = ownerOf(tokenId);
        _defiStartTime[tokenId] = block.timestamp;
        _Deficount[_defiOwner[tokenId]].increment();
        transferFrom ( _defiOwner[tokenId], _creater, tokenId );
    }

    function getMyTokenBack(uint tokenId) public returns(uint _DEFITime) {
        uint DEFITime;
        require( _defiOwner[tokenId] == msg.sender, "only owner of token can get token back");
        DEFITime = block.timestamp - _defiStartTime[tokenId];
        _Deficount[_defiOwner[tokenId]].decrement();
        transferFromDefi ( _creater, _defiOwner[tokenId], tokenId );
        return DEFITime;
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned by the msg.sender
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
