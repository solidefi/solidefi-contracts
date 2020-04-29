pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./ProtocolInterface.sol";
import "../interfaces/ERC20.sol";
import "../interfaces/ITokenInterface.sol";
import "../constants/ConstantAddresses.sol";
import "./dydx/ISoloMargin.sol";


//import "./SavingsLogger.sol";

contract ProtocolProxy is ConstantAddresses {
    address public constant COMPOUND_ADDRESS = 0x51b599C3572A4DD2A896F36b5914F0bFb012BC58;
    address public constant DYDX_ADDRESS = 0x06bE8ff02421443332A38eDcf72c9d11F5b53426;
    address public constant AAVE_ADDRESS = 0xAA4809b498342335C02B6057f237f5C5916D8C79;
    enum SavingsProtocol {Compound, Dydx, Aave}

    function deposit(SavingsProtocol _protocol, uint256 _amount) public {
        _deposit(_protocol, _amount, true);

        // SavingsLogger(SAVINGS_LOGGER_ADDRESS).logDeposit(
        //     msg.sender,
        //     uint8(_protocol),
        //     _amount
        // );
    }

    function withdraw(SavingsProtocol _protocol, uint256 _amount) public {
        _withdraw(_protocol, _amount, true);

        // SavingsLogger(SAVINGS_LOGGER_ADDRESS).logWithdraw(
        //     msg.sender,
        //     uint8(_protocol),
        //     _amount
        // );
    }

    function withdrawDai() public {
        ERC20(AAVE_DAI_ADDRESS).transfer(
            msg.sender,
            ERC20(AAVE_DAI_ADDRESS).balanceOf(address(this))
        );
    }

    function getAddress(SavingsProtocol _protocol)
        public
        pure
        returns (address)
    {
        if (_protocol == SavingsProtocol.Compound) {
            return COMPOUND_ADDRESS;
        }

        if (_protocol == SavingsProtocol.Dydx) {
            return DYDX_ADDRESS;
        }

        if (_protocol == SavingsProtocol.Aave) {
            return AAVE_ADDRESS;
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

        // just for testing on kovan due to diff dai address extra check
        if (_protocol == SavingsProtocol.Compound) {
            if (_fromUser) {
                ERC20(DAI_ADDRESS).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                );
            }
        }
        if (_protocol == SavingsProtocol.Dydx) {
            if (_fromUser) {
                ERC20(SAI_ADDRESS).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                );
            }
        }
        if (_protocol == SavingsProtocol.Aave) {
            if (_fromUser) {
                ERC20(AAVE_DAI_ADDRESS).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                );
            }
        }
        approveDeposit(_protocol);

        ProtocolInterface(getAddress(_protocol)).deposit(
            address(this),
            _amount
        );

        endAction(_protocol);
    }

    function _withdraw(SavingsProtocol _protocol, uint256 _amount, bool _toUser)
        public
    {
        approveWithdraw(_protocol);

        ProtocolInterface(getAddress(_protocol)).withdraw(
            address(this),
            _amount
        );

        endAction(_protocol);

        if (_toUser) {
            withdrawDai();
        }
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
            ERC20(NEW_CDAI_ADDRESS).approve(getAddress(_protocol), uint256(-1));
        }

        if (_protocol == SavingsProtocol.Dydx) {
            setDydxOperator(true);
        }

        if (_protocol == SavingsProtocol.Aave) {
            ERC20(A_DAI_ADDRESS).approve(getAddress(_protocol), uint256(-1));
        }
    }

    function setDydxOperator(bool _trusted) internal {

            ISoloMargin.OperatorArg[] memory operatorArgs
         = new ISoloMargin.OperatorArg[](1);
        operatorArgs[0] = ISoloMargin.OperatorArg({
            operator: getAddress(SavingsProtocol.Dydx),
            trusted: _trusted
        });

        ISoloMargin(SOLO_MARGIN_ADDRESS).setOperators(operatorArgs);
    }
}
