pragma solidity ^0.5.0;

import "../ownership/Ownable.sol";

contract SelfDestructible is Ownable {
    function destroy() public onlyOwner  {
        selfdestruct(owner());
    }    
}
