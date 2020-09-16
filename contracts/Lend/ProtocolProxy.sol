// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./ProtocolInterface.sol";
import "../interfaces/ERC20.sol";
import "./dydx/ISoloMargin.sol";
import "./Logger.sol";
import "../constants/ConstantAddresses.sol";

/**
 * @notice ProtocolProxy
 * @author Solidefi
 */
contract ProtocolProxy is ConstantAddresses {
    enum SavingsProtocol {Compound, Dydx, Aave}

    enum SavingsToken {DAI, USDC, USDT, TUSD}

    function deposit(
        SavingsProtocol _protocol,
        SavingsToken _coin,
        uint256 _amount
    ) public {
        _deposit(_protocol, _coin, _amount);

        Logger(LOGGER_ADDRESS).logDeposit(
            msg.sender,
            uint8(_protocol),
            uint8(_coin),
            _amount,
            uint256(now)
        );
    }

    function withdraw(
        SavingsProtocol _protocol,
        SavingsToken _coin,
        uint256 _amount
    ) public {
        _withdraw(_protocol, _coin, _amount);

        Logger(LOGGER_ADDRESS).logWithdraw(
            msg.sender,
            uint8(_protocol),
            uint8(_coin),
            _amount,
            uint256(now)
        );
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

    // mainnet
    function getTokenAddress(SavingsToken _coin) public pure returns (address, address) {
        if (_coin == SavingsToken.DAI) {
            return (DAI_ADDRESS, CDAI_ADDRESS);
        }

        if (_coin == SavingsToken.USDC) {
            return (USDC_ADDRESS, CUSDC_ADDRESS);
        }

        if (_coin == SavingsToken.USDT) {
            return (USDT_ADDRESS, CUSDT_ADDRESS);
        }
    }

    // Interest-Bearing Token
    function _deposit(
        SavingsProtocol _protocol,
        SavingsToken _coin,
        uint256 _amount
    ) internal {
        approveDeposit(_protocol, _coin);
        (address TOKEN, address IBTOKEN) = getTokenAddress(_coin);

        ProtocolInterface(getAddress(_protocol)).deposit(address(this), _amount, TOKEN, IBTOKEN);
    }

    function _withdraw(
        SavingsProtocol _protocol,
        SavingsToken _coin,
        uint256 _amount
    ) internal {
        approveWithdraw(_protocol, _coin);

        (address TOKEN, address IBTOKEN) = getTokenAddress(_coin);
        ProtocolInterface(getAddress(_protocol)).withdraw(address(this), _amount, TOKEN, IBTOKEN);
    }

    function swap(
        SavingsProtocol _from,
        SavingsProtocol _to,
        uint256 _amount,
        SavingsToken _coin
    ) public {
        (address TOKEN, ) = getTokenAddress(_coin);
        _withdraw(_from, _coin, _amount);

        uint256 amountToDeposit = ERC20(TOKEN).balanceOf(address(this));

        _deposit(_to, _coin, amountToDeposit);

        Logger(LOGGER_ADDRESS).logSwap(msg.sender, uint8(_from), uint8(_to), _amount);
    }

    function endAction(SavingsProtocol _protocol) internal {
        if (_protocol == SavingsProtocol.Dydx) {
            setDydxOperator(false);
        }
    }

    function approveDeposit(SavingsProtocol _protocol, SavingsToken _coin) internal {
        (address TOKEN, ) = getTokenAddress(_coin);
        if (_protocol == SavingsProtocol.Compound || _protocol == SavingsProtocol.Aave) {
            ERC20(TOKEN).approve(getAddress(_protocol), uint256(-1));
        }

        if (_protocol == SavingsProtocol.Dydx) {
            ERC20(TOKEN).approve(SOLO_MARGIN_ADDRESS, uint256(-1));
            setDydxOperator(true);
        }
    }

    function approveWithdraw(SavingsProtocol _protocol, SavingsToken _coin) internal {
        (, address IBTOKEN) = getTokenAddress(_coin);
        if (_protocol == SavingsProtocol.Compound || _protocol == SavingsProtocol.Aave) {
            ERC20(IBTOKEN).approve(getAddress(_protocol), uint256(-1));
        }

        if (_protocol == SavingsProtocol.Dydx) {
            setDydxOperator(true);
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
}
