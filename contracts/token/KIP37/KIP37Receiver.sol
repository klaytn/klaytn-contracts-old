// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "./IKIP37Receiver.sol";
import "../../introspection/KIP13.sol";

contract KIP37Receiver is KIP13, IKIP37Receiver {
    constructor() public {
        _registerInterface(
            KIP37Receiver(0).onKIP37Received.selector ^
                KIP37Receiver(0).onKIP37BatchReceived.selector
        );
    }
}
