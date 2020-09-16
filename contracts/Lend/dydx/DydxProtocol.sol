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

import "../ProtocolInterface.sol";
import "./ISoloMargin.sol";
import "../../interfaces/ERC20.sol";

contract DydxProtocol is ProtocolInterface {
    //mainnet
    address public constant SOLO_MARGIN_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant CDAI_ADDRESS = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;

    ISoloMargin public soloMargin;

    uint256 marketId;

    constructor() public {
        soloMargin = ISoloMargin(SOLO_MARGIN_ADDRESS);
    }

    function deposit(
        address _user,
        uint256 _amount,
        address _token,
        address _cToken
    ) public override {
        require(msg.sender == _user);
        if (_token == DAI_ADDRESS) {
            marketId = 3;
        } else if (_token == USDC_ADDRESS) {
            marketId = 2;
        }
        _cToken == CDAI_ADDRESS;
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
            primaryMarketId: marketId,
            otherAddress: _user,
            secondaryMarketId: 0, //not used
            otherAccountId: 0, //not used
            data: "" //not used
        });

        soloMargin.operate(accounts, actions);
    }

    function withdraw(
        address _user,
        uint256 _amount,
        address _token,
        address _cToken
    ) public override {
        require(msg.sender == _user);
        _cToken = DAI_ADDRESS;
        if (_token == DAI_ADDRESS) {
            marketId = 3;
        } else if (_token == USDC_ADDRESS) {
            marketId = 2;
        }
        _cToken == CDAI_ADDRESS;
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
            primaryMarketId: marketId,
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
