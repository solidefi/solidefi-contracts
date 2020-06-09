pragma solidity >=0.6.0;

import "./DSProxyInterface.sol";


abstract contract ProxyRegistryInterface {
    function proxies(address _owner)
        public
        virtual
        view
        returns (DSProxyInterface);

    function build(address) public virtual returns (address);
}
