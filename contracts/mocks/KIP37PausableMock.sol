// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "./KIP37Mock.sol";
import "../token/KIP37/KIP37Pausable.sol";

contract KIP37PausableMock is KIP37Mock, KIP37Pausable {
    constructor(string memory uri) public KIP37Mock(uri) { }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
