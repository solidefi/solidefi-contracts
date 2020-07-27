// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;

abstract contract ProtocolInterface {
    function deposit(
        address _user,
        uint256 _amount,
        address _token,
        address _cToken
    ) public virtual;

    function withdraw(
        address _user,
        uint256 _amount,
        address _token,
        address _cToken
    ) public virtual;
}
