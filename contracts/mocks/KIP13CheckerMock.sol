pragma solidity ^0.5.0;

import "../introspection/KIP13Checker.sol";

contract KIP13CheckerMock {
    using KIP13Checker for address;

    function supportsKIP13(address account) public view returns (bool) {
        return account._supportsKIP13();
    }

    function supportsInterface(address account, bytes4 interfaceId) public view returns (bool) {
        return account._supportsInterface(interfaceId);
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) public view returns (bool) {
        return account._supportsAllInterfaces(interfaceIds);
    }
}
