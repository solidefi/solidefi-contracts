// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "../ProtocolInterface.sol";
import "../../interfaces/CTokenInterface.sol";
import "../../interfaces/ERC20.sol";

/**
 * @notice CompoundProtocol
 * @author Solidefi
 */
contract CompoundProtocol is ProtocolInterface {
    CTokenInterface public cTokenContract;

    /**
     * @dev Deposit DAI to compound protocol return cDAI to user proxy wallet.
     * @param _user User proxy wallet address.
     * @param _amount Amount of DAI.
     */

    function deposit(
        address _user,
        uint256 _amount,
        address _token,
        address _cToken
    ) public override {
        cTokenContract = CTokenInterface(_cToken);

        require(ERC20(_token).transferFrom(_user, address(this), _amount), "Nothing to deposit");

        ERC20(_token).approve(_cToken, uint256(-1));
        require(cTokenContract.mint(_amount) == 0, "Failed to mint");
        cTokenContract.transfer(_user, cTokenContract.balanceOf(address(this)));
    }

    /**
     *@dev Withdraw DAI from Compound protcol return it to users EOA
     *@param _user User proxy wallet address.
     *@param _amount Amount of DAI.
     */
    function withdraw(
        address _user,
        uint256 _amount,
        address _token,
        address _cToken
    ) public override {
        cTokenContract = CTokenInterface(_cToken);
        require(
            cTokenContract.transferFrom(_user, address(this), ERC20(_cToken).balanceOf(_user)),
            "Nothing to withdraw"
        );
        cTokenContract.approve(_cToken, uint256(-1));
        require(cTokenContract.redeemUnderlying(_amount) == 0, "Reedem Failed");
        uint256 cDaiBalance = cTokenContract.balanceOf(address(this));
        if (cDaiBalance > 0) {
            cTokenContract.transfer(_user, cDaiBalance);
        }
        ERC20(_token).transfer(_user, _amount);
    }
}
