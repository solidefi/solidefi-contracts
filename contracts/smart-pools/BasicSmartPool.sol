// pragma solidity >=0.6.0;

// import "../interfaces/IBPool.sol";
// import "../interfaces/ERC20.sol";
// import "../Math.sol";
// import "../SToken.sol";
// import "../ReentryProtection.sol";

// abstract contract BasicSmartPool is SToken, ReentryProtection {
//     using Math for uint256;

//     // Solidefi Basic Smart Struct
//     bytes32 public constant sbsSlot = keccak256("SBasicSmartPool.storage.location");
//     struct sbs {
//         IBPool bPool;
//         address controller;
//     }
//     modifier ready() {
//         require(address(lsbs().bPool) != address(0), "PBasicSmartPool.ready: not ready");
//         _;
//     }

//     modifier onlyController() {
//         require(msg.sender == lsbs().controller, "PBasicSmartPool.onlyController: not controller");
//         _;
//     }

//     /**
//         @notice Initialises the contract
//         @param _bPool Address of the underlying balancer pool
//         @param _name Name for the smart pool token
//         @param _symbol Symbol for the smart pool token
//         @param _initialSupply Initial token supply to mint
//     */
//     function init(
//         address _bPool,
//         string calldata _name,
//         string calldata _symbol,
//         uint256 _initialSupply
//     ) external {
//         sbs storage s = lsbs();
//         require(address(s.bPool) == address(0), "PBasicSmartPool.init: already initialised");
//         require(_bPool != address(0), "PBasicSmartPool.init: _bPool cannot be 0x00....000");
//         require(_initialSupply != 0, "PBasicSmartPool.init: _initialSupply can not zero");
//         s.bPool = IBPool(_bPool);
//         s.controller = msg.sender;

//         lpts().name = _name;
//         lpts().symbol = _symbol;
//         _mintPoolShare(_initialSupply);
//         _pushPoolShare(msg.sender, _initialSupply);
//     }

//     address public constant DEV_ADDRESS = 0x9Ea17bcaB9d819e41A7866aD2CC7F00dfd9EE352;
//     address public constant DAI = 0x1528F3FCc26d13F7079325Fb78D9442607781c8C;

//     //IBPool public bpool = IBPool(0xEb797E61C5b522a8CEF230de37AB438D01664fA6);

//     /**
//      * @dev Sets the controller address. Can only be set by the current controller
//      * @param  _controller Address of the new controller.
//      */

//     // function setController(address _controller) public {
//     //     require(msg.sender == DEV_ADDRESS);
//     //     bpool.setController(_controller);
//     // }

//     function setController(address _controller) external onlyController noReentry {
//         lsbs().controller = _controller;
//     }

//     /**
//      * @dev Mint pool share in exchange of exchange for underlying assets.
//      * @param  _amount of DAI.
//      */

//     // function addLiquidity(uint256[] memory _amount) public {
//     //     // should be done using web3 and gnosis batching (front end)
//     //     // require(ERC20(DAI).balanceOf(msg.sender) >= _amount, "Insufficient balance");
//     //     // address[] memory tokens = bpool.getCurrentTokens();
//     //     // uint256[] memory tokenAmount;
//     //     // for (uint256 i = 0; i < tokens.length; i++) {
//     //     //     uint256 denormalizedWeight = bpool.getDenormalizedWeight(tokens[i]);
//     //     //     tokenAmount[i] = (denormalizedWeight.bmul(_amount)).bdiv(bpool.getNumTokens());
//     //     //     exchange tokenAmount[i] for tokens[i] using 1inch and send to pool smart contract
//     //     //     call addLiquidity
//     //     // }

//     //     address[] memory tokens = bpool.getCurrentTokens();

//     //     for (uint256 i = 0; i < tokens.length; i++) {
//     //         uint256 oldTokenAmount = bpool.getBalance(tokens[i]);
//     //         uint256 denormalizedWeight = bpool.getDenormalizedWeight(tokens[i]);
//     //         ERC20(tokens[i]).approve(0xEb797E61C5b522a8CEF230de37AB438D01664fA6, _amount[i]);
//     //         bpool.rebind(tokens[i], oldTokenAmount.badd(_amount[i]), denormalizedWeight);
//     //     }
//     // }

//     /**
//         @notice Mints pool shares in exchange for underlying assets.
//         @param _amount Amount of pool shares to mint
//     */

//     function joinPool(uint256 _amount) external virtual ready noReentry {
//         _joinPool(_amount);
//     }

//     /**
//         @notice Internal join pool function. See joinPool for more info
//         @param _amount Amount of pool shares to mint
//     */
//     function _joinPool(uint256 _amount) internal virtual ready {
//         IBPool bPool = lsbs().bPool;
//         uint256 poolTotal = totalSupply();
//         uint256 ratio = _amount.bdiv(poolTotal);
//         require(ratio != 0);

//         address[] memory tokens = bPool.getCurrentTokens();

//         for (uint256 i = 0; i < tokens.length; i++) {
//             address t = tokens[i];
//             uint256 bal = bPool.getBalance(t);
//             uint256 tokenAmountIn = ratio.bmul(bal);

//             _pullUnderlying(t, msg.sender, tokenAmountIn, bal);
//         }
//         _mintPoolShare(_amount);
//         _pushPoolShare(msg.sender, _amount);
//     }

//     /**
//         @notice Pull the underlying token from an address and rebind it to the balancer pool
//         @param _token Address of the token to pull
//         @param _from Address to pull the token from
//         @param _amount Amount of token to pull
//         @param _tokenBalance Balance of the token already in the balancer pool
//     */
//     function _pullUnderlying(
//         address _token,
//         address _from,
//         uint256 _amount,
//         uint256 _tokenBalance
//     ) internal {
//         IBPool bPool = lsbs().bPool;
//         // Gets current Balance of token i, Bi, and weight of token i, Wi, from BPool.
//         uint256 tokenWeight = bPool.getDenormalizedWeight(_token);

//         require(
//             ERC20(_token).transferFrom(_from, address(this), _amount),
//             "PBasicSmartPool._pullUnderlying: transferFrom failed"
//         );
//         bPool.rebind(_token, _tokenBalance.badd(_amount), tokenWeight);
//     }

//     /**
//         @notice Mint pool shares
//         @param _amount Amount of pool shares to mint
//     */
//     function _mintPoolShare(uint256 _amount) internal {
//         _mint(_amount);
//     }

//     /**
//         @notice Push pool shares to account
//         @param _to Address to push the pool shares to
//         @param _amount Amount of pool shares to push
//     */
//     function _pushPoolShare(address _to, uint256 _amount) internal {
//         _push(_to, _amount);
//     }

//     /**
//         @notice Load PBasicPool storage
//         @return s Pointer to the storage struct
//     */
//     function lsbs() internal pure returns (sbs storage s) {
//         bytes32 loc = sbsSlot;
//         assembly {
//             s_slot := loc
//         }
//     }
// }
