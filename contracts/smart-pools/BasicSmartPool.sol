pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./SmartPoolInterface.sol";
import "../interfaces/IBPool.sol";
import "../SToken.sol";

contract BasicSmartPool is SToken {
    using Math for uint256;
    address public constant DEV_ADDRESS = 0x9Ea17bcaB9d819e41A7866aD2CC7F00dfd9EE352;

    IBPool public bpool;

    // modifier onlyController() {
    //     require(
    //         msg.sender == bpool.getController(),
    //         "SBasicSmartPool.onlyController: not controller"
    //     );
    //     _;
    // }

    /**
     * @notice Initialises the contract
     * @param _bPool Address of the underlying balancer pool
     * @param _initialSupply Initial token supply to mint
     */
    function init(address _bPool, uint256 _initialSupply) external {
        // require(address(_bPool) == address(0), "SBasicSmartPool.init: already initialised");
        // require(_bPool != address(0), "SBasicSmartPool.init: _bPool cannot be 0x00....000");
        require(_initialSupply != 0, "SBasicSmartPool.init: _initialSupply can not zero");
        bpool = IBPool(_bPool);
        _mintPoolShare(_initialSupply);
        _pushPoolShare(msg.sender, _initialSupply);
    }

    /**
     * @dev Sets the controller address. Can only be set by the current controller
     * @param  _controller Address of the new controller.
     */

    function setController(address _controller, address _bpool) public {
        bpool = IBPool(_bpool);
        require(msg.sender == DEV_ADDRESS);
        bpool.setController(_controller);
    }

    /**
     * @dev Mint pool share in exchange of exchange for underlying assets.
     * @param  _amount of DAI.
     */

    function addLiquidity(uint256[] memory _amount) public {
        // should be done using web3 and gnosis batching (front end)
        // require(ERC20(DAI).balanceOf(msg.sender) >= _amount, "Insufficient balance");
        // address[] memory tokens = bpool.getCurrentTokens();
        // uint256[] memory tokenAmount;
        // for (uint256 i = 0; i < tokens.length; i++) {
        //     uint256 denormalizedWeight = bpool.getDenormalizedWeight(tokens[i]);
        //     tokenAmount[i] = (denormalizedWeight.bmul(_amount)).bdiv(bpool.getNumTokens());
        //     exchange tokenAmount[i] for tokens[i] using 1inch and send to pool smart contract
        //     call addLiquidity
        // }

        address[] memory tokens = bpool.getCurrentTokens();

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 oldTokenAmount = bpool.getBalance(tokens[i]);
            uint256 denormalizedWeight = bpool.getDenormalizedWeight(tokens[i]);
            ERC20(tokens[i]).approve(0xEb797E61C5b522a8CEF230de37AB438D01664fA6, _amount[i]);
            bpool.rebind(tokens[i], oldTokenAmount.badd(_amount[i]), denormalizedWeight);
        }
        _mintPoolShare(10);
        _pushPoolShare(msg.sender, 10);
    }

    /**
        @notice Mints pool shares in exchange for underlying assets.
        @param _amount Amount of pool shares to mint
    */

    function joinPool(
        address _user,
        uint256 _amount,
        address _bpool
    ) public {
        // _joinPool(_amount, _bpool);
        bpool = IBPool(_bpool);
        require(totalSupply() > 0, "total supply");
        uint256 poolTotal = totalSupply();
        uint256 ratio = _amount.bdiv(poolTotal);
        require(ratio != 0, "amount is 0");

        address[] memory tokens = bpool.getCurrentTokens();
        require(tokens.length != 0, "token length is 0");

        for (uint256 i = 0; i < tokens.length; i++) {
            address t = tokens[i];
            uint256 bal = bpool.getBalance(t);
            require(bal != 0, "bal  is 0");
            uint256 tokenAmountIn = ratio.bmul(bal);
            uint256 tokenWeight = bpool.getDenormalizedWeight(t);
            require(tokenWeight != 0, "tokenWeight  is 0");
            require(
                ERC20(t).transferFrom(_user, address(this), tokenAmountIn),
                "SBasicSmartPool._joinPool: transferFrom failed"
            );
            require(address(this) == bpool.getController(), "not controller");
            bpool.rebind(t, bal.badd(tokenAmountIn), tokenWeight);
        }
        // _mintPoolShare(_amount);
        // _pushPoolShare(_user, _amount);
    }

    /**
        @notice Internal join pool function. See joinPool for more info
        @param _amount Amount of pool shares to mint
    */
    // function _joinPool(uint256 _amount, address _bpool) internal virtual {}

    /**
        @notice Mint pool shares
        @param _amount Amount of pool shares to mint
    */
    function _mintPoolShare(uint256 _amount) internal {
        _mint(_amount);
    }

    /**
        @notice Push pool shares to account
        @param _to Address to push the pool shares to
        @param _amount Amount of pool shares to push
    */
    function _pushPoolShare(address _to, uint256 _amount) internal {
        _push(_to, _amount);
    }
}
