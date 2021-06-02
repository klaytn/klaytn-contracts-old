pragma solidity ^0.5.0;

import "./KIP37.sol";
import "../../access/roles/MinterRole.sol";

/**
 * @dev Extension of {KIP37} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 */
contract KIP37Mintable is KIP37, MinterRole {
    /*
     *     bytes4(keccak256('create(uint256,uint256,string)')) == 0x4b068c78
     *     bytes4(keccak256('mint(uint256,address,uint256)')) == 0x836a1040
     *     bytes4(keccak256('mint(uint256,address[],uint256[])')) == 0xcfa84fc1
     *     bytes4(keccak256('mintBatch(address,uint256[],uint256[])')) == 0xd81d0a15
     *
     *     => 0x4b068c78 ^ 0x836a1040 ^ 0xcfa84fc1 ^ 0xd81d0a15 == 0xdfd9d9ec
     */
    bytes4 private constant _INTERFACE_ID_KIP37_MINTABLE = 0xdfd9d9ec;

    // id => creators
    mapping(uint256 => address) public creators;

    mapping(uint256 => string) _uris;

    constructor() public {
        _registerInterface(_INTERFACE_ID_KIP37_MINTABLE);
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        address creator = creators[tokenId];
        return creator != address(0);
    }

    /**
     * @dev See {IKIP37MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substituion mechanism
     * http://kips.klaytn.com/KIPs/kip-37#metadata
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 tokenId) external view returns (string memory) {
        string memory customURI = string(_uris[tokenId]);
        if(bytes(customURI).length != 0) {
            return customURI;
        }

        return _uri;
    }

    /// @notice Creates a new token type and assigns _initialSupply to the minter.
    /// @dev Throws if `msg.sender` is not allowed to create.
    ///   Throws if the token id is already used.
    /// @param _id The token id to create.
    /// @param _initialSupply The amount of tokens being minted.
    /// @param _uri The token URI of the created token.
    /// @return A boolean that indicates if the operation was successful.
    function create(
        uint256 _id,
        uint256 _initialSupply,
        string memory _uri
    ) public onlyMinter returns (bool) {
        require(!_exists(_id), "KIP37: token already created");

        creators[_id] = msg.sender;
        _mint(msg.sender, _id, _initialSupply, "");

        if (bytes(_uri).length > 0) {
            _uris[_id] = _uri;
            emit URI(_uri, _id);
        }
    }

    /// @notice Mints tokens of the specific token type `_id` and assigns the tokens according to the variables `_to` and `_value`.
    /// @dev Throws if `msg.sender` is not allowed to mint.
    ///   MUST emit an event `TransferSingle`.
    /// @param _id The token id to mint.
    /// @param _to The address that will receive the minted tokens.
    /// @param _value The quantity of tokens being minted.
    function mint(
        uint256 _id,
        address _to,
        uint256 _value
    ) public onlyMinter {
        require(_exists(_id), "KIP37: nonexistent token");
        _mint(_to, _id, _value, "");
    }

    /// @notice Mints tokens of the specific token type `_id` in a batch and assigns the tokens according to the variables `_toList` and `_values`.
    /// @dev Throws if `msg.sender` is not allowed to mint.
    ///   MUST emit one or more `TransferSingle` events.
    ///   MUST revert if the length of `_toList` is not the same as the length of `_values`.
    /// @param _id The token id to mint.
    /// @param _toList The list of addresses that will receive the minted tokens.
    /// @param _values The list of quantities of tokens being minted.
    function mint(
        uint256 _id,
        address[] memory _toList,
        uint256[] memory _values
    ) public onlyMinter {
        require(_exists(_id), "KIP37: nonexistent token");
        require(
            _toList.length == _values.length,
            "KIP37: toList and _values length mismatch"
        );
        for (uint256 i = 0; i < _toList.length; ++i) {
            address to = _toList[i];
            uint256 value = _values[i];
            _mint(to, _id, value, "");
        }
    }

    /// @notice Mints multiple KIP37 tokens of the specific token types `_ids` in a batch and assigns the tokens according to the variables `_to` and `_values`.
    /// @dev Throws if `msg.sender` is not allowed to mint.
    ///   MUST emit one or more `TransferSingle` events or a single `TransferBatch` event.
    ///   MUST revert if the length of `_ids` is not the same as the length of `_values`.
    /// @param _to The address that will receive the minted tokens.
    /// @param _ids The list of the token ids to mint.
    /// @param _values The list of quantities of tokens being minted.
    function mintBatch(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _values
    ) public onlyMinter {
        for (uint256 i = 0; i < _ids.length; ++i) {
            require(_exists(_ids[i]), "KIP37: nonexistent token");
        }
        _mintBatch(_to, _ids, _values, "");
    }
}
