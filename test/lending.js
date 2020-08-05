const { BN, constants, expectEvent, shouldFail, time } = require('openzeppelin-test-helpers');
const { ZERO_ADDRESS } = constants;

const CPK = require("contract-proxy-kit")
const ProtocolProxy = artifacts.require('ProtocolProxy');
const Token = artifacts.require("ERC20");
//const ISoloMargin = artifacts.require("ISoloMargin")
const CTokenInterface = artifacts.require("CTokenInterface");
const ATokenInterface = artifacts.require("ATokenInterface");
//const ITokenInterface = artifacts.require("ITokenInterface")


contract('ProtocolProxy', function (accounts) {

    const oneEther = 1000000000000000000;
    const COMPOUND_ENUM = 0;
    const DYDX_ENUM = 1;
    const AAVE_ENUM =2;

    const DAI_ENUM = 0;
    const USDC_ENUM = 1;
    const USDT_ENUM = 2;
    const TUSD_ENUM = 3;

    let daiToken, protocolProxy, cpk;

    function getAbiFunction(contract, functionName) {
        const abi = contract.toJSON().abi;

        return abi.find(abi => abi.name === functionName);
    }

    beforeEach(async function () {
        protocolProxy = await ProtocolProxy.deployed()
         cpk = await CPK.create({ web3 , ownerAccount:accounts[6]});
        let daiAddress = await protocolProxy.DAI_ADDRESS();
        daiToken = await Token.at(daiAddress);
        let usdcAddress = await protocolProxy.USDC_ADDRESS();
        usdcToken = await Token.at(usdcAddress);
        let usdtAddress = await protocolProxy.USDT_ADDRESS();
        usdtToken = await Token.at(usdtAddress);
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
          { gasLimit:999990, from:accounts[6]},
          ); 
        return hash;
    }
    // async function withdraw(protocolEnum, amount) {
    //     const{ promiEvent, hash } = await cpk.execTransactions([
    //         {
    //           operation: CPK.DELEGATECALL,
    //           to: protocolProxy.address,
    //           value: 0,
    //           data: protocolProxy.contract.methods.withdraw(protocolEnum, tokenEnum,amount).encodeABI(),  
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
        let token = await Token.at(address, {from: accounts[6]})

        let balance = await token.balanceOf(account, {from: accounts[6]})

        return balance.toString();
    }

    async function getDaiBalance(account) {
        let daiAddress = await protocolProxy.DAI_ADDRESS({from: accounts[6]});

        let balance = await getTokenBalance(daiAddress, account, {from: accounts[6]})

        return balance;
    }
    async function getUsdcBalance(account) {
        let usdcAddress = await protocolProxy.USDC_ADDRESS( {from: accounts[6]});

        let balance = await getTokenBalance(usdcAddress, account, {from: accounts[6]})

        return balance;
    }
    async function getUsdtBalance(account) {
        let usdtAddress = await protocolProxy.USDT_ADDRESS( {from: accounts[6]});

        let balance = await getTokenBalance(usdtAddress, account, {from: accounts[6]})

        return balance;
    }

    async function getInterestBearingTokenBalance(account, tokenEnum, protocolEnum) {
        let balance, cTokenInterface, aTokenInterface;
        if(protocolEnum == COMPOUND_ENUM){
            if(tokenEnum == DAI_ENUM){
              let cDaiAddress = await protocolProxy.CDAI_ADDRESS( {from: accounts[6]});
              cTokenInterface = await CTokenInterface.at(cDaiAddress, {from: accounts[6]});
           
            }
            else if(tokenEnum == USDC_ENUM){
               let cUsdcAddress = await protocolProxy.CUSDC_ADDRESS({from: accounts[6]});
                cTokenInterface = await CTokenInterface.at(cUsdcAddress, {from: accounts[6]});
            }
            else if(tokenEnum == USDT_ENUM){
               let cUsdtAddress = await protocolProxy.CUSDT_ADDRESS({from: accounts[6]});
               cTokenInterface = await CTokenInterface.at(cUsdtAddress, {from: accounts[6]});
           
            }
             balance = await cTokenInterface.balanceOfUnderlying.call(account, {from: accounts[6]})
        }
        if(protocolEnum == AAVE_ENUM){
            if(tokenEnum == DAI_ENUM){
              let aDaiAddress = await protocolProxy.ADAI_ADDRESS({from: accounts[6]});
              aTokenInterface = await ATokenInterface.at(aDaiAddress, {from: accounts[6]});
           
            }
            else if(tokenEnum == USDC_ENUM){
               let aUsdcAddress = await protocolProxy.AAVE_AUSDC_ADDRESS( {from: accounts[6]});
                aTokenInterface = await ATokenInterface.at(aUsdcAddress, {from: accounts[6]});
            }
            else if(tokenEnum == USDT_ENUM){
               let aUsdtAddress = await protocolProxy.AAVE_AUSDT_ADDRESS({from: accounts[6]});
               aTokenInterface = await ATokenInterface.at(aUsdtAddress, {from: accounts[6]});
           
            }
             balance = await aTokenInterface.principalBalanceOf.call(account, {from: accounts[6]})
        }     

        return balance.toString();
    }

    

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
        it('should have protocolProxy, cpk and Token contracts in memory', async function () {
            console.log("daiToken: ",daiToken.address);
            console.log("usdcToken: ",usdcToken.address);
            console.log("usdtToken: ",usdtToken.address);

            console.log("gnosis safe address: ",cpk.address);
            console.log("protocolproxy contract address ",protocolProxy.address);
          
        });

        it('should read balances', async function () {
            console.log("protocolProxy address: ", protocolProxy.address)
            console.log("gnosis safe address:", cpk.address)
            // let dydxBalance = await getDydxBalance(dsProxy.address);
            // console.log("dydx balance:", dydxBalance)
            let tokenBalance, cTokenBalance 
            cTokenBalance  = await getInterestBearingTokenBalance(cpk.address, DAI_ENUM, COMPOUND_ENUM, {from: accounts[6]} )
            console.log("cDAI balance:", cTokenBalance)
             tokenBalance = await getDaiBalance(cpk.address, {from: accounts[6]})
            console.log("dai balance:", tokenBalance)
            cTokenBalance  = await getInterestBearingTokenBalance(cpk.address, USDC_ENUM, COMPOUND_ENUM, {from: accounts[6]})
            console.log("cUSDC balance:", cTokenBalance)
             tokenBalance = await getUsdcBalance(cpk.address, {from: accounts[6]})
            console.log("USDC balance:", tokenBalance)
            cTokenBalance  = await getInterestBearingTokenBalance(cpk.address, USDT_ENUM, COMPOUND_ENUM,  {from: accounts[6]})
            console.log("cUSDT balance:", cTokenBalance)
             tokenBalance = await getUsdtBalance(cpk.address, {from: accounts[6]})
            console.log("USDT balance:", tokenBalance)
           
        });
    });

    describe('Depositing', function () {
        // it('should be able to deposit DAI to Compound', async function () {
        //     try {
               
        //         let tx = await deposit(COMPOUND_ENUM, DAI_ENUM, web3.utils.toWei('0.0001', 'ether'), {from:accounts[6]})
        //          console.log(tx);
        //           let balance = await getInterestBearingTokenBalance(cpk.address, DAI_ENUM, COMPOUND_ENUM)

        //          console.log("CDAI Balance :", balance.toString())

        //     } catch(err) {
        //         assert.equal(1, 2, err)
        //     }
        // });
    //    it('should be able to deposit USDC to Compound', async function () {
    //         try {
               
    //             let tx = await deposit(COMPOUND_ENUM, USDC_ENUM, web3.utils.toWei('0.0001', 'mwei'), {from: accounts[6]})

    //              let balance = await getInterestBearingTokenBalance(cpk.address, USDC_ENUM, COMPOUND_ENUM)

    //             console.log("CUSDC Balance :", balance.toString())

    //         } catch(err) {
                
    //             assert.equal(1, 2, err)
    //         }
    //     });
        it('should be able to deposit USDT to Compound', async function () {
            try {
               
                let tx = await deposit(COMPOUND_ENUM, USDT_ENUM, web3.utils.toWei('0.1', 'mwei'), {from: accounts[6]})

                 let balance = await getInterestBearingTokenBalance(cpk.address, USDT_ENUM, COMPOUND_ENUM)

                console.log("CUSDT Balance :", balance.toString())

            } catch(err) {
                assert.equal(1, 2, err)
            }
        });
        // it('should be able to deposit DAI to Aave', async function () {
        //     try {
               
        //         let tx = await deposit(AAVE_ENUM, DAI_ENUM, web3.utils.toWei('0.0001', 'ether'))

        //          let balance = await getInterestBearingTokenBalance(cpk.address, DAI_ENUM, AAVE_ENUM)

        //         console.log("ADAI Balance :", balance.toString())

        //     } catch(err) {
        //         assert.equal(1, 2, err)
        //     }
        // });
        // it('should be able to deposit USDC to Aave', async function () {
        //     try {
               
        //         let tx = await deposit(AAVE_ENUM, USDC_ENUM, web3.utils.toWei('0.0001', 'mwei'))

        //          let balance = await getInterestBearingTokenBalance(cpk.address, USDC_ENUM, AAVE_ENUM)

        //         console.log("AUSDC Balance :", balance.toString())

        //     } catch(err) {
        //         assert.equal(1, 2, err)
        //     }
        // });
        // it('should be able to deposit USDT to Aave', async function () {
        //     try {
               
        //         let tx = await deposit(AAVE_ENUM, USDT_ENUM, web3.utils.toWei('0.0001', 'mwei'))

        //          let balance = await getInterestBearingTokenBalance(cpk.address, USDT_ENUM, AAVE_ENUM)

        //         console.log("AUSDT Balance :", balance.toString())

        //     } catch(err) {
        //         assert.equal(1, 2, err)
        //     }
        // });
      
    
        // it('should be able to deposit DAI to Dydx', async function () {
        //     try {
        //         let tx = await deposit(DYDX_ENUM, web3.utils.toWei('1', 'ether'))

        //         let balance = await getDydxBalance(dsProxy.address)

        //         console.log("Dydx balance:", balance.toString())

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