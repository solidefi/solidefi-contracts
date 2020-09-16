// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "../ProtocolInterface.sol";
import "../../interfaces/LendingPoolAddressesProviderInterface.sol";
import "../../interfaces/LendingPool.sol";
import "../../interfaces/ERC20.sol";
import "../../interfaces/ATokenInterface.sol";

/**
 * @notice AaveProtocol
 * @author Solidefi
 */
contract AaveProtocol is ProtocolInterface {
    address public constant LENDING_PROTO_ADDRESS_PROV = 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8;

    ATokenInterface public aDaiContract;
    LendingPoolAddressesProviderInterface public provider;
    LendingPool public lendingPool;

    /**
     * @dev Deposit DAI to aave protocol return cDAI to user proxy wallet.
     * @param _user User proxy wallet address.
     * @param _amount Amount of DAI.
     */
    function deposit(
        address _user,
        uint256 _amount,
        address _token,
        address _aToken
    ) public override {
        aDaiContract = ATokenInterface(_aToken);
        provider = LendingPoolAddressesProviderInterface(LENDING_PROTO_ADDRESS_PROV);

        lendingPool = LendingPool(provider.getLendingPool());
        require(ERC20(_token).transferFrom(_user, address(this), _amount), "Nothing to deposit");
        ERC20(_token).approve(provider.getLendingPoolCore(), uint256(-1));
        lendingPool.deposit(_token, _amount, 0);

        aDaiContract.transfer(_user, aDaiContract.balanceOf(address(this)));
    }

    /**
     *@dev Withdraw DAI from aave protocol return it to users EOA
     *@param _user User proxy wallet address.
     *@param _amount Amount of Token.
     *@param _token Token address.
     *@param _aToken Interest-Bearing Token address.
     */
    function withdraw(
        address _user,
        uint256 _amount,
        address _token,
        address _aToken
    ) public override {
        aDaiContract = ATokenInterface(_aToken);
        require(aDaiContract.transferFrom(_user, address(this), _amount), "Nothing to withdraw");

        aDaiContract.redeem(_amount);

        ERC20(_token).transfer(_user, _amount);
    }
}
