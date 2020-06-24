pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;
import "../ProtocolInterface.sol";
import "../../constants/ConstantAddresses.sol";
import "../../interfaces/LendingPoolAddressesProviderInterface.sol";
import "../../interfaces/LendingPool.sol";
import "../../interfaces/ERC20.sol";
import "../../interfaces/ATokenInterface.sol";

contract AaveProtocol is ProtocolInterface, ConstantAddresses {
    address public protocolProxy;

    ATokenInterface public aDaiContract;
    LendingPoolAddressesProviderInterface public provider;
    LendingPool public lendingPool;

    constructor() public {
        aDaiContract = ATokenInterface(ADAI_ADDRESS);

        provider = LendingPoolAddressesProviderInterface(LENDING_PROTO_ADDRESS_PROV);

        lendingPool = LendingPool(provider.getLendingPool());
    }

    /**
     * @dev Deposit DAI to aave protocol return cDAI to user proxy wallet.
     * @param _user User proxy wallet address.
     * @param _amount Amount of DAI.
     */
    function deposit(address _user, uint256 _amount) public override {
        require(
            ERC20(AAVE_DAI_ADDRESS).transferFrom(_user, address(this), _amount),
            "Nothing to deposit"
        );
        ERC20(AAVE_DAI_ADDRESS).approve(provider.getLendingPoolCore(), uint256(-1));
        lendingPool.deposit(AAVE_DAI_ADDRESS, _amount, 0);

        aDaiContract.transfer(_user, aDaiContract.balanceOf(address(this)));
    }

    /**
     *@dev Withdraw DAI from aave protocol return it to users EOA
     *@param _user User proxy wallet address.
     *@param _amount Amount of DAI.
     */
    function withdraw(address _user, uint256 _amount) public override {
        require(aDaiContract.transferFrom(_user, address(this), _amount), "Nothing to withdraw");

        aDaiContract.redeem(_amount);

        ERC20(AAVE_DAI_ADDRESS).transfer(_user, _amount);
    }
}
