pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "../ProtocolInterface.sol";
import "../../interfaces/CTokenInterface.sol";
import "../../interfaces/ERC20.sol";
import "../../constants/ConstantAddresses.sol";

contract CompoundProtocol is ProtocolInterface, ConstantAddresses {
    CTokenInterface public cDaiContract;
    address public protocolProxy;

    constructor() public {
        cDaiContract = CTokenInterface(CDAI_ADDRESS);
    }

    /**
     * @dev Deposit DAI to compound protocol return cDAI to user proxy wallet.
     * @param _user User proxy wallet address.
     * @param _amount Amount of DAI.
     */

    function deposit(address _user, uint256 _amount) public override {
        require(
            ERC20(DAI_ADDRESS).transferFrom(_user, address(this), _amount),
            "Nothing to deposit"
        );

        ERC20(DAI_ADDRESS).approve(CDAI_ADDRESS, uint256(-1));
        require(cDaiContract.mint(_amount) == 0, "Failed cDaiContract.mint");
        cDaiContract.transfer(_user, cDaiContract.balanceOf(address(this)));
    }

    /**
     *@dev Withdraw DAI from Compound protcol return it to users EOA
     *@param _user User proxy wallet address.
     *@param _amount Amount of DAI.
     */
    function withdraw(address _user, uint256 _amount) public override {
        require(
            cDaiContract.transferFrom(_user, address(this), ERC20(CDAI_ADDRESS).balanceOf(_user)),
            "Nothing to withdraw"
        );
        cDaiContract.approve(CDAI_ADDRESS, uint256(-1));
        require(cDaiContract.redeemUnderlying(_amount) == 0, "Reedem Failed");
        uint256 cDaiBalance = cDaiContract.balanceOf(address(this));
        if (cDaiBalance > 0) {
            cDaiContract.transfer(_user, cDaiBalance);
        }
        ERC20(DAI_ADDRESS).transfer(_user, _amount);
    }
}
