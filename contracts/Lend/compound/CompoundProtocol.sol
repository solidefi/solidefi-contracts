pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "../ProtocolInterface.sol";
import "../../interfaces/CTokenInterface.sol";
import "../../compound/Exponential.sol";
import "../../interfaces/ERC20.sol";
import "../../constants/ConstantAddresses.sol";
import "../../DS/DSAuth.sol";


contract CompoundProtocol is
    ProtocolInterface,
    Exponential,
    ConstantAddresses,
    DSAuth
{
    CTokenInterface public cDaiContract;
    address public protocolProxy;

    constructor() public {
        cDaiContract = CTokenInterface(NEW_CDAI_ADDRESS);
    }

    function addProtocolProxy(address _protocolProxy) public auth {
        protocolProxy = _protocolProxy;
    }

    function deposit(address _user, uint256 _amount) public override {
        require(msg.sender == _user);
        // get dai from user
        require(ERC20(DAI_ADDRESS).transferFrom(_user, address(this), _amount));

        ERC20(DAI_ADDRESS).approve(NEW_CDAI_ADDRESS, uint256(-1));
        require(cDaiContract.mint(_amount) == 0, "Failed Mint");
        // balance should be equal to cDai minted
        uint256 cDaiMinted = cDaiContract.balanceOf(address(this));
        // return cDai to user
        cDaiContract.transfer(_user, cDaiMinted);
    }

    function withdraw(address _user, uint256 _amount) public override {
        require(msg.sender == _user);
        // transfer all users balance to this contract
        require(
            cDaiContract.transferFrom(
                _user,
                address(this),
                ERC20(NEW_CDAI_ADDRESS).balanceOf(_user)
            )
        );

        cDaiContract.approve(NEW_CDAI_ADDRESS, uint256(-1));
        // get dai from cDai contract
        require(cDaiContract.redeemUnderlying(_amount) == 0, "Reedem Failed");

        // return to user balance we didn't spend
        uint256 cDaiBalance = cDaiContract.balanceOf(address(this));
        if (cDaiBalance > 0) {
            cDaiContract.transfer(_user, cDaiBalance);
        }
        // return dai we have to user
        ERC20(DAI_ADDRESS).transfer(_user, _amount);
    }
}
