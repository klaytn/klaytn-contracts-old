pragma solidity ^0.5.0;

import "../introspection/KIP13.sol";

contract KIP13Mock is KIP13 {
    function registerInterface(bytes4 interfaceId) public {
        _registerInterface(interfaceId);
    }
}
