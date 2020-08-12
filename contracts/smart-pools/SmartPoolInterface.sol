// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;

abstract contract SmartPoolInterface {
    function joinPool(
        address _user,
        uint256 _amount,
        address _bpool
    ) public virtual;
}
