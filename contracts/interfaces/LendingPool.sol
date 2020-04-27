pragma solidity ^0.5.0;


contract LendingPool {
    function deposit(address, uint256, uint16) external;

    function setUserUseReserveAsCollateral(address, bool) external;
}
