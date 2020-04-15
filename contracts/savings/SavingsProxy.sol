pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./ProtocolInterface.sol";
import "../interfaces/ERC20.sol";
import "../interfaces/ITokenInterface.sol";
import "../constants/ConstantAddresses.sol";
import "./dydx/ISoloMargin.sol";


//import "./SavingsLogger.sol";

//import "./dsr/DSRSavingsProtocol.sol";

contract SavingsProxy is ConstantAddresses {
    address public constant SAVINGS_COMPOUND_ADDRESS = 0x15E9Fd390e0619dEf294d4C23DbAc69608203DB6;
    address public constant SAVINGS_DYDX_ADDRESS = 0x0A103DB1C6e91edE7cD20D83f2a6D7960E587a9F;

    enum SavingsProtocol {Compound, Dydx, Fulcrum, Dsr}

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
        ERC20(SAI_ADDRESS).transfer(
            msg.sender,
            ERC20(SAI_ADDRESS).balanceOf(address(this))
        );
    }

    function getAddress(SavingsProtocol _protocol)
        public
        pure
        returns (address)
    {
        if (_protocol == SavingsProtocol.Compound) {
            return SAVINGS_COMPOUND_ADDRESS;
        }

        if (_protocol == SavingsProtocol.Dydx) {
            return SAVINGS_DYDX_ADDRESS;
        }
    }

    function _deposit(
        SavingsProtocol _protocol,
        uint256 _amount,
        bool _fromUser
    ) internal {
        if (_fromUser) {
            ERC20(SAI_ADDRESS).transferFrom(msg.sender, address(this), _amount);
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
    }

    function approveWithdraw(SavingsProtocol _protocol) internal {
        if (_protocol == SavingsProtocol.Compound) {
            ERC20(NEW_CDAI_ADDRESS).approve(getAddress(_protocol), uint256(-1));
        }

        if (_protocol == SavingsProtocol.Dydx) {
            setDydxOperator(true);
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
