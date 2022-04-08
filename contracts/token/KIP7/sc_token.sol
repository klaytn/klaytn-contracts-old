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

import "./KIP7Mintable.sol";
import "./KIP7Burnable.sol";
import "./KIP7Pausable.sol";
import "./KIP7Metadata.sol";
import "./KIP7ServiceChain.sol";

contract ServiceChainTokenKIP7 is KIP7, KIP7Mintable, KIP7Burnable, KIP7Pausable, KIP7Metadata, KIP7ServiceChain {
    string public constant NAME = "KIP7ServiceChain";
    string public constant SYMBOL = "KIP7SCT";
    uint8 public constant DECIMALS = 18;

    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(DECIMALS));

    constructor(address _bridge) KIP7Metadata(NAME, SYMBOL, DECIMALS) KIP7ServiceChain(_bridge) public {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
