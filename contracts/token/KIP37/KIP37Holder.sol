// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "./KIP37Receiver.sol";

contract KIP37Holder is KIP37Receiver {
    function onKIP37Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        return this.onKIP37Received.selector;
    }

    function onKIP37BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public returns (bytes4) {
        return this.onKIP37BatchReceived.selector;
    }
}
