// MIT License

// Copyright (c) 2019 DecenterApps

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./ISoloMargin.sol";
import "../../interfaces/ERC20.sol";

contract DydxProtocol {
    //kovan
    address public constant SOLO_MARGIN_ADDRESS = 0x4EC3570cADaAEE08Ae384779B0f3A45EF85289DE;
    //mainnet
    //address public constant SOLO_MARGIN_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;

    ISoloMargin public soloMargin;
    address public protocolProxy;

    // kovan saiMarketId = 1
    //uint256 daiMarketId = 1;

    // //mainnet
    // uint256 daiMarketId = 3;
    // uint256 usdcMarketId = 2;

    constructor() public {
        soloMargin = ISoloMargin(SOLO_MARGIN_ADDRESS);
    }

    function dydxDeposit(
        address _user,
        uint256 _amount,
        uint256 _inputMarketId
    ) public {
        require(msg.sender == _user);
        Account.Info[] memory accounts = new Account.Info[](1);
        accounts[0] = getAccount(_user, 0);

        Actions.ActionArgs[] memory actions = new Actions.ActionArgs[](1);
        Types.AssetAmount memory amount = Types.AssetAmount({
            sign: true,
            denomination: Types.AssetDenomination.Wei,
            ref: Types.AssetReference.Delta,
            value: _amount
        });

        actions[0] = Actions.ActionArgs({
            actionType: Actions.ActionType.Deposit,
            accountId: 0,
            amount: amount,
            primaryMarketId: _inputMarketId,
            otherAddress: _user,
            secondaryMarketId: 0, //not used
            otherAccountId: 0, //not used
            data: "" //not used
        });

        soloMargin.operate(accounts, actions);
    }

    function dydxWithdraw(
        address _user,
        uint256 _amount,
        uint256 _inputMarketId
    ) public {
        require(msg.sender == _user);

        Account.Info[] memory accounts = new Account.Info[](1);
        accounts[0] = getAccount(_user, 0);

        Actions.ActionArgs[] memory actions = new Actions.ActionArgs[](1);
        Types.AssetAmount memory amount = Types.AssetAmount({
            sign: false,
            denomination: Types.AssetDenomination.Wei,
            ref: Types.AssetReference.Delta,
            value: _amount
        });

        actions[0] = Actions.ActionArgs({
            actionType: Actions.ActionType.Withdraw,
            accountId: 0,
            amount: amount,
            primaryMarketId: _inputMarketId,
            otherAddress: _user,
            secondaryMarketId: 0, //not used
            otherAccountId: 0, //not used
            data: "" //not used
        });

        soloMargin.operate(accounts, actions);
    }

    function getWeiBalance(
        address _user,
        uint256 _index,
        uint256 _inputMarketId
    ) public view returns (Types.Wei memory) {
        Types.Wei[] memory weiBalances;
        (, , weiBalances) = soloMargin.getAccountBalances(getAccount(_user, _index));

        return weiBalances[_inputMarketId];
    }

    function getParBalance(
        address _user,
        uint256 _index,
        uint256 _inputMarketId
    ) public view returns (Types.Par memory) {
        Types.Par[] memory parBalances;
        (, parBalances, ) = soloMargin.getAccountBalances(getAccount(_user, _index));

        return parBalances[_inputMarketId];
    }

    function getAccount(address _user, uint256 _index) public pure returns (Account.Info memory) {
        Account.Info memory account = Account.Info({owner: _user, number: _index});

        return account;
    }
}
