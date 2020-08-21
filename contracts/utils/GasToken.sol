pragma solidity >=0.6.0;

import "../interfaces/GasTokenInterface.sol";

contract GasToken {
    function burnGasAndFree(address gas_token, uint256 free) public {
        require(GasTokenInterface(gas_token).free(free), "Insufficient gas token");
    }

    function burnGasAndFreeFrom(address gas_token, uint256 free) public {
        require(GasTokenInterface(gas_token).freeFrom(msg.sender, free), "Insufficient gas token");
    }
}
