pragma solidity >=0.6.0;

import "./ERC20.sol";

abstract contract ATokenInterface is ERC20 {
    function principalBalanceOf(address _user) external virtual view returns (uint256 balance);

    function UINT_MAX_VALUE() external virtual returns (uint256);

    function underlyingAssetAddress() external virtual view returns (address);

    function getUserIndex(address _user) external virtual view returns (uint256);

    function getInterestRedirectionAddress(address _user) external virtual view returns (address);

    function getRedirectedBalance(address _user) external virtual view returns (uint256);

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool);

    function redirectInterestStream(address _to) external virtual;

    function redirectInterestStreamOf(address _from, address _to) external virtual;

    function allowInterestRedirectionTo(address _to) external virtual;

    function redeem(uint256 _amount) external virtual;

    function mintOnDeposit(address _account, uint256 _amount) external virtual;

    function burnOnLiquidation(address _account, uint256 _value) external virtual;

    function transferOnLiquidation(
        address _from,
        address _to,
        uint256 _value
    ) external virtual;

    function isTransferAllowed(address _user, uint256 _amount) external virtual view returns (bool);
}
