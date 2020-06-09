const ProtocolProxy = artifacts.require("./ProtocolProxy.sol");
const DydxProtocol = artifacts.require("./DydxProtocol.sol");
const CompoundProtocol = artifacts.require("./CompoundProtocol");
const AaveProtocol = artifacts.require("./AaveProtocol");
const Logger = artifacts.require("./Logger.sol");
//require('dotenv').config();

module.exports = function (deployer, network, accounts) {
    // let deployAgain = (process.env.DEPLOY_AGAIN === 'true') ? true : false;

    deployer.then(async () => {
        // lend logger 
        //await deployer.deploy(Logger, { gas: 6000000 })
        // --------- first deploy this part ---------------------------------

        // await deployer.deploy(CompoundProtocol, { gas: 6000000 })
        // await deployer.deploy(DydxProtocol, { gas: 6000000 })
        // await deployer.deploy(AaveProtocol, { gas: 6000000 })



        // --------- change addresses in protocolProxy contract and then deploy this part --------------

        let dydxProtocol = await DydxProtocol.deployed()
        let compoundProtocol = await CompoundProtocol.deployed()
        let aaveProtocol = await AaveProtocol.deployed();

        await deployer.deploy(ProtocolProxy, { gas: 6000000 })
        let protocolProxy = await ProtocolProxy.deployed()

        await dydxProtocol.addProtocolProxy(protocolProxy.address, { gas: 6000000 })
        await compoundProtocol.addProtocolProxy(protocolProxy.address, { gas: 6000000 })
        await aaveProtocol.addProtocolProxy(protocolProxy.address, { gas: 6000000 })

    });
};


