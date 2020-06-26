// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;

abstract contract LendingPoolAddressesProviderInterface {
    function getLendingPool() external virtual returns (address);

    function getLendingPoolCore() external virtual returns (address);
}
