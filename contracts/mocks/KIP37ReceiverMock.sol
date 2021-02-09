// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "../token/KIP37/IKIP37Receiver.sol";
import "./KIP13Mock.sol";

contract KIP37ReceiverMock is IKIP37Receiver, KIP13Mock {
    bytes4 private _recRetval;
    bool private _recReverts;
    bytes4 private _batRetval;
    bool private _batReverts;

    event Received(address operator, address from, uint256 id, uint256 value, bytes data, uint256 gas);
    event BatchReceived(address operator, address from, uint256[] ids, uint256[] values, bytes data, uint256 gas);

    constructor (
        bytes4 recRetval,
        bool recReverts,
        bytes4 batRetval,
        bool batReverts
    )
        public
    {
        _recRetval = recRetval;
        _recReverts = recReverts;
        _batRetval = batRetval;
        _batReverts = batReverts;
    }

    function onKIP37Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4)
    {
        emit Received(operator, from, id, value, data, gasleft());
        return _recRetval;
    }

    function onKIP37BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4)
    {
        emit BatchReceived(operator, from, ids, values, data, gasleft());
        return _batRetval;
    }
}
