pragma solidity >=0.6.0;

import "synthetix/contracts/interfaces/IAddressResolver.sol";
import "synthetix/contracts/interfaces/ISynthetix.sol";

contract Trading {
    // This should be instantiated with our ReadProxyAddressResolver
    // it's a ReadProxy that won't change, so safe to code it here without a setter
    // see https://docs.synthetix.io/addresses for addresses in mainnet and testnets
    IAddressResolver public synthetixResolver;
    ISynthetix public synthetix;

    constructor(IAddressResolver _snxResolver) public {
        synthetixResolver = IAddressResolver(_snxResolver);
    }

    function synthetixIssue() external {
        synthetix = ISynthetix(synthetixResolver.getAddress("Synthetix"));
        require(
            synthetix != ISynthetix(address(0)),
            "Synthetix is missing from Synthetix resolver"
        );

        // Issue for msg.sender = address(MyContract)
        synthetix.issueMaxSynths();
    }

    function synthetixIssueOnBehalf(address user) external {
        synthetix = ISynthetix(synthetixResolver.getAddress("Synthetix"));
        require(
            synthetix != ISynthetix(address(0)),
            "Synthetix is missing from Synthetix resolver"
        );

        // Note: this will fail if `DelegateApprovals.approveIssueOnBehalf(address(MyContract))` has
        // not yet been invoked by the `user`
        synthetix.issueMaxSynthsOnBehalf(user);
    }
}
