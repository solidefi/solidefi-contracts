// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./ProtocolInterface.sol";
import "../interfaces/ERC20.sol";
import "./dydx/ISoloMargin.sol";
import "./Logger.sol";
import "../constants/ConstantAddresses.sol";
import "./dydx/DydxProtocol.sol";

//import "../interfaces/ComptrollerInterface.sol";

contract ProtocolProxy is ConstantAddresses, DydxProtocol {
    enum SavingsProtocol {Compound, Dydx, Aave}

    enum SavingsToken {DAI, USDC, USDT, TUSD}

    function deposit(
        SavingsProtocol _protocol,
        SavingsToken _coin,
        uint256 _amount
    ) public {
        _deposit(_protocol, _coin, _amount);

        Logger(LOGGER_ADDRESS).logDeposit(msg.sender, uint8(_protocol), _amount, uint256(now));
    }

    function withdraw(
        SavingsProtocol _protocol,
        SavingsToken _coin,
        uint256 _amount
    ) public {
        _withdraw(_protocol, _coin, _amount);

        Logger(LOGGER_ADDRESS).logWithdraw(msg.sender, uint8(_protocol), _amount, uint256(now));
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
    // function getTokenAddress(SavingsToken _coin) public pure returns (address, address) {
    //     if (_coin == SavingsToken.DAI) {
    //         return (DAI_ADDRESS, CDAI_ADDRESS);
    //     }

    //     if (_coin == SavingsToken.USDC) {
    //         return (USDC_ADDRESS, CUSDC_ADDRESS);
    //     }

    //     if (_coin == SavingsToken.USDT) {
    //         return (USDT_ADDRESS, USDT_ADDRESS);
    //     }
    // }

    //kovan
    function getTokenAddress(SavingsToken _coin, SavingsProtocol _protocol)
        public
        pure
        returns (address, address)
    {
        if (_protocol == SavingsProtocol.Compound) {
            if (_coin == SavingsToken.DAI) {
                return (DAI_ADDRESS, CDAI_ADDRESS);
            }

            if (_coin == SavingsToken.USDC) {
                return (USDC_ADDRESS, CUSDC_ADDRESS);
            }

            if (_coin == SavingsToken.USDT) {
                return (USDT_ADDRESS, USDT_ADDRESS);
            }
        }
        if (_protocol == SavingsProtocol.Aave) {
            if (_coin == SavingsToken.DAI) {
                return (AAVE_DAI_ADDRESS, ADAI_ADDRESS);
            }

            if (_coin == SavingsToken.USDC) {
                return (AAVE_USDC_ADDRESS, AAVE_AUSDC_ADDRESS);
            }

            if (_coin == SavingsToken.USDT) {
                return (AAVE_USDT_ADDRESS, AAVE_AUSDT_ADDRESS);
            }
        }
    }

    // Interest-Bearing Token
    function _deposit(
        SavingsProtocol _protocol,
        SavingsToken _coin,
        uint256 _amount
    ) internal {
        approveDeposit(_protocol, _coin);

        if (_protocol == SavingsProtocol.Dydx) {
            uint256 _inputMarketId;
            if (_coin == SavingsToken.DAI) {
                _inputMarketId = 1;
            } else {
                _inputMarketId = 2;
            }
            dydxDeposit(address(this), _amount, _inputMarketId);
            endAction(_protocol);
        } else {
            (address TOKEN, address IBTOKEN) = getTokenAddress(_coin, _protocol);

            ProtocolInterface(getAddress(_protocol)).deposit(
                address(this),
                _amount,
                TOKEN,
                IBTOKEN
            );
        }
    }

    function _withdraw(
        SavingsProtocol _protocol,
        SavingsToken _coin,
        uint256 _amount
    ) public {
        approveWithdraw(_protocol, _coin);
        if (_protocol == SavingsProtocol.Dydx) {
            uint256 _inputMarketId;
            if (_coin == SavingsToken.DAI) {
                _inputMarketId = 1;
            } else {
                _inputMarketId = 2;
            }
            dydxWithdraw(address(this), _amount, _inputMarketId);
            endAction(_protocol);
        } else {
            (address TOKEN, address IBTOKEN) = getTokenAddress(_coin, _protocol);
            ProtocolInterface(getAddress(_protocol)).withdraw(
                address(this),
                _amount,
                TOKEN,
                IBTOKEN
            );
        }
    }

    // function swap(
    //     SavingsProtocol _from,
    //     SavingsProtocol _to,
    //     uint256 _amount,
    //     SavingsToken _coin
    // ) public {
    //     _withdraw(_from, _amount);

    //     uint256 amountToDeposit = ERC20(DAI_ADDRESS).balanceOf(address(this));

    //     _deposit(_to, amountToDeposit, _coin);

    //     Logger(LOGGER_ADDRESS).logSwap(msg.sender, uint8(_from), uint8(_to), _amount);
    // }

    function endAction(SavingsProtocol _protocol) internal {
        if (_protocol == SavingsProtocol.Dydx) {
            setDydxOperator(false);
        }
    }

    function approveDeposit(SavingsProtocol _protocol, SavingsToken _coin) internal {
        // kovan
        (address TOKEN, ) = getTokenAddress(_coin, _protocol);
        if (_protocol == SavingsProtocol.Compound) {
            ERC20(TOKEN).approve(getAddress(_protocol), uint256(-1));
        }

        if (_protocol == SavingsProtocol.Dydx) {
            ERC20(SAI_ADDRESS).approve(SOLO_MARGIN_ADDRESS, uint256(-1));
            setDydxOperator(true);
        }

        if (_protocol == SavingsProtocol.Aave) {
            ERC20(TOKEN).approve(getAddress(_protocol), uint256(-1));
        }
    }

    function approveWithdraw(SavingsProtocol _protocol, SavingsToken _coin) internal {
        (, address IBTOKEN) = getTokenAddress(_coin, _protocol);
        if (_protocol == SavingsProtocol.Compound) {
            ERC20(IBTOKEN).approve(getAddress(_protocol), uint256(-1));
        }

        if (_protocol == SavingsProtocol.Dydx) {
            setDydxOperator(true);
        }

        if (_protocol == SavingsProtocol.Aave) {
            ERC20(IBTOKEN).approve(getAddress(_protocol), uint256(-1));
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
