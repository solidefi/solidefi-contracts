  const ProtocolProxy = artifacts.require("./ProtocolProxy.sol");
//  const DydxProtocol = artifacts.require("./DydxProtocol.sol");
//const CompoundProtocol = artifacts.require("./CompoundProtocol");
// const AaveProtocol = artifacts.require("./AaveProtocol");
//const Logger = artifacts.require("./Logger.sol");
require('dotenv').config();

module.exports = function (deployer, network, accounts) {
    let deployAgain = (process.env.DEPLOY_AGAIN === 'true') ? true : false;

    deployer.then(async () => {
        // lend logger 
        // await deployer.deploy(Logger, { gas: 4000000 })    
        //   await deployer.deploy(CompoundProtocol, { gas: 6000000 })
        //    await deployer.deploy(DydxProtocol, { gas: 3000000 })
        // await deployer.deploy(AaveProtocol, { gas: 3000000 })
       
        await deployer.deploy(ProtocolProxy, { gas: 3000000 })

    });
};


