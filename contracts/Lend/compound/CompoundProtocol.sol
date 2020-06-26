// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "../ProtocolInterface.sol";
import "../../interfaces/CTokenInterface.sol";
import "../../interfaces/ERC20.sol";

contract CompoundProtocol is ProtocolInterface {
    // rinkeby
    // address public constant DAI_ADDRESS = 0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa;
    // address public constant CDAI_ADDRESS = 0x6D7F0754FFeb405d23C51CE938289d4835bE3b14;
    // kovan
    address public constant DAI_ADDRESS = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    address public constant CDAI_ADDRESS = 0xF0d0EB522cfa50B716B3b1604C4F0fA6f04376AD;
    //address public constant OLD_CDAI_ADDRESS = 0xe7bc397DBd069fC7d0109C0636d06888bb50668c;

    //mainnet
    // address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // address public constant CDAI_ADDRESS = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;

    CTokenInterface public cDaiContract;

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
