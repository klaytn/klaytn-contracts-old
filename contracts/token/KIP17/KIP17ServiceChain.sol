// Copyright 2022 The klaytn Authors
// This file is part of the klaytn library.
//
// The klaytn library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The klaytn library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the klaytn library. If not, see <http://www.gnu.org/licenses/>.

pragma solidity 0.5.6;

import "./KIP17.sol";
import "./IKIP17BridgeReceiver.sol";
import "../../ownership/Ownable.sol";

contract KIP17ServiceChain is KIP17, Ownable {
    using Address for address;
    address public bridge;

    constructor(address _bridge) internal {
        if (!_bridge.isContract()) {
            revert("bridge is not a contract");
        }
        bridge = _bridge;
    }

    function setBridge(address _bridge) public onlyOwner {
        bridge = _bridge;
    }

    function requestValueTransfer(uint256 _uid, address _to, bytes calldata _extraData) external {
        transferFrom(msg.sender, bridge, _uid);

        IKIP17BridgeReceiver(bridge).onKIP17Received(msg.sender, _uid, _to, _extraData);
    }
}
