// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./ProtocolInterface.sol";
import "../interfaces/ERC20.sol";
import "./dydx/ISoloMargin.sol";
import "./Logger.sol";
import "../interfaces/ComptrollerInterface.sol";

contract ProtocolProxy {
    //Rinkeby

    // address public constant DAI_ADDRESS = 0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa;
    // address public constant SAVINGS_COMPOUND_ADDRESS = 0x21182Be016C37B0CFD70Bf4Fbbe8B983c365D60E;
    // kovan
    address public constant LOGGER_ADDRESS = 0xf1A6dA3d64F67c4A4800672836A4c5ebF4623473;
    address public constant SAVINGS_COMPOUND_ADDRESS = 0x28C48Aa83DA32a16640BeAb73aBB1deA14359cF7;
    address public constant SAVINGS_DYDX_ADDRESS = 0xcfB88f711b05c5A0ff799850Da7A57b9b88De0b6;
    address public constant SAVINGS_AAVE_ADDRESS = 0xb9D9E0c41d45263420352c261ea4F53Dc2e7fc95;
    //constant kovan
    address public constant DAI_ADDRESS = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    address public constant SAI_ADDRESS = 0xC4375B7De8af5a38a93548eb8453a498222C4fF2;
    address public constant AAVE_DAI_ADDRESS = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    address public constant ADAI_ADDRESS = 0x58AD4cB396411B691A9AAb6F74545b2C5217FE6a;
    address public constant CDAI_ADDRESS = 0xF0d0EB522cfa50B716B3b1604C4F0fA6f04376AD;
    address public constant SOLO_MARGIN_ADDRESS = 0x4EC3570cADaAEE08Ae384779B0f3A45EF85289DE;
    address public constant COMPTROLLER_ADDRESS = 0x5eAe89DC1C671724A672ff0630122ee834098657;

    // mainnet
    // address public constant LOGGER_ADDRESS = 0xf1A6dA3d64F67c4A4800672836A4c5ebF4623473;
    // address public constant SAVINGS_COMPOUND_ADDRESS = 0xFca70d5e2Ba8EF6c2B13cD43Ad8eFdDEDEd6aA13;
    // address public constant SAVINGS_DYDX_ADDRESS = 0xb44dd830d255182D24ED2Eb74b5ceDf4F1b18C75;
    // address public constant SAVINGS_AAVE_ADDRESS = 0xb63dB2CB8a62D3564B3C984aa02AC820573BF64a;

    // constant mainnet
    // address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // address public constant ADAI_ADDRESS = 0xfC1E690f61EFd961294b3e1Ce3313fBD8aa4f85d;
    // address public constant CDAI_ADDRESS = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    // address public constant SOLO_MARGIN_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    //address public constant COMPTROLLER_ADDRESS = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;

    enum SavingsProtocol {Compound, Dydx, Aave}

    function deposit(SavingsProtocol _protocol, uint256 _amount) public {
        _deposit(_protocol, _amount, true);

        Logger(LOGGER_ADDRESS).logDeposit(msg.sender, uint8(_protocol), _amount, uint256(now));
    }

    function withdraw(SavingsProtocol _protocol, uint256 _amount) public {
        _withdraw(_protocol, _amount, true);

        Logger(LOGGER_ADDRESS).logWithdraw(msg.sender, uint8(_protocol), _amount, uint256(now));
    }

    // main net
    // function withdrawDai() public {
    //     ERC20(DAI_ADDRESS).transfer(
    //         msg.sender,
    //         ERC20(DAI_ADDRESS).balanceOf(address(this))
    //     );
    // }
    // kovan test net only
    function withdrawDai(SavingsProtocol _protocol) public {
        if (_protocol == SavingsProtocol.Compound) {
            ERC20(DAI_ADDRESS).transfer(msg.sender, ERC20(DAI_ADDRESS).balanceOf(address(this)));
        }
        if (_protocol == SavingsProtocol.Dydx) {
            ERC20(SAI_ADDRESS).transfer(msg.sender, ERC20(SAI_ADDRESS).balanceOf(address(this)));
        }
        if (_protocol == SavingsProtocol.Aave) {
            ERC20(AAVE_DAI_ADDRESS).transfer(
                msg.sender,
                ERC20(AAVE_DAI_ADDRESS).balanceOf(address(this))
            );
        }
    }

    function getAddress(SavingsProtocol _protocol) public pure returns (address) {
        if (_protocol == SavingsProtocol.Compound) {
            return SAVINGS_COMPOUND_ADDRESS;
        }

        if (_protocol == SavingsProtocol.Dydx) {
            return SAVINGS_DYDX_ADDRESS;
        }

        if (_protocol == SavingsProtocol.Aave) {
            return SAVINGS_AAVE_ADDRESS;
        }
    }

    function _deposit(
        SavingsProtocol _protocol,
        uint256 _amount,
        bool _fromUser
    ) internal {
        // kovan compound DAI_ADDRESS
        // kovan dydx SAI_ADDRESS
        // kovan Aave AAVE_DAI_ADDRESS

        // just for testing on kovan due to diff dai address
        if (_protocol == SavingsProtocol.Compound) {
            if (_fromUser) {
                ERC20(DAI_ADDRESS).transferFrom(msg.sender, address(this), _amount);
            }
        }
        if (_protocol == SavingsProtocol.Dydx) {
            if (_fromUser) {
                ERC20(SAI_ADDRESS).transferFrom(msg.sender, address(this), _amount);
            }
        }
        if (_protocol == SavingsProtocol.Aave) {
            if (_fromUser) {
                ERC20(AAVE_DAI_ADDRESS).transferFrom(msg.sender, address(this), _amount);
            }
        }
        approveDeposit(_protocol);

        ProtocolInterface(getAddress(_protocol)).deposit(address(this), _amount);

        endAction(_protocol);
    }

    function _withdraw(
        SavingsProtocol _protocol,
        uint256 _amount,
        bool _toUser
    ) public {
        approveWithdraw(_protocol);

        ProtocolInterface(getAddress(_protocol)).withdraw(address(this), _amount);

        endAction(_protocol);

        if (_toUser) {
            withdrawDai(_protocol);
        }
    }

    function swap(
        SavingsProtocol _from,
        SavingsProtocol _to,
        uint256 _amount
    ) public {
        _withdraw(_from, _amount, false);

        uint256 amountToDeposit = ERC20(DAI_ADDRESS).balanceOf(address(this));

        _deposit(_to, amountToDeposit, false);

        Logger(LOGGER_ADDRESS).logSwap(msg.sender, uint8(_from), uint8(_to), _amount);
    }

    function endAction(SavingsProtocol _protocol) internal {
        if (_protocol == SavingsProtocol.Dydx) {
            setDydxOperator(false);
        }
    }

    function approveDeposit(SavingsProtocol _protocol) internal {
        if (_protocol == SavingsProtocol.Compound) {
            ERC20(DAI_ADDRESS).approve(getAddress(_protocol), uint256(-1));
        }

        if (_protocol == SavingsProtocol.Dydx) {
            ERC20(SAI_ADDRESS).approve(SOLO_MARGIN_ADDRESS, uint256(-1));
            setDydxOperator(true);
        }

        if (_protocol == SavingsProtocol.Aave) {
            ERC20(AAVE_DAI_ADDRESS).approve(getAddress(_protocol), uint256(-1));
        }
    }

    function approveWithdraw(SavingsProtocol _protocol) internal {
        if (_protocol == SavingsProtocol.Compound) {
            ERC20(CDAI_ADDRESS).approve(getAddress(_protocol), uint256(-1));
        }

        if (_protocol == SavingsProtocol.Dydx) {
            setDydxOperator(true);
        }

        if (_protocol == SavingsProtocol.Aave) {
            ERC20(ADAI_ADDRESS).approve(getAddress(_protocol), uint256(-1));
        }
    }

    function setDydxOperator(bool _trusted) internal {
        ISoloMargin.OperatorArg[] memory operatorArgs = new ISoloMargin.OperatorArg[](1);
        operatorArgs[0] = ISoloMargin.OperatorArg({
            operator: getAddress(SavingsProtocol.Dydx),
            trusted: _trusted
        });

        ISoloMargin(SOLO_MARGIN_ADDRESS).setOperators(operatorArgs);
    }

    function claimComp() public {
        ComptrollerInterface(COMPTROLLER_ADDRESS).claimComp(address(this));
    }
}
