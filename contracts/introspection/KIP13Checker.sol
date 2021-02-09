pragma solidity ^0.5.0;

/**
 * @dev Library used to query support of an interface declared via `IKIP13`.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library KIP13Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_KIP13 = 0x01ffc9a7;

    /**
     * @dev Returns true if `account` supports the `IKIP13` interface,
     */
    function _supportsKIP13(address account) internal view returns (bool) {
        // Any contract that implements KIP13 must explicitly indicate support of
        // InterfaceId_KIP13 and explicitly indicate non-support of InterfaceId_Invalid
        return _supportsKIP13Interface(account, _INTERFACE_ID_KIP13) &&
            !_supportsKIP13Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for `IKIP13` itself is queried automatically.
     *
     * See `IKIP13.supportsInterface`.
     */
    function _supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both KIP13 as per the spec and support of _interfaceId
        return _supportsKIP13(account) &&
            _supportsKIP13Interface(account, interfaceId);
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for `IKIP13` itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * `IKIP13` support.
     *
     * See `IKIP13.supportsInterface`.
     */
    function _supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of KIP13 itself
        if (!_supportsKIP13(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsKIP13Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check KIP13 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports KIP13, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with the `supportsKIP13` method in this library.
     * Interface identification is specified in ERC-165.
     */
    function _supportsKIP13Interface(address account, bytes4 interfaceId) private view returns (bool) {
        // success determines whether the staticcall succeeded and result determines
        // whether the contract at account indicates support of _interfaceId
        (bool success, bool result) = _callKIP13SupportsInterface(account, interfaceId);

        return (success && result);
    }

    /**
     * @notice Calls the function with selector 0x01ffc9a7 (KIP13) and suppresses throw
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return success true if the STATICCALL succeeded, false otherwise
     * @return result true if the STATICCALL succeeded and the contract at account
     * indicates support of the interface with identifier interfaceId, false otherwise
     */
    function _callKIP13SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool success, bool result)
    {
        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_KIP13, interfaceId);

        // solhint-disable-next-line no-inline-assembly
        assembly {
            let encodedParams_data := add(0x20, encodedParams)
            let encodedParams_size := mload(encodedParams)

            let output := mload(0x40)    // Find empty storage location using "free memory pointer"
            mstore(output, 0x0)

            success := staticcall(
                30000,                   // 30k gas
                account,                 // To addr
                encodedParams_data,
                encodedParams_size,
                output,
                0x20                     // Outputs are 32 bytes long
            )

            result := mload(output)      // Load the result
        }
    }
}
