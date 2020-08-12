pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;
import "./SmartPoolInterface.sol";
import "../interfaces/ERC20.sol";
import "../interfaces/IBPool.sol";

contract ProxySmartPool {
    IBPool public bPool;

    function joinSmartPool(uint256 _amount, address _bPool) public {
        approveSmartPool(_bPool);
        SmartPoolInterface(0xAe163bd44DCb67AEa98cC5E25657156702639ecE).joinPool(
            address(this),
            _amount,
            _bPool
        );
    }

    function approveSmartPool(address _bPool) internal {
        bPool = IBPool(_bPool);
        address[] memory tokens = bPool.getCurrentTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            address t = tokens[i];
            ERC20(t).approve(0xAe163bd44DCb67AEa98cC5E25657156702639ecE, uint256(-1));
        }
        // ERC20(DAI_ADDRESS).approve(getAddress(_protocol), uint256(-1));
    }
}
