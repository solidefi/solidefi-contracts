// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "../ProtocolInterface.sol";
import "../../interfaces/LendingPoolAddressesProviderInterface.sol";
import "../../interfaces/LendingPool.sol";
import "../../interfaces/ERC20.sol";
import "../../interfaces/ATokenInterface.sol";

contract AaveProtocol is ProtocolInterface {
    //kovan
    // address public constant ADAI_ADDRESS = 0x58AD4cB396411B691A9AAb6F74545b2C5217FE6a;
    // address public constant AAVE_DAI_ADDRESS = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    address public constant LENDING_PROTO_ADDRESS_PROV = 0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5;
    // address public constant LENDING_POOL = 0x580D4Fdc4BF8f9b5ae2fb9225D584fED4AD5375c;
    // address public constant LENDING_POOL_CORE = 0x95D1189Ed88B380E319dF73fF00E479fcc4CFa45;

    // //mainnet
    // address public constant ADAI_ADDRESS = 0xfC1E690f61EFd961294b3e1Ce3313fBD8aa4f85d;
    // address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // address public constant LENDING_PROTO_ADDRESS_PROV = 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8;
    // address public constant LENDING_POOL = 0x398eC7346DcD622eDc5ae82352F02bE94C62d119;
    // address public constant LENDING_POOL_CORE = 0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3;

    ATokenInterface public aDaiContract;
    LendingPoolAddressesProviderInterface public provider;
    LendingPool public lendingPool;

    // constructor() public {
    //     aDaiContract = ATokenInterface(ADAI_ADDRESS);
    // }

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
