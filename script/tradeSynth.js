const path = require("path");
const dotenv = require('dotenv').config({path:'/Users/surbhiaudichya/Documents/solidefi-contracts/.env'});
const synthetix = require('synthetix');
const CPK = require('contract-proxy-kit')
const Web3 = require('web3');

const network = 'kovan';
const exchangeForSynth = require("./exchangeSynth")

web3 = new Web3(new Web3.providers.HttpProvider(process.env.KOVAN_INFURA_ENDPOINT));

account = web3.eth.accounts.privateKeyToAccount(process.env.PRIV_KEY);
web3.eth.accounts.wallet.add(account);

const  {address: addressSynthetix}  = synthetix.getTarget({ network, contract: 'ProxyERC20' });
const  {abi : abiSynthetix}  = synthetix.getSource({ network, contract: 'Synthetix' });
const Synthetix = new web3.eth.Contract(abiSynthetix,addressSynthetix);

const { toBytes32 } = synthetix;

trading = (async () => {
  try {
   
  const cpk = await CPK.create({ web3 , ownerAccount:account.address});
  const addressSUSD = await Synthetix.methods.synths(toBytes32('sUSD')).call();
  const sUSDContract = new web3.eth.Contract(abiSynthetix,addressSUSD);
  // const dai = new web3.eth.Contract(ERC20JSON.abi, DAI);
  const value = 0.001*1e18;
  const fromSymbol = DAI;
 const toSymbol = sUSD;
  exchangeForSynth(fromSymbol,toSymbol,value, cpk.address, async(error, data) => { 
   
     if (error) {
      return console.log(error) 
     } 
     
    //  const allowance = await dai.methods.allowance(accounts[0], data.to).call();
    //  console.log("allowance ",allowance.toString());
    //  if (allowance.toString() === '0') {
    //   let gasLimit = await  dai.methods.approve( data.to,web3.utils.toWei(Number.MAX_SAFE_INTEGER.toString(), 'ether')).estimateGas({ from: accounts[0] });
    //   let gasPrice = await web3.eth.getGasPrice();
    //   await dai.methods.approve( data.to,web3.utils.toWei(Number.MAX_SAFE_INTEGER.toString(), 'ether')).send({ from: accounts[0],gasPrice: web3.utils.toHex(gasPrice),
    //     gasLimit: web3.utils.toHex(gasLimit) });
    // }

   
      try {
        if(!await Synthetix.methods.isWaitingPeriod(toBytes32('sUSD'))){
          return console.log(await Synthetix.methods.isWaitingPeriod(toBytes32('sUSD')).call());
        }
        console.log("sXAG",await Synthetix.methods.isWaitingPeriod(toBytes32('sXAG')).call());
        console.log("sXAU",await Synthetix.methods.isWaitingPeriod(toBytes32('sXAU')).call());
        console.log(cpk.address);
     const { promiEvent, hash } = await cpk.execTransactions([
       {
         operation: CPK.CALL,
         to: data.to,
         value: 0,                           
         data: data.calldata,
       },
       {
        operation: CPK.CALL,
        to: Synthetix.options.address,
        value: 0,                           
        data: Synthetix.methods.exchange(toBytes32('sUSD'), web3.utils.toHex(data.sUSDAmount), toBytes32('sXAU')).encodeABI(),
       },
      ],{gasLimit: 999990});    
      console.log(hash);
    }  
    catch (err) {
      console.log('Synthetix token Error', err);
    } 

    });
  } catch (err) {
    console.log('Error', err);
  }
})();

sell = (async () => {
  // sell sXAU for DAI
  // exchange sXAU for sUSD
  // 1inch sUSD for DAI 
  try {
    const cpk = await CPK.create({ web3 , ownerAccount:account.address});
    const sXAUamount = 0.000001*1e18;
    const sUSDvalue = 0.001*1e18; //sUSD value this should be equal to what we got after exchanging sXAU for sUSD
    const fromSymbol = sUSD;
    const toSymbol = DAI;
    sellSynth(sXAUamount, cpk.address, async(error, res) => { 
       
      
      exchangeForSynth('sUSD','DAI',res.sUSDvalue, cpk.address, async(error, data) => { 
        const { hash } = await cpk.execTransactions([     
          {
            operation: CPK.CALL,
            to: data.to,
            value: 0,                           
            data: data.calldata,
          },
          
         ],{gasLimit: 999990});    
         console.log(hash);
    
      });
        
    });
    
    

  } catch(err){
    console.log(err);
  }

})();

/**
 * console.log( synthetix.getSuspensionReasons());
 * Synthetix.methods.settle(toBytes32('sUSD'))
 */