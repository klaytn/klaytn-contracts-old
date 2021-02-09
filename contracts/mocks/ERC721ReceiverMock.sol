pragma solidity ^0.5.0;

import "../token/KIP17/IERC721Receiver.sol";

contract ERC721ReceiverMock is IERC721Receiver {
    bytes4 private _retval;

    event Received(address operator, address from, uint256 tokenId, bytes data, uint256 gas);

    constructor (bytes4 retval) public {
        _retval = retval;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
        public returns (bytes4)
    {
        emit Received(operator, from, tokenId, data, gasleft());
        return _retval;
    }
}
