const SavingsProxy = artifacts.require("./SavingsProxy.sol");
const DydxSavingsProtocol = artifacts.require("./DydxSavingsProtocol.sol");
const CompoundSavingsProtocol = artifacts.require("./CompoundSavingsProtocol");


//require('dotenv').config();

module.exports = function (deployer, network, accounts) {
    // let deployAgain = (process.env.DEPLOY_AGAIN === 'true') ? true : false;

    deployer.then(async () => {

        // --------- first deploy this part ---------------------------------
        // await deployer.deploy(DydxSavingsProtocol, { gas: 6000000 })
        // await deployer.deploy(CompoundSavingsProtocol, { gas: 6000000 })
        // --------- change addresses in SavingsProxy contract and then deploy this part --------------
        let dydxSavingsProtocol = await DydxSavingsProtocol.deployed()
        let compoundSavingsProtocol = await CompoundSavingsProtocol.deployed()


        await deployer.deploy(SavingsProxy, { gas: 6000000 })
        let savingsProxy = await SavingsProxy.deployed()

        await dydxSavingsProtocol.addSavingsProxy(savingsProxy.address, { gas: 6000000 })
        await compoundSavingsProtocol.addSavingsProxy(savingsProxy.address, { gas: 6000000 })


    });
};


