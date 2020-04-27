pragma solidity ^0.5.0;


contract LendingPoolAddressesProviderInterface {
    function getLendingPool() external returns (address);

    function getLendingPoolCore() external returns (address);
}
