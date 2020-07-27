// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./ProtocolInterface.sol";
import "../interfaces/ERC20.sol";
import "./dydx/ISoloMargin.sol";
import "./Logger.sol";

//import "../interfaces/ComptrollerInterface.sol";

contract ProtocolProxy {
    //Rinkeby
    // address public constant DAI_ADDRESS = 0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa;
    // address public constant SAVINGS_COMPOUND_ADDRESS = 0x21182Be016C37B0CFD70Bf4Fbbe8B983c365D60E;

    //kovan
    address public constant LOGGER_ADDRESS = 0x43fD99B873D48bf1845B3CD073fA53CA3eaAec56;
    address public constant SAVINGS_COMPOUND_ADDRESS = 0xE3BB7Ef3f303208D2cd20207Bac69A8249C0d9E1;
    address public constant SAVINGS_DYDX_ADDRESS = 0xe73cC32bc17C58870701AD744eA4Ccf459ec9012;
    address public constant SAVINGS_AAVE_ADDRESS = 0x3C7717Ab97a85cFbf4eFce8eee8B1E218f8F3610;
    //constant kovan
    address public constant DAI_ADDRESS = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    address public constant SAI_ADDRESS = 0xC4375B7De8af5a38a93548eb8453a498222C4fF2;
    address public constant AAVE_DAI_ADDRESS = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    address public constant ADAI_ADDRESS = 0x58AD4cB396411B691A9AAb6F74545b2C5217FE6a;
    address public constant CDAI_ADDRESS = 0xF0d0EB522cfa50B716B3b1604C4F0fA6f04376AD;
    address public constant SOLO_MARGIN_ADDRESS = 0x4EC3570cADaAEE08Ae384779B0f3A45EF85289DE;
    address public constant COMPTROLLER_ADDRESS = 0x5eAe89DC1C671724A672ff0630122ee834098657;
    address public constant COMP_ADDRESS = 0x61460874a7196d6a22D1eE4922473664b3E95270;

    address public constant USDC_ADDRESS = 0xb7a4F3E9097C08dA09517b5aB877F7a917224ede;
    address public constant CUSDC_ADDRESS = 0x4a92E71227D294F041BD82dd8f78591B75140d63;
    address public constant USDT_ADDRESS = 0x07de306FF27a2B630B1141956844eB1552B956B5;
    address public constant CUSDT_ADDRESS = 0x3f0A0EA2f86baE6362CF9799B523BA06647Da018;

    // // mainnet
    // address public constant LOGGER_ADDRESS = 0xD943C08D37949dB925081D93B47bDa6c9F72BD1c;
    // address public constant SAVINGS_COMPOUND_ADDRESS = 0x3106eBb845e3334DabeA07e1392F108bAAFDee57;
    // address public constant SAVINGS_DYDX_ADDRESS = 0xE68c1032946F0BDe02A0A29E09B11a26B00Bae8c;
    // address public constant SAVINGS_AAVE_ADDRESS = 0x6f9A0508217ef535730c20fB159BF9a982E668ab;

    // // constant mainnet
    // address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // address public constant ADAI_ADDRESS = 0xfC1E690f61EFd961294b3e1Ce3313fBD8aa4f85d;
    // address public constant CDAI_ADDRESS = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    // address public constant SOLO_MARGIN_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    // address public constant COMPTROLLER_ADDRESS = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    // address public constant COMP_ADDRESS = 0xc00e94Cb662C3520282E6f5717214004A7f26888;

    enum SavingsProtocol {Compound, Dydx, Aave}

    enum SavingsToken {DAI, USDC, USDT}

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

    function getTokenAddress(SavingsToken _coin) public pure returns (address, address) {
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

    function _deposit(
        SavingsProtocol _protocol,
        SavingsToken _coin,
        uint256 _amount
    ) internal {
        (address TOKEN, address CTOKEN) = getTokenAddress(_coin);
        approveDeposit(_protocol, _coin);
        ProtocolInterface(getAddress(_protocol)).deposit(address(this), _amount, TOKEN, CTOKEN);
        endAction(_protocol);
    }

    function _withdraw(
        SavingsProtocol _protocol,
        SavingsToken _coin,
        uint256 _amount
    ) public {
        (address TOKEN, address CTOKEN) = getTokenAddress(_coin);
        approveWithdraw(_protocol, _coin);

        ProtocolInterface(getAddress(_protocol)).withdraw(address(this), _amount, TOKEN, CTOKEN);

        endAction(_protocol);
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
        (address TOKEN, ) = getTokenAddress(_coin);
        if (_protocol == SavingsProtocol.Compound) {
            ERC20(TOKEN).approve(getAddress(_protocol), uint256(-1));
        }

        if (_protocol == SavingsProtocol.Dydx) {
            ERC20(SAI_ADDRESS).approve(SOLO_MARGIN_ADDRESS, uint256(-1));
            setDydxOperator(true);
        }

        if (_protocol == SavingsProtocol.Aave) {
            ERC20(AAVE_DAI_ADDRESS).approve(getAddress(_protocol), uint256(-1));
        }
    }

    function approveWithdraw(SavingsProtocol _protocol, SavingsToken _coin) internal {
        (, address CTOKEN) = getTokenAddress(_coin);
        if (_protocol == SavingsProtocol.Compound) {
            ERC20(CTOKEN).approve(getAddress(_protocol), uint256(-1));
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
}
