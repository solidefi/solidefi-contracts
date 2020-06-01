pragma solidity ^0.5.0;

import "./ERC20.sol";


contract ATokenInterface is ERC20 {
    function principalBalanceOf(address _user)
        external
        view
        returns (uint256 balance);

    function UINT_MAX_VALUE() external returns (uint256);

    function underlyingAssetAddress() external view returns (address);

    function getUserIndex(address _user) external view returns (uint256);

    function getInterestRedirectionAddress(address _user)
        external
        view
        returns (address);

    function getRedirectedBalance(address _user)
        external
        view
        returns (uint256);

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);

    function redirectInterestStream(address _to) external;

    function redirectInterestStreamOf(address _from, address _to) external;

    function allowInterestRedirectionTo(address _to) external;

    function redeem(uint256 _amount) external;

    function mintOnDeposit(address _account, uint256 _amount) external;

    function burnOnLiquidation(address _account, uint256 _value) external;

    function transferOnLiquidation(
        address _from,
        address _to,
        uint256 _value
    ) external;

    function isTransferAllowed(address _user, uint256 _amount)
        external
        view
        returns (bool);
}
