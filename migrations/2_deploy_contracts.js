
const DydxSavingsProtocol = artifacts.require("./DydxSavingsProtocol.sol");
const CompoundSavingsProtocol = artifacts.require("./CompoundSavingsProtocol");


//require('dotenv').config();

module.exports = function(deployer, network, accounts) {
   // let deployAgain = (process.env.DEPLOY_AGAIN === 'true') ? true : false;

    deployer.then(async () => {

        // --------- first deploy this part ---------------------------------
        await deployer.deploy(DydxSavingsProtocol, {gas: 6000000})
        await deployer.deploy(CompoundSavingsProtocol, {gas: 6000000})
        
    });
};


