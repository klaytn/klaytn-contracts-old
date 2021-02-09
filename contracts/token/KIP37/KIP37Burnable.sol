// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "./KIP37.sol";

/**
 * @dev Extension of {KIP37} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 */
contract KIP37Burnable is KIP37 {
    /*
     *     bytes4(keccak256('burn(address,uint256,uint256)')) == 0xf5298aca
     *     bytes4(keccak256('burnBatch(address,uint256[],uint256[])')) == 0x6b20c454
     *
     *     => 0xf5298aca ^ 0x6b20c454 == 0x9e094e9e
     */
    bytes4 private constant _INTERFACE_ID_KIP37_BURNABLE = 0x9e094e9e;

    constructor() public {
        _registerInterface(_INTERFACE_ID_KIP37_BURNABLE);
    }

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "KIP37: caller is not owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "KIP37: caller is not owner nor approved"
        );

        _burnBatch(account, ids, values);
    }
}
