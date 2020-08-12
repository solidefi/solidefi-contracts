// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;

interface ERC20 {
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _src, address indexed _dst, uint256 _amount);
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    // function decimals() external view returns (uint256 digits);

   
}
