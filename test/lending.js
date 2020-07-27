const { BN, constants, expectEvent, shouldFail, time } = require('openzeppelin-test-helpers');
const { ZERO_ADDRESS } = constants;

const CPK = require("contract-proxy-kit")
const ProtocolProxy = artifacts.require('ProtocolProxy');
const Token = artifacts.require("ERC20");
//const ISoloMargin = artifacts.require("ISoloMargin")
const CTokenInterface = artifacts.require("CTokenInterface")
//const ITokenInterface = artifacts.require("ITokenInterface")


contract('ProtocolProxy', function (accounts) {

    const oneEther = 1000000000000000000;
    const COMPOUND_ENUM = 0;
    const DYDX_ENUM = 1;
    const FULCRUM_ENUM = 2;
    const AAVE_ENUM =2;

    const DAI_ENUM = 0;
    const USDC_ENUM=1;
    const USDT_ENUM=2;

    let daiToken, protocolProxy, cpk;

    function getAbiFunction(contract, functionName) {
        const abi = contract.toJSON().abi;

        return abi.find(abi => abi.name === functionName);
    }

    beforeEach(async function () {
        protocolProxy = await ProtocolProxy.deployed()
         cpk = await CPK.create({ web3 , ownerAccount:accounts[6]});
        let daiAddress = await protocolProxy.DAI_ADDRESS();
        daiToken = await Token.at(daiAddress)
       // await daiToken.approve(cpk.address, web3.utils.toWei(Number.MAX_SAFE_INTEGER.toString(), 'ether'))
    });

    async function deposit(protocolEnum,tokenEnum, amount) {
        const{ hash } = await cpk.execTransactions([
            {
              operation: CPK.DELEGATECALL,
              to: protocolProxy.address,
              value: 0,
              data: protocolProxy.contract.methods.deposit(protocolEnum,tokenEnum, amount).encodeABI(),  
            },    
          ],
          { gasLimit:999990 },
          ); 
        return hash;
    }
    // async function withdraw(protocolEnum, amount) {
    //     const{ promiEvent, hash } = await cpk.execTransactions([
    //         {
    //           operation: CPK.DELEGATECALL,
    //           to: protocolProxy.address,
    //           value: 0,
    //           data: protocolProxy.contract.methods.withdraw(protocolEnum,amount).encodeABI(),  
    //         },    
    //       ],
    //       { gasLimit:899990 },
    //       ); 
    //     return hash;
    // }

    // async function swap(protocolEnumFrom, protocolEnumTo, amount) {
    //     const data = web3.eth.abi.encodeFunctionCall(getAbiFunction(SavingsProxy, 'swap'), [protocolEnumFrom, protocolEnumTo, amount]);
    //     const tx = await dsProxy.methods['execute(address,bytes)'](savingsProxy.address, data);

    //     return tx;
    // }

    async function getTokenBalance(address, account) {
        let token = await Token.at(address)

        let balance = await token.balanceOf(account)

        return balance.toString();
    }

    async function getDaiBalance(account) {
        let daiAddress = await protocolProxy.DAI_ADDRESS();

        let balance = await getTokenBalance(daiAddress, account)

        return balance;
    }

    async function getCompoundBalance(account) {
        let cDaiAddress = await protocolProxy.CDAI_ADDRESS();
        let cTokenInterface = await CTokenInterface.at(cDaiAddress);

        let balance = await cTokenInterface.balanceOfUnderlying.call(account)

        return balance.toString();
    }

    // async function getFulcrumBalance(account) {
    //     let iDaiAddress = await savingsProxy.IDAI_ADDRESS();
    //     let iTokenInterface = await ITokenInterface.at(iDaiAddress)

    //     let balance = await iTokenInterface.assetBalanceOf.call(account)
    //     return balance.toString();
    // }

    // async function getDydxBalance(account) {
    //     let soloMarginAddress = await savingsProxy.SOLO_MARGIN_ADDRESS();
    //     let soloMargin = await ISoloMargin.at(soloMarginAddress)
    //     let balance = await soloMargin.getAccountBalances([account, 0])

    //     let weiBalance =  balance[2][1]['value'].toString();

    //     return weiBalance
    // }

    async function advanceMultipleBlocks(num) {
        for (var i = 0; i < num; i++) {
            await time.advanceBlock()
        }
    }

    describe('When starting new test', function () {
        it('should have protocolProxy, cpk and daiToken contracts in memory', async function () {
            console.log(daiToken.address);
            console.log(cpk.address);
            console.log(protocolProxy.address);
            console.log(await protocolProxy.SAVINGS_COMPOUND_ADDRESS());
        });

        it('should read balances', async function () {
            console.log("protocolProxy address: ", protocolProxy.address)

            // let dydxBalance = await getDydxBalance(dsProxy.address);
            // console.log("dydx balance:", dydxBalance)
            let compoundBalance = await getCompoundBalance(cpk.address)
            console.log("compound balance:", compoundBalance)
            let daiBalance = await getDaiBalance(cpk.address)
            console.log("dai balance:", daiBalance)
            // let fulcrumBalance = await getFulcrumBalance(dsProxy.address)
            // console.log("fulcrum balance:", fulcrumBalance)
        });
    });

    describe('Depositing', function () {
        it('should be able to deposit DAI to Compound', async function () {
            try {
               
                let tx = await deposit(COMPOUND_ENUM, DAI_ENUM, web3.utils.toWei('0.00001', 'ether'))

                 let balance = await getCompoundBalance(cpk.address)

                console.log("CDAI Balance :", balance.toString())

            } catch(err) {
                assert.equal(1, 2, err)
            }
        });

        // it('should be able to deposit DAI to Dydx', async function () {
        //     try {
        //         let tx = await deposit(DYDX_ENUM, web3.utils.toWei('1', 'ether'))

        //         let balance = await getDydxBalance(dsProxy.address)

        //         console.log("Dydx balance:", balance.toString())

        //     } catch(err) {
        //         assert.equal(1, 2, err)
        //     }
        // });

        // it('should be able to deposit DAI to Fulcrum', async function () {
        //     try {
        //         let tx = await deposit(FULCRUM_ENUM, web3.utils.toWei('1', 'ether'))

        //         let balance = await getFulcrumBalance(dsProxy.address)

        //         console.log("iDai balance:", balance.toString())

        //     } catch(err) {
        //         assert.equal(1, 2, err)
        //     }
        // });
    });

    // describe('Swap', function () {
    //     it('should be able to swap DAI from Compound to Dydx', async function () {
    //         try {
    //             let depositTx = await deposit(COMPOUND_ENUM, web3.utils.toWei('1', 'ether'));

    //             let cbalanceBefore = await getCompoundBalance(dsProxy.address)
    //             let dbalanceBefore = await getDydxBalance(dsProxy.address)

    //             let swapTx = await swap(COMPOUND_ENUM, DYDX_ENUM, cbalanceBefore)

    //             let cbalanceAfter = await getCompoundBalance(dsProxy.address)
    //             let dbalanceAfter = await getDydxBalance(dsProxy.address)

    //             console.log("compound")
    //             console.log(cbalanceBefore)
    //             console.log(cbalanceAfter)
    //             console.log("dydx")
    //             console.log(dbalanceBefore)
    //             console.log(dbalanceAfter)
    //         } catch(err) {
    //             assert.equal(1, 2, err)
    //         }
    //     });
    //     it('should be able to swap DAI from Compound to Fulcrum', async function () {
    //         try {
    //             let depositTx = await deposit(COMPOUND_ENUM, web3.utils.toWei('1', 'ether'));

    //             let cbalanceBefore = await getCompoundBalance(dsProxy.address)
    //             let fbalanceBefore = await getFulcrumBalance(dsProxy.address)

    //             let swapTx = await swap(COMPOUND_ENUM, FULCRUM_ENUM, cbalanceBefore)

    //             let cbalanceAfter = await getCompoundBalance(dsProxy.address)
    //             let fbalanceAfter = await getFulcrumBalance(dsProxy.address)

    //             console.log("compound")
    //             console.log(cbalanceBefore)
    //             console.log(cbalanceAfter)
    //             console.log("fulcrum")
    //             console.log(fbalanceBefore)
    //             console.log(fbalanceAfter)
    //         } catch(err) {
    //             assert.equal(1, 2, err)
    //         }
    //     });
    //     it('should be able to swap DAI from Dydx to Compound', async function () {
    //         try {
    //             let depositTx = await deposit(DYDX_ENUM, web3.utils.toWei('1', 'ether'));

    //             let cbalanceBefore = await getCompoundBalance(dsProxy.address)
    //             let dbalanceBefore = await getDydxBalance(dsProxy.address)

    //             let swapTx = await swap(DYDX_ENUM, COMPOUND_ENUM, dbalanceBefore)

    //             let cbalanceAfter = await getCompoundBalance(dsProxy.address)
    //             let dbalanceAfter = await getDydxBalance(dsProxy.address)

    //             console.log("dydx")
    //             console.log(dbalanceBefore)
    //             console.log(dbalanceAfter)
    //             console.log("compound")
    //             console.log(cbalanceBefore)
    //             console.log(cbalanceAfter)
    //         } catch(err) {
    //             assert.equal(1, 2, err)
    //         }
    //     });
    //     it('should be able to swap DAI from Dydx to Fulcrum', async function () {
    //         try {
    //             let depositTx = await deposit(DYDX_ENUM, web3.utils.toWei('1', 'ether'));

    //             let fbalanceBefore = await getFulcrumBalance(dsProxy.address)
    //             let dbalanceBefore = await getDydxBalance(dsProxy.address)

    //             let swapTx = await swap(DYDX_ENUM, FULCRUM_ENUM, dbalanceBefore)

    //             let fbalanceAfter = await getFulcrumBalance(dsProxy.address)
    //             let dbalanceAfter = await getDydxBalance(dsProxy.address)

    //             console.log("dydx")
    //             console.log(dbalanceBefore)
    //             console.log(dbalanceAfter)
    //             console.log("fulcrum")
    //             console.log(fbalanceBefore)
    //             console.log(fbalanceAfter)
    //         } catch(err) {
    //             assert.equal(1, 2, err)
    //         }
    //     });
    //     it('should be able to swap DAI from Fulcrum to Compound', async function () {
    //         try {
    //             let depositTx = await deposit(FULCRUM_ENUM, web3.utils.toWei('1', 'ether'));

    //             let fbalanceBefore = await getFulcrumBalance(dsProxy.address)
    //             let cbalanceBefore = await getCompoundBalance(dsProxy.address)

    //             let swapTx = await swap(FULCRUM_ENUM, COMPOUND_ENUM, fbalanceBefore)

    //             let fbalanceAfter = await getFulcrumBalance(dsProxy.address)
    //             let cbalanceAfter = await getCompoundBalance(dsProxy.address)

    //             console.log("fulcrum")
    //             console.log(fbalanceBefore)
    //             console.log(fbalanceAfter)
    //             console.log("compound")
    //             console.log(cbalanceBefore)
    //             console.log(cbalanceAfter)
    //         } catch(err) {
    //             assert.equal(1, 2, err)
    //         }
    //     });
    //     it('should be able to swap DAI from Fulcrum to Dydx', async function () {
    //         try {
    //             let depositTx = await deposit(FULCRUM_ENUM, web3.utils.toWei('1', 'ether'));

    //             let fbalanceBefore = await getFulcrumBalance(dsProxy.address)
    //             let dbalanceBefore = await getDydxBalance(dsProxy.address)

    //             let swapTx = await swap(FULCRUM_ENUM, DYDX_ENUM, fbalanceBefore)

    //             let fbalanceAfter = await getFulcrumBalance(dsProxy.address)
    //             let dbalanceAfter = await getDydxBalance(dsProxy.address)

    //             console.log("fulcrum")
    //             console.log(fbalanceBefore)
    //             console.log(fbalanceAfter)
    //             console.log("dydx")
    //             console.log(dbalanceBefore)
    //             console.log(dbalanceAfter)
    //         } catch(err) {
    //             assert.equal(1, 2, err)
    //         }
    //     });
    // });

    // describe('Withdrawing', function () {
    //     it('should be able to withdraw DAI to Compound', async function () {
    //         try {
    //             let cDaiBalance = await getCompoundBalance(cpk.address)

    //             let balanceBefore = await getCompoundBalance(cpk.address);

    //             if (balanceBefore != "0") {
    //                 console.log("balance is zero, depositing 1 dai")
    //               //  await depost(COMPOUND_ENUM, web3.utils.toWei('0.0001', 'ether'))
    //             }

    //             const tx = await withdraw(COMPOUND_ENUM, cDaiBalance)

    //             let balanceAfter = await getCompoundBalance(cpk.address);

    //             console.log("compound")
    //             console.log(balanceBefore)
    //             console.log(balanceAfter)
    //         } catch(err) {
    //             assert.equal(1, 2, err)
    //         }
    //     });

        // it('should be able to withdraw DAI to Dydx', async function () {
        //     try {
        //         let weiBalance =  await getDydxBalance(dsProxy.address);

        //         let balanceBefore = await getDydxBalance(dsProxy.address);

        //         if (balanceBefore != "0") {
        //             console.log("balance is zero, depositing 1 dai")
        //             await depost(DYDX_ENUM, web3.utils.toWei('1', 'ether'))
        //         }

        //         let tx = await withdraw(DYDX_ENUM, weiBalance)

        //         let balanceAfter = await getDydxBalance(dsProxy.address);

        //         console.log("dydx")
        //         console.log(balanceBefore.toString())
        //         console.log(balanceAfter.toString())

        //     } catch(err) {
        //         assert.equal(1, 2, err)
        //     }
        // });

        // it('should be able to withdraw DAI to Fulcrum', async function () {
        //     try {
        //         let iDaiBalance = await getFulcrumBalance(dsProxy.address)

        //         let balanceBefore = await getFulcrumBalance(dsProxy.address);

        //         if (balanceBefore == "0") {
        //             console.log("balance is zero, depositing 1 dai")
        //             await depost(FULCRUM_ENUM, web3.utils.toWei('1', 'ether'))
        //         }

        //         let tx = await withdraw(FULCRUM_ENUM, iDaiBalance);

        //         let balanceAfter = await getFulcrumBalance(dsProxy.address);

        //         console.log("Fulcrum")
        //         console.log(balanceBefore.toString())
        //         console.log(balanceAfter.toString())

        //     } catch(err) {
        //         assert.equal(1, 2, err)
        //     }
        // });

    //     it('should be able to return funds to user', async function() {
    //         try {
    //             const data = web3.eth.abi.encodeFunctionCall(getAbiFunction(SavingsProxy, 'withdrawDai'), []);
    //             const tx = await dsProxy.methods['execute(address,bytes)'](savingsProxy.address, data);

    //             let myBal = await daiToken.balanceOf(accounts[0])
    //             console.log("My dai balance:", myBal.toString())
    //         } catch(err) {
    //             assert.equal(1, 2, err)
    //         }
    //     });
    //  });

});