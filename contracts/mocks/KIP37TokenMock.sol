// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "../token/KIP37/KIP37Token.sol";

/**
 * @title KIP37TokenMock
 * This mock just publicizes internal functions for testing purposes
 */
contract KIP37TokenMock is KIP37Token {
    constructor (string memory uri) public KIP37Token(uri) {
        // solhint-disable-previous-line no-empty-blocks
    }
}
