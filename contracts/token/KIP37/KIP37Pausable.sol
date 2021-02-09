// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "./KIP37.sol";
import "../../lifecycle/Pausable.sol";

/**
 * @dev KIP37 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 *
 * _Available since v3.1._
 */
contract KIP37Pausable is KIP37, Pausable {
    mapping(uint256 => bool) private _tokenPaused;

    /*
     *     bytes4(keccak256('pause()')) == 0x8456cb59
     *     bytes4(keccak256('pause(uint256)')) == 0x136439dd
     *     bytes4(keccak256('paused()')) == 0x5c975abb
     *     bytes4(keccak256('paused(uint256)')) == 0x00dde10e
     *     bytes4(keccak256('unpause()')) == 0x3f4ba83a
     *     bytes4(keccak256('unpause(uint256)')) == 0xfabc1cbc
     *
     *     => 0x8456cb59 ^ 0x136439dd ^ 0x5c975abb ^
     *        0x00dde10e ^ 0x3f4ba83a ^ 0xfabc1cbc == 0x0e8ffdb7
     */
    bytes4 private constant _INTERFACE_ID_KIP37_PAUSABLE = 0x0e8ffdb7;

    constructor() public {
        _registerInterface(_INTERFACE_ID_KIP37_PAUSABLE);
    }

    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`) with token ID.
     */
    event Paused(uint256 tokenId, address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`) with token ID.
     */
    event Unpaused(uint256 tokenId, address account);

    /// @notice Checks whether the specific token is paused.
    /// @return True if the specific token is paused, false otherwise
    function paused(uint256 _id) public view returns (bool) {
        return _tokenPaused[_id];
    }

    /// @notice Pauses actions related to transfer and approval of the specific token.
    /// @dev Throws if `msg.sender` is not allowed to pause.
    ///   Throws if the specific token is paused.
    function pause(uint256 _id) public onlyPauser {
        require(_tokenPaused[_id] == false, "KIP37Pausable: already paused");
        _tokenPaused[_id] = true;
        emit Paused(_id, msg.sender);
    }

    /// @notice Resumes from the paused state of the specific token.
    /// @dev Throws if `msg.sender` is not allowed to unpause.
    ///   Throws if the specific token is not paused.
    function unpause(uint256 _id) public onlyPauser {
        require(_tokenPaused[_id] == true, "KIP37Pausable: already unpaused");
        _tokenPaused[_id] = false;
        emit Unpaused(_id, msg.sender);
    }

    /**
     * @dev See {KIP37-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal {
        require(!paused(), "KIP37Pausable: token transfer while paused");
        for (uint256 i = 0; i < ids.length; i++) {
            require(
                _tokenPaused[ids[i]] == false,
                "KIP37Pausable: the token is paused"
            );
        }
    }
}
