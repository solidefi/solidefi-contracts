const CPK = require("contract-proxy-kit")
const chai = require("chai");
const Token = artifacts.require("ERC20");
const Pool = artifacts.require("IBPooL");
const Faucet = artifacts.require("IFaucet");
const BasicSmartPool = artifacts.require("BasicSmartPool");
const IBFactory = artifacts.require("IBFactory");
const ProxySmartPool = artifacts.require("ProxySmartPool");

// chai.use(solidity);
const {expect} = chai;
contract('SMART POOL TEST', function (accounts) {
   
describe('When creating new pool', function () {
    this.timeout(10000000);
    const poolAddress = process.env.POOL;
    const INITIAL_SUPPLY = web3.utils.toWei("100",'ether' );
    const MAX = web3.utils.toWei(Number.MAX_SAFE_INTEGER.toString(), 'ether');
    let tokens=[];
    let token;
    let pool;
    let mintAmount = web3.utils.toWei('0.001', 'ether');
    let smartPool;
    let proxySmartPool;
  
    before(async () => { 
    cpk = await CPK.create({ web3 , ownerAccount:accounts[6]});   
    pool = await Pool.at(poolAddress, {from:accounts[6]});
    smartPool = await BasicSmartPool.at(process.env.BSP, {from:accounts[6]});
    console.log(smartPool.address);
    proxySmartPool = await ProxySmartPool.at(process.env.PSP, {from:accounts[6]});
    // Approve tokens
    console.log("Approving tokens");
    //  const tokenAddresses =["0x1528F3FCc26d13F7079325Fb78D9442607781c8C","0x1f1f156E0317167c11Aa412E3d1435ea29Dc3cCE","0xd0A1E359811322d97991E03f863a0C30C2cF029C"];     
    const tokenAddresses = await pool.getCurrentTokens({from: accounts[6]});
    
    for (const tokenAddress of tokenAddresses) {   
        const token = await Token.at(tokenAddress, {from:accounts[6]});
        tokens.push(token);

        // if((await token.allowance(accounts[6], poolAddress)).gt(MAX.sub(100))) {
        //   console.log(`Approving ${tokenAddress}`);
          
        //   await token.approve(poolAddress, MAX, {from:accounts[6]});
        //   const t= await token.allowance(accounts[6], poolAddress, {from:accounts[6]});
        //   console.log(t.toString());
        // }
      }
    });

      // it("Create a new pool should return pool address", async () => {
        // createPool = await IBFactory.at(process.env.IBFACTORY, {from:accounts[6]});
      //   const newPool = await createPool.newBPool({from:accounts[6]});
      //   console.log("New Pool ",newPool.toString());
       
      // });
    

    //   it("Faucet should return token", async () => {
    //     const token = await Token.at("0x1f1f156E0317167c11Aa412E3d1435ea29Dc3cCE", {from:accounts[6]});
    //     const balanceBefore = await token.balanceOf(accounts[6], {from:accounts[6]});
    //     const faucet = await Faucet.at(process.env.FAUCET, {from: accounts[6]});
    //     await faucet.drip("0x1f1f156E0317167c11Aa412E3d1435ea29Dc3cCE",{from:accounts[6], gasLimit: 2000000});
    //     const balanceAfter = await token.balanceOf(accounts[6],{from:accounts[6]});
    //     console.log(balanceBefore.toString(), balanceAfter.toString());
    //     // assert.equal(balanceAfter, balanceBefore.add(web3.utils.toWei('0.001', 'ether')));
    //   });
    

      // it(`Controller should be correct`, async () => {  
      //   try {
      //       let controller = await pool.getController();
      //       assert.equal(controller, accounts[6]);
      //       console.log("controller address :", controller.toString(), accounts[6].toString());
      //   } catch(err) {
      //       assert.equal(1, 2, err);
      //   }
      // }); 

      //  it("Binding a token should work", async () => {
      //   try {          
                
      //           await pool.bind(tokens[0].address, web3.utils.toWei('5', 'ether'), web3.utils.toWei('1', 'ether'), {
      //           from:accounts[6], gasLimit: 2000000});
      //           await pool.bind(tokens[1].address, web3.utils.toWei('25', 'ether'), web3.utils.toWei('1', 'ether'), {
      //             from:accounts[6], gasLimit: 2000000});
      //           await pool.bind(tokens[2].address, web3.utils.toWei('0.02', 'ether'), web3.utils.toWei('1', 'ether'), {
      //               from:accounts[6], gasLimit: 2000000});
        
      //       const poolTokens = await pool.getCurrentTokens({from:accounts[6]});
      //       console.log("List of pool current token addresses:", poolTokens.toString()); 
      //       //assert.equal(poolTokens[poolTokens.length - 1],tokens[1].address, "Not added");
      //   } catch(err) {
      //       assert.equal(1, 2, err);
      //   }
      // });

    // it("Rebinding a token should work", async () => {
    //     // Reducing the weight of a token to make room to bind another one
    //     const balanceBefore = await pool.getBalance(tokens[0].address, {from:accounts[6]});
        
    //       await pool.rebind(tokens[0].address, balanceBefore, web3.utils.toWei('1', 'ether'), {from:accounts[6],
    //         gasLimit: 2000000,
    //       });
       
    //     const weight = await pool.getDenormalizedWeight(tokens[0].address, {from:accounts[6]});
    //     assert.equal(weight, web3.utils.toWei('1', 'ether'));
    //   }); 

   

    //  it("Set swap fee should work", async () => {  
    //       await pool.setSwapFee(web3.utils.toWei('0.003', 'ether'), {from:accounts[6],
    //         gasLimit: 2000000,
    //       });
       
    //     const swapFee = await pool.getSwapFee({from:accounts[6]});
    //     assert.equal(swapFee, web3.utils.toWei('0.003', 'ether'));
    //   });  

      it(`init should work CALL`, async () => {  
        try {
          const{ hash } =  await cpk.execTransactions([
            {
              operation: CPK.CALL,
              to: smartPool.address,
              value: 0,
              data: smartPool.contract.methods.init(poolAddress, web3.utils.toWei('15', 'wei') ).encodeABI(),  
            },    
          ],
          { gasLimit:999999, from:accounts[1]},); 
          console.log(hash.toString())
          return hash; 
            
        } catch(err) {
            assert.equal(1, 2, err);
        }
      }); 
  
      // it(`setController using smartpool contract should work`, async () => {  
      //   try {
      //           let oldController = await pool.getController( {from:accounts[6]});
      //           //  const hash = await smartPool.setController(accounts[6],poolAddress,{from:accounts[6]});
      //            const hash = await pool.setController(smartPool.address, {from: accounts[6]});
      //       //  console.log(hash.toString());          
      //       let newController = await pool.getController( {from:accounts[6]});
      //       console.log("New controller address and old controller address :", newController.toString(), oldController.toString());
      //   } catch(err) {
      //       assert.equal(1, 2, err);
      //   }
      // }); 

      //  it("Joining the pool should work", async () => {
      //   const balanceBefore = await pool.balanceOf(smartPool.address, {from:accounts[6]});
      //   // let token = await Token.at(tokens[1].address, {from:accounts[6]});
      //   // await token.transfer(cpk.address,web3.utils.toWei('17', 'ether'),{from:accounts[6], gasLimit: 2000000});
      //   //  token = await Token.at(tokens[2].address, {from:accounts[6]});
      //   //  await token.transfer(cpk.address,web3.utils.toWei('0.02', 'ether'),{from:accounts[6], gasLimit: 2000000});
           
      //   const{ hash } =  await cpk.execTransactions([
      //       {
      //         operation: CPK.DELEGATECALL,
      //         to: proxySmartPool.address,
      //         value: 0,
      //         data: proxySmartPool.contract.methods.joinSmartPool(web3.utils.toWei('1', 'wei'), poolAddress ).encodeABI(),  
      //       },    
      //     ],
      //     { gasLimit:999999, from:accounts[1]}); 
      //     console.log("join pool tx: ",hash.toString());
      //   const balanceAfter = await pool.balanceOf(accounts[6],{from:accounts[6]});
      //   console.log(" balanceBefore ",balanceBefore.toString(), "balanceAfter ",balanceAfter.toString() );
      // });
     
    // it(`addLiquidity using smartpool contract from any address should work`, async () => {  
    //     try {

    //      let  tokenAmount = [];
    //      let _amount = 10;
         
    //     for (const token of tokens) {
    //         let denormalizedWeight = await pool.getDenormalizedWeight(token.address, {from:accounts[6]});
    //         let numTokens = await  pool.getNumTokens({from:accounts[6]})
    //         tokenAmount.push((denormalizedWeight * _amount)/(numTokens));
    //         console.log(token.address);
    //         console.log(denormalizedWeight.toString());
    //         console.log(numTokens.toString());

    //         // exchange tokenAmount[i] DAI for tokens[i] pool tokens using 1inch 
    //         // send tokens[i] amount to pool smart contract and tokenAmount == minAmount
    //     }
    //         console.log(tokenAmount.toString());
    //          let minAmount = web3.utils.toWei('0.001', 'ether')        
    //          await smartPool.addLiquidity([minAmount,minAmount,minAmount], {from:accounts[0]});        
    //     } catch(err) {
    //         assert.equal(1, 2, err);
    //     }
    //   }); 
    
  });
  
});