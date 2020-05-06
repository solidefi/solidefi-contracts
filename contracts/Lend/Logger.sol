pragma solidity ^0.5.0;


contract Logger {
    event Deposit(address indexed sender, uint8 protocol, uint256 amount);
    event Withdraw(address indexed sender, uint8 protocol, uint256 amount);

    function logDeposit(address _sender, uint8 _protocol, uint256 _amount)
        external
    {
        emit Deposit(_sender, _protocol, _amount);
    }

    function logWithdraw(address _sender, uint8 _protocol, uint256 _amount)
        external
    {
        emit Withdraw(_sender, _protocol, _amount);
    }
}
