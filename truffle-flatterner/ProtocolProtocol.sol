// File: contracts/Lend/ProtocolInterface.sol

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;

abstract contract ProtocolInterface {
    function deposit(
        address _user,
        uint256 _amount,
        address _token,
        address _cToken
    ) public virtual;

    function withdraw(
        address _user,
        uint256 _amount,
        address _token,
        address _cToken
    ) public virtual;
}

// File: contracts/interfaces/ERC20.sol

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;

interface ERC20 {
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _src, address indexed _dst, uint256 _amount);
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    // function decimals() external view returns (uint256 digits);

   
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/Lend/dydx/lib/Require.sol

/*

    Copyright 2019 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;


/**
 * @title Require
 * @author dYdX
 *
 * Stringifies parameters to pretty-print revert messages. Costs more gas than regular require()
 */
library Require {
    // ============ Constants ============

    uint256 constant ASCII_ZERO = 48; // '0'
    uint256 constant ASCII_RELATIVE_ZERO = 87; // 'a' - 10
    uint256 constant ASCII_LOWER_EX = 120; // 'x'
    bytes2 constant COLON = 0x3a20; // ': '
    bytes2 constant COMMA = 0x2c20; // ', '
    bytes2 constant LPAREN = 0x203c; // ' <'
    bytes1 constant RPAREN = 0x3e; // '>'
    uint256 constant FOUR_BIT_MASK = 0xf;

    // ============ Library Functions ============

    function that(
        bool must,
        bytes32 file,
        bytes32 reason
    ) internal pure {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason)
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        uint256 payloadA
    ) internal pure {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        uint256 payloadA,
        uint256 payloadB
    ) internal pure {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA
    ) internal pure {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA,
        uint256 payloadB
    ) internal pure {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA,
        uint256 payloadB,
        uint256 payloadC
    ) internal pure {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bytes32 payloadA
    ) internal pure {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bytes32 payloadA,
        uint256 payloadB,
        uint256 payloadC
    ) internal pure {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        RPAREN
                    )
                )
            );
        }
    }

    // ============ Private Functions ============

    function stringifyTruncated(bytes32 input)
        private
        pure
        returns (bytes memory)
    {
        // put the input bytes into the result
        bytes memory result = abi.encodePacked(input);

        // determine the length of the input by finding the location of the last non-zero byte
        for (uint256 i = 32; i > 0; ) {
            // reverse-for-loops with unsigned integer
            /* solium-disable-next-line security/no-modify-for-iter-var */
            i--;

            // find the last non-zero byte in order to determine the length
            if (result[i] != 0) {
                uint256 length = i + 1;

                /* solium-disable-next-line security/no-inline-assembly */
                assembly {
                    mstore(result, length) // r.length = length;
                }

                return result;
            }
        }

        // all bytes are zero
        return new bytes(0);
    }

    function stringify(uint256 input) private pure returns (bytes memory) {
        if (input == 0) {
            return "0";
        }

        // get the final string length
        uint256 j = input;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }

        // allocate the string
        bytes memory bstr = new bytes(length);

        // populate the string starting with the least-significant character
        j = input;
        for (uint256 i = length; i > 0; ) {
            // reverse-for-loops with unsigned integer
            /* solium-disable-next-line security/no-modify-for-iter-var */
            i--;

            // take last decimal digit
            bstr[i] = bytes1(uint8(ASCII_ZERO + (j % 10)));

            // remove the last decimal digit
            j /= 10;
        }

        return bstr;
    }

    function stringify(address input) private pure returns (bytes memory) {
        uint256 z = uint256(input);

        // addresses are "0x" followed by 20 bytes of data which take up 2 characters each
        bytes memory result = new bytes(42);

        // populate the result with "0x"
        result[0] = bytes1(uint8(ASCII_ZERO));
        result[1] = bytes1(uint8(ASCII_LOWER_EX));

        // for each byte (starting from the lowest byte), populate the result with two characters
        for (uint256 i = 0; i < 20; i++) {
            // each byte takes two characters
            uint256 shift = i * 2;

            // populate the least-significant character
            result[41 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;

            // populate the most-significant character
            result[40 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;
        }

        return result;
    }

    function stringify(bytes32 input) private pure returns (bytes memory) {
        uint256 z = uint256(input);

        // bytes32 are "0x" followed by 32 bytes of data which take up 2 characters each
        bytes memory result = new bytes(66);

        // populate the result with "0x"
        result[0] = bytes1(uint8(ASCII_ZERO));
        result[1] = bytes1(uint8(ASCII_LOWER_EX));

        // for each byte (starting from the lowest byte), populate the result with two characters
        for (uint256 i = 0; i < 32; i++) {
            // each byte takes two characters
            uint256 shift = i * 2;

            // populate the least-significant character
            result[65 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;

            // populate the most-significant character
            result[64 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;
        }

        return result;
    }

    function char(uint256 input) private pure returns (bytes1) {
        // return ASCII digit (0-9)
        if (input < 10) {
            return bytes1(uint8(input + ASCII_ZERO));
        }

        // return ASCII letter (a-f)
        return bytes1(uint8(input + ASCII_RELATIVE_ZERO));
    }
}

// File: contracts/Lend/dydx/lib/Math.sol

/*

    Copyright 2019 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;




/**
 * @title Math
 * @author dYdX
 *
 * Library for non-standard Math functions
 */
library Math {
    using SafeMath for uint256;

    // ============ Constants ============

    bytes32 constant FILE = "Math";

    // ============ Library Functions ============

    /*
     * Return target * (numerator / denominator).
     */
    function getPartial(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    ) internal pure returns (uint256) {
        return target.mul(numerator).div(denominator);
    }

    /*
     * Return target * (numerator / denominator), but rounded up.
     */
    function getPartialRoundUp(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    ) internal pure returns (uint256) {
        if (target == 0 || numerator == 0) {
            // SafeMath will check for zero denominator
            return SafeMath.div(0, denominator);
        }
        return target.mul(numerator).sub(1).div(denominator).add(1);
    }

    function to128(uint256 number) internal pure returns (uint128) {
        uint128 result = uint128(number);
        Require.that(result == number, FILE, "Unsafe cast to uint128");
        return result;
    }

    function to96(uint256 number) internal pure returns (uint96) {
        uint96 result = uint96(number);
        Require.that(result == number, FILE, "Unsafe cast to uint96");
        return result;
    }

    function to32(uint256 number) internal pure returns (uint32) {
        uint32 result = uint32(number);
        Require.that(result == number, FILE, "Unsafe cast to uint32");
        return result;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
}

// File: contracts/Lend/dydx/lib/Types.sol

/*

    Copyright 2019 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;




/**
 * @title Types
 * @author dYdX
 *
 * Library for interacting with the basic structs used in Solo
 */
library Types {
    using Math for uint256;

    // ============ AssetAmount ============

    enum AssetDenomination {
        Wei, // the amount is denominated in wei
        Par // the amount is denominated in par
    }

    enum AssetReference {
        Delta, // the amount is given as a delta from the current value
        Target // the amount is given as an exact number to end up at
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    // ============ Par (Principal Amount) ============

    // Total borrow and supply values for a market
    struct TotalPar {
        uint128 borrow;
        uint128 supply;
    }

    // Individual principal amount for an account
    struct Par {
        bool sign; // true if positive
        uint128 value;
    }

    function zeroPar() internal pure returns (Par memory) {
        return Par({sign: false, value: 0});
    }

    function sub(Par memory a, Par memory b)
        internal
        pure
        returns (Par memory)
    {
        return add(a, negative(b));
    }

    function add(Par memory a, Par memory b)
        internal
        pure
        returns (Par memory)
    {
        Par memory result;
        if (a.sign == b.sign) {
            result.sign = a.sign;
            result.value = SafeMath.add(a.value, b.value).to128();
        } else {
            if (a.value >= b.value) {
                result.sign = a.sign;
                result.value = SafeMath.sub(a.value, b.value).to128();
            } else {
                result.sign = b.sign;
                result.value = SafeMath.sub(b.value, a.value).to128();
            }
        }
        return result;
    }

    function equals(Par memory a, Par memory b) internal pure returns (bool) {
        if (a.value == b.value) {
            if (a.value == 0) {
                return true;
            }
            return a.sign == b.sign;
        }
        return false;
    }

    function negative(Par memory a) internal pure returns (Par memory) {
        return Par({sign: !a.sign, value: a.value});
    }

    function isNegative(Par memory a) internal pure returns (bool) {
        return !a.sign && a.value > 0;
    }

    function isPositive(Par memory a) internal pure returns (bool) {
        return a.sign && a.value > 0;
    }

    function isZero(Par memory a) internal pure returns (bool) {
        return a.value == 0;
    }

    // ============ Wei (Token Amount) ============

    // Individual token amount for an account
    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }

    function zeroWei() internal pure returns (Wei memory) {
        return Wei({sign: false, value: 0});
    }

    function sub(Wei memory a, Wei memory b)
        internal
        pure
        returns (Wei memory)
    {
        return add(a, negative(b));
    }

    function add(Wei memory a, Wei memory b)
        internal
        pure
        returns (Wei memory)
    {
        Wei memory result;
        if (a.sign == b.sign) {
            result.sign = a.sign;
            result.value = SafeMath.add(a.value, b.value);
        } else {
            if (a.value >= b.value) {
                result.sign = a.sign;
                result.value = SafeMath.sub(a.value, b.value);
            } else {
                result.sign = b.sign;
                result.value = SafeMath.sub(b.value, a.value);
            }
        }
        return result;
    }

    function equals(Wei memory a, Wei memory b) internal pure returns (bool) {
        if (a.value == b.value) {
            if (a.value == 0) {
                return true;
            }
            return a.sign == b.sign;
        }
        return false;
    }

    function negative(Wei memory a) internal pure returns (Wei memory) {
        return Wei({sign: !a.sign, value: a.value});
    }

    function isNegative(Wei memory a) internal pure returns (bool) {
        return !a.sign && a.value > 0;
    }

    function isPositive(Wei memory a) internal pure returns (bool) {
        return a.sign && a.value > 0;
    }

    function isZero(Wei memory a) internal pure returns (bool) {
        return a.value == 0;
    }
}

// File: contracts/Lend/dydx/lib/Account.sol

/*

    Copyright 2019 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;



/**
 * @title Account
 * @author dYdX
 *
 * Library of structs and functions that represent an account
 */
library Account {
    // ============ Enums ============

    /*
     * Most-recently-cached account status.
     *
     * Normal: Can only be liquidated if the account values are violating the global margin-ratio.
     * Liquid: Can be liquidated no matter the account values.
     *         Can be vaporized if there are no more positive account values.
     * Vapor:  Has only negative (or zeroed) account values. Can be vaporized.
     *
     */
    enum Status {Normal, Liquid, Vapor}

    // ============ Structs ============

    // Represents the unique key that specifies an account
    struct Info {
        address owner; // The address that owns the account
        uint256 number; // A nonce that allows a single address to control many accounts
    }

    // The complete storage for any account
    struct Storage {
        mapping(uint256 => Types.Par) balances; // Mapping from marketId to principal
        Status status;
    }

    // ============ Library Functions ============

    function equals(Info memory a, Info memory b) internal pure returns (bool) {
        return a.owner == b.owner && a.number == b.number;
    }
}

// File: contracts/Lend/dydx/lib/Actions.sol

/*

    Copyright 2019 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;




/**
 * @title Actions
 * @author dYdX
 *
 * Library that defines and parses valid Actions
 */
library Actions {
    // ============ Constants ============

    bytes32 constant FILE = "Actions";

    // ============ Enums ============

    enum ActionType {
        Deposit, // supply tokens
        Withdraw, // borrow tokens
        Transfer, // transfer balance between accounts
        Buy, // buy an amount of some token (externally)
        Sell, // sell an amount of some token (externally)
        Trade, // trade tokens against another account
        Liquidate, // liquidate an undercollateralized or expiring account
        Vaporize, // use excess tokens to zero-out a completely negative account
        Call // send arbitrary data to an address
    }

    enum AccountLayout {OnePrimary, TwoPrimary, PrimaryAndSecondary}

    enum MarketLayout {ZeroMarkets, OneMarket, TwoMarkets}

    // ============ Structs ============

    /*
     * Arguments that are passed to Solo in an ordered list as part of a single operation.
     * Each ActionArgs has an actionType which specifies which action struct that this data will be
     * parsed into before being processed.
     */
    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        Types.AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    // ============ Action Types ============

    /*
     * Moves tokens from an address to Solo. Can either repay a borrow or provide additional supply.
     */
    struct DepositArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 market;
        address from;
    }

    /*
     * Moves tokens from Solo to another address. Can either borrow tokens or reduce the amount
     * previously supplied.
     */
    struct WithdrawArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 market;
        address to;
    }

    /*
     * Transfers balance between two accounts. The msg.sender must be an operator for both accounts.
     * The amount field applies to accountOne.
     * This action does not require any token movement since the trade is done internally to Solo.
     */
    struct TransferArgs {
        Types.AssetAmount amount;
        Account.Info accountOne;
        Account.Info accountTwo;
        uint256 market;
    }

    /*
     * Acquires a certain amount of tokens by spending other tokens. Sends takerMarket tokens to the
     * specified exchangeWrapper contract and expects makerMarket tokens in return. The amount field
     * applies to the makerMarket.
     */
    struct BuyArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 makerMarket;
        uint256 takerMarket;
        address exchangeWrapper;
        bytes orderData;
    }

    /*
     * Spends a certain amount of tokens to acquire other tokens. Sends takerMarket tokens to the
     * specified exchangeWrapper and expects makerMarket tokens in return. The amount field applies
     * to the takerMarket.
     */
    struct SellArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 takerMarket;
        uint256 makerMarket;
        address exchangeWrapper;
        bytes orderData;
    }

    /*
     * Trades balances between two accounts using any external contract that implements the
     * AutoTrader interface. The AutoTrader contract must be an operator for the makerAccount (for
     * which it is trading on-behalf-of). The amount field applies to the makerAccount and the
     * inputMarket. This proposed change to the makerAccount is passed to the AutoTrader which will
     * quote a change for the makerAccount in the outputMarket (or will disallow the trade).
     * This action does not require any token movement since the trade is done internally to Solo.
     */
    struct TradeArgs {
        Types.AssetAmount amount;
        Account.Info takerAccount;
        Account.Info makerAccount;
        uint256 inputMarket;
        uint256 outputMarket;
        address autoTrader;
        bytes tradeData;
    }

    /*
     * Each account must maintain a certain margin-ratio (specified globally). If the account falls
     * below this margin-ratio, it can be liquidated by any other account. This allows anyone else
     * (arbitrageurs) to repay any borrowed asset (owedMarket) of the liquidating account in
     * exchange for any collateral asset (heldMarket) of the liquidAccount. The ratio is determined
     * by the price ratio (given by the oracles) plus a spread (specified globally). Liquidating an
     * account also sets a flag on the account that the account is being liquidated. This allows
     * anyone to continue liquidating the account until there are no more borrows being taken by the
     * liquidating account. Liquidators do not have to liquidate the entire account all at once but
     * can liquidate as much as they choose. The liquidating flag allows liquidators to continue
     * liquidating the account even if it becomes collateralized through partial liquidation or
     * price movement.
     */
    struct LiquidateArgs {
        Types.AssetAmount amount;
        Account.Info solidAccount;
        Account.Info liquidAccount;
        uint256 owedMarket;
        uint256 heldMarket;
    }

    /*
     * Similar to liquidate, but vaporAccounts are accounts that have only negative balances
     * remaining. The arbitrageur pays back the negative asset (owedMarket) of the vaporAccount in
     * exchange for a collateral asset (heldMarket) at a favorable spread. However, since the
     * liquidAccount has no collateral assets, the collateral must come from Solo's excess tokens.
     */
    struct VaporizeArgs {
        Types.AssetAmount amount;
        Account.Info solidAccount;
        Account.Info vaporAccount;
        uint256 owedMarket;
        uint256 heldMarket;
    }

    /*
     * Passes arbitrary bytes of data to an external contract that implements the Callee interface.
     * Does not change any asset amounts. This function may be useful for setting certain variables
     * on layer-two contracts for certain accounts without having to make a separate Ethereum
     * transaction for doing so. Also, the second-layer contracts can ensure that the call is coming
     * from an operator of the particular account.
     */
    struct CallArgs {
        Account.Info account;
        address callee;
        bytes data;
    }

    // ============ Helper Functions ============

    function getMarketLayout(ActionType actionType)
        internal
        pure
        returns (MarketLayout)
    {
        if (
            actionType == Actions.ActionType.Deposit ||
            actionType == Actions.ActionType.Withdraw ||
            actionType == Actions.ActionType.Transfer
        ) {
            return MarketLayout.OneMarket;
        } else if (actionType == Actions.ActionType.Call) {
            return MarketLayout.ZeroMarkets;
        }
        return MarketLayout.TwoMarkets;
    }

    function getAccountLayout(ActionType actionType)
        internal
        pure
        returns (AccountLayout)
    {
        if (
            actionType == Actions.ActionType.Transfer ||
            actionType == Actions.ActionType.Trade
        ) {
            return AccountLayout.TwoPrimary;
        } else if (
            actionType == Actions.ActionType.Liquidate ||
            actionType == Actions.ActionType.Vaporize
        ) {
            return AccountLayout.PrimaryAndSecondary;
        }
        return AccountLayout.OnePrimary;
    }

    // ============ Parsing Functions ============

    function parseDepositArgs(
        Account.Info[] memory accounts,
        ActionArgs memory args
    ) internal pure returns (DepositArgs memory) {
        assert(args.actionType == ActionType.Deposit);
        return
            DepositArgs({
                amount: args.amount,
                account: accounts[args.accountId],
                market: args.primaryMarketId,
                from: args.otherAddress
            });
    }

    function parseWithdrawArgs(
        Account.Info[] memory accounts,
        ActionArgs memory args
    ) internal pure returns (WithdrawArgs memory) {
        assert(args.actionType == ActionType.Withdraw);
        return
            WithdrawArgs({
                amount: args.amount,
                account: accounts[args.accountId],
                market: args.primaryMarketId,
                to: args.otherAddress
            });
    }

    function parseTransferArgs(
        Account.Info[] memory accounts,
        ActionArgs memory args
    ) internal pure returns (TransferArgs memory) {
        assert(args.actionType == ActionType.Transfer);
        return
            TransferArgs({
                amount: args.amount,
                accountOne: accounts[args.accountId],
                accountTwo: accounts[args.otherAccountId],
                market: args.primaryMarketId
            });
    }

    function parseBuyArgs(
        Account.Info[] memory accounts,
        ActionArgs memory args
    ) internal pure returns (BuyArgs memory) {
        assert(args.actionType == ActionType.Buy);
        return
            BuyArgs({
                amount: args.amount,
                account: accounts[args.accountId],
                makerMarket: args.primaryMarketId,
                takerMarket: args.secondaryMarketId,
                exchangeWrapper: args.otherAddress,
                orderData: args.data
            });
    }

    function parseSellArgs(
        Account.Info[] memory accounts,
        ActionArgs memory args
    ) internal pure returns (SellArgs memory) {
        assert(args.actionType == ActionType.Sell);
        return
            SellArgs({
                amount: args.amount,
                account: accounts[args.accountId],
                takerMarket: args.primaryMarketId,
                makerMarket: args.secondaryMarketId,
                exchangeWrapper: args.otherAddress,
                orderData: args.data
            });
    }

    function parseTradeArgs(
        Account.Info[] memory accounts,
        ActionArgs memory args
    ) internal pure returns (TradeArgs memory) {
        assert(args.actionType == ActionType.Trade);
        return
            TradeArgs({
                amount: args.amount,
                takerAccount: accounts[args.accountId],
                makerAccount: accounts[args.otherAccountId],
                inputMarket: args.primaryMarketId,
                outputMarket: args.secondaryMarketId,
                autoTrader: args.otherAddress,
                tradeData: args.data
            });
    }

    function parseLiquidateArgs(
        Account.Info[] memory accounts,
        ActionArgs memory args
    ) internal pure returns (LiquidateArgs memory) {
        assert(args.actionType == ActionType.Liquidate);
        return
            LiquidateArgs({
                amount: args.amount,
                solidAccount: accounts[args.accountId],
                liquidAccount: accounts[args.otherAccountId],
                owedMarket: args.primaryMarketId,
                heldMarket: args.secondaryMarketId
            });
    }

    function parseVaporizeArgs(
        Account.Info[] memory accounts,
        ActionArgs memory args
    ) internal pure returns (VaporizeArgs memory) {
        assert(args.actionType == ActionType.Vaporize);
        return
            VaporizeArgs({
                amount: args.amount,
                solidAccount: accounts[args.accountId],
                vaporAccount: accounts[args.otherAccountId],
                owedMarket: args.primaryMarketId,
                heldMarket: args.secondaryMarketId
            });
    }

    function parseCallArgs(
        Account.Info[] memory accounts,
        ActionArgs memory args
    ) internal pure returns (CallArgs memory) {
        assert(args.actionType == ActionType.Call);
        return
            CallArgs({
                account: accounts[args.accountId],
                callee: args.otherAddress,
                data: args.data
            });
    }
}

// File: contracts/Lend/dydx/ISoloMargin.sol

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;




abstract contract ISoloMargin {
    struct OperatorArg {
        address operator;
        bool trusted;
    }

    function operate(Account.Info[] memory accounts, Actions.ActionArgs[] memory actions)
        public
        virtual;

    function getAccountBalances(Account.Info memory account)
        public
        virtual
        view
        returns (
            address[] memory,
            Types.Par[] memory,
            Types.Wei[] memory
        );

    function setOperators(OperatorArg[] memory args) public virtual;
}

// File: contracts/Lend/Logger.sol

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;

contract Logger {
    event Deposit(
        address indexed sender,
        uint8 protocol,
        uint8 coin,
        uint256 amount,
        uint256 timestamp
    );
    event Withdraw(
        address indexed sender,
        uint8 protocol,
        uint8 coin,
        uint256 amount,
        uint256 timestamp
    );
    event Swap(address indexed sender, uint8 fromProtocol, uint8 toProtocol, uint256 amount);

    function logDeposit(
        address _sender,
        uint8 _protocol,
        uint8 _coin,
        uint256 _amount,
        uint256 _timestamp
    ) external {
        emit Deposit(_sender, _protocol, _coin, _amount, _timestamp);
    }

    function logWithdraw(
        address _sender,
        uint8 _protocol,
        uint8 _coin,
        uint256 _amount,
        uint256 _timestamp
    ) external {
        emit Withdraw(_sender, _protocol, _coin, _amount, _timestamp);
    }

    function logSwap(
        address _sender,
        uint8 _protocolFrom,
        uint8 _protocolTo,
        uint256 _amount
    ) external {
        emit Swap(_sender, _protocolFrom, _protocolTo, _amount);
    }
}

// File: contracts/constants/ConstantAddressesMainnet.sol

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;

contract ConstantAddressesMainnet {
    // mainnet
    address public constant LOGGER_ADDRESS = 0x0d64909AAc6Fc1B39184100c7D07adbD4AD6B905;
    address public constant SAVINGS_COMPOUND_ADDRESS = 0x350ae46a6FDC97A27c1B0A00fDB24637A6ff1a3B;
    address public constant SAVINGS_DYDX_ADDRESS = 0x2a4D374aaBBC6A1c45FDf022B9eC4Fe4492C1EEB;
    address public constant SAVINGS_AAVE_ADDRESS = 0x72b2f78b9EeCf740d7Bf81AeaB315e48BAfEC994;
    // constant mainnet
    address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant ADAI_ADDRESS = 0xfC1E690f61EFd961294b3e1Ce3313fBD8aa4f85d;
    address public constant CDAI_ADDRESS = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant CUSDC_ADDRESS = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;
    address public constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant CUSDT_ADDRESS = 0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9;

    address public constant SOLO_MARGIN_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address public constant COMPTROLLER_ADDRESS = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    address public constant COMP_ADDRESS = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
}

// File: contracts/constants/ConstantAddressesKovan.sol

pragma solidity >=0.6.0;

contract ConstantAddressesKovan {
    //Rinkeby
    // address public constant DAI_ADDRESS = 0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa;
    // address public constant SAVINGS_COMPOUND_ADDRESS = 0x21182Be016C37B0CFD70Bf4Fbbe8B983c365D60E;

    //kovan
    address public constant LOGGER_ADDRESS = 0x43fD99B873D48bf1845B3CD073fA53CA3eaAec56;
    address public constant SAVINGS_COMPOUND_ADDRESS = 0x83021914EcFaB9c1358c62aaa340644aBB372f84;
    address public constant SAVINGS_DYDX_ADDRESS = 0x2633bc318639DEb4504B9a3577384412140c8046;
    address public constant SAVINGS_AAVE_ADDRESS = 0x7604973aeDB53cC5b4b491A01D96a0ce5E3Ac9D6;

    // aave
    address public constant AAVE_DAI_ADDRESS = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    address public constant ADAI_ADDRESS = 0x58AD4cB396411B691A9AAb6F74545b2C5217FE6a;
    address public constant AAVE_USDC_ADDRESS = 0xe22da380ee6B445bb8273C81944ADEB6E8450422;
    address public constant AAVE_AUSDC_ADDRESS = 0x02F626c6ccb6D2ebC071c068DC1f02Bf5693416a;
    address public constant AAVE_USDT_ADDRESS = 0x13512979ADE267AB5100878E2e0f485B568328a4;
    address public constant AAVE_AUSDT_ADDRESS = 0xA01bA9fB493b851F4Ac5093A324CB081A909C34B;
    //dydx
    address public constant SOLO_MARGIN_ADDRESS = 0x4EC3570cADaAEE08Ae384779B0f3A45EF85289DE;
    address public constant SAI_ADDRESS = 0xC4375B7De8af5a38a93548eb8453a498222C4fF2;

    //Compound
    address public constant COMPTROLLER_ADDRESS = 0x5eAe89DC1C671724A672ff0630122ee834098657;
    address public constant COMP_ADDRESS = 0x61460874a7196d6a22D1eE4922473664b3E95270;
    address public constant DAI_ADDRESS = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    address public constant CDAI_ADDRESS = 0xF0d0EB522cfa50B716B3b1604C4F0fA6f04376AD;
    address public constant USDC_ADDRESS = 0xb7a4F3E9097C08dA09517b5aB877F7a917224ede;
    address public constant CUSDC_ADDRESS = 0x4a92E71227D294F041BD82dd8f78591B75140d63;
    address public constant USDT_ADDRESS = 0x07de306FF27a2B630B1141956844eB1552B956B5;
    address public constant CUSDT_ADDRESS = 0x3f0A0EA2f86baE6362CF9799B523BA06647Da018;
}

// File: contracts/constants/ConstantAddresses.sol

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;



contract ConstantAddresses is ConstantAddressesMainnet {}

// File: contracts/Lend/ProtocolProxy.sol

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;






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
