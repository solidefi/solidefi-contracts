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
    uint16 _referralCode = 0;
    ATokenInterface public aDaiContract;
    LendingPoolAddressesProviderInterface public provider;
    LendingPool public lendingPool;

    constructor() public {
        aDaiContract = ATokenInterface(A_DAI_ADDRESS);
        /// Retrieve LendingPool address
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
        lendingPool.deposit(AAVE_DAI_ADDRESS, _amount, _referralCode);

        // balance should be equal to aDai minted
        uint256 aDaiMinted = aDaiContract.balanceOf(address(this));
        // return cDai to user
        aDaiContract.transfer(_user, aDaiMinted);
    }

    function withdraw(address _user, uint256 _amount) public {}

    function setUserUseReserveAsCollateral(
        address _reserve,
        bool _useAsCollateral
    ) public {
        /// setUserUseReserveAsCollateral method call
        lendingPool.setUserUseReserveAsCollateral(_reserve, _useAsCollateral);
    }
}
