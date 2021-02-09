pragma solidity ^0.5.0;

import "../token/KIP17/IKIP17Receiver.sol";

contract KIP17ReceiverMock is IKIP17Receiver {
    bytes4 private _retval;

    event Received(address operator, address from, uint256 tokenId, bytes data, uint256 gas);

    constructor (bytes4 retval) public {
        _retval = retval;
    }

    function onKIP17Received(address operator, address from, uint256 tokenId, bytes memory data)
        public returns (bytes4)
    {
        emit Received(operator, from, tokenId, data, gasleft());
        return _retval;
    }
}
