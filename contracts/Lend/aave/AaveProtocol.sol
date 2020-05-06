pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import "../ProtocolInterface.sol";
import "../../constants/ConstantAddresses.sol";
import "../../interfaces/LendingPoolAddressesProviderInterface.sol";
import "../../interfaces/LendingPool.sol";
import "../../interfaces/ERC20.sol";
import "../../DS/DSAuth.sol";
import "../../interfaces/ATokenInterface.sol";


contract AaveProtocol is ProtocolInterface, ConstantAddresses, DSAuth {
    address public protocolProxy;

    ATokenInterface public aDaiContract;
    LendingPoolAddressesProviderInterface public provider;
    LendingPool public lendingPool;

    constructor() public {
        aDaiContract = ATokenInterface(ADAI_ADDRESS);

        provider = LendingPoolAddressesProviderInterface(
            LENDING_PROTO_ADDRESS_PROV
        );

        lendingPool = LendingPool(provider.getLendingPool());
    }

    function addProtocolProxy(address _protocolProxy) public auth {
        protocolProxy = _protocolProxy;
    }

    function deposit(address _user, uint256 _amount) public {
        require(msg.sender == _user);

        require(
            ERC20(AAVE_DAI_ADDRESS).transferFrom(_user, address(this), _amount)
        );
        ERC20(AAVE_DAI_ADDRESS).approve(
            provider.getLendingPoolCore(),
            uint256(-1)
        );
        lendingPool.deposit(AAVE_DAI_ADDRESS, _amount, 0);

        // balance should be equal to aDai minted
        uint256 aDaiMinted = aDaiContract.balanceOf(address(this));
        // return aDai to user
        aDaiContract.transfer(_user, aDaiMinted);
    }

    function withdraw(address _user, uint256 _amount) public {
        require(msg.sender == _user);
        // transfer all users balance to this contract
        require(aDaiContract.transferFrom(_user, address(this), _amount));

        aDaiContract.redeem(_amount);

        // return dai we have to user
        ERC20(AAVE_DAI_ADDRESS).transfer(_user, _amount);
    }
}
