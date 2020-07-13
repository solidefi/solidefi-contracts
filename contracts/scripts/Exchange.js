
const synthetix = require('synthetix'); // nodejs
//const ethers = require('ethers'); // nodejs
const CPK = require('contract-proxy-kit')
const Web3 = require('web3');


const network = 'kovan';
//const provider = ethers.getDefaultProvider(network === 'mainnet' ? 'homestead' : network);
//const privateKey =  process.env.PRIV_KEY; // don't actually put a private key in code obviously
//const signer = new ethers.Wallet(privateKey).connect(provider);

web3 = new Web3(new Web3.providers.HttpProvider("https://kovan.infura.io/v3/11b9a3581295441e896cacb35648a968"));

account = web3.eth.accounts.privateKeyToAccount("0xE1DDD8AAFC215C39C5CD6D35BB6EECF5B323ABF78FE566BB7A94FCC7479101C7")
web3.eth.accounts.wallet.add(account)

const  {address: addressSynthetix}  = synthetix.getTarget({ network, contract: 'ProxyERC20' });
const  {abi : abiSynthetix}  = synthetix.getSource({ network, contract: 'Synthetix' });
const Synthetix = new web3.eth.Contract(abiSynthetix,addressSynthetix);

const { toBytes32 } = synthetix;


const {  address: addressDepot} = synthetix.getTarget({ network, contract: 'Depot' });
const  { abi: abiDepot }  = synthetix.getSource({ network, contract: 'Depot' });
const Depot = new web3.eth.Contract(abiDepot,addressDepot);

const {  address: addressDelegateApprovals} = synthetix.getTarget({ network, contract: 'DelegateApprovals' });
const  { abi: abiDelegateApprovals }  = synthetix.getSource({ network, contract: 'DelegateApprovals' });
const DelegateApprovals = new web3.eth.Contract(abiDelegateApprovals,addressDelegateApprovals);



trading = (async () => {
  try {
   
     const cpk = await CPK.create({ web3 , ownerAccount:account.address});
  const addressSUSD = await Synthetix.methods.synths(toBytes32('sUSD')).call();

  const sUSDContract = new web3.eth.Contract(abiSynthetix,addressSUSD);

   let txnDepot = await Depot.methods.synthsReceivedForEther(web3.utils.toHex((0.012*1e18))).call();
   console.log(JSON.stringify(txnDepot,  null, '\t'));
   
//with gnosis 
        await web3.eth.sendTransaction({
          from: account.address,
          to: '0x1bc2f452d95ffa5044a03c0804a379ed5b2bc0f5',
          value: web3.utils.toHex(0.00001*1e18),
          gasLimit: 999990
        })
  //if(!synthetix.isWaitingPeriod(src) 
   const { promiEvent, hash } = await cpk.execTransactions([
       {
         operation: CPK.CALL,
         to: Depot.options.address,
         value: web3.utils.toHex(0.02*1e18),                           
         data: Depot.methods.exchangeEtherForSynths().encodeABI(),
       },
       {
        operation: CPK.CALL,
        to: Synthetix.options.address,
        value: 0,                           
        data: Synthetix.methods.exchange(toBytes32('sUSD'), web3.utils.toHex((txnDepot)), toBytes32('sXAG')).encodeABI(),
      },

      ],{gasLimit: 999990});
      console.log(hash);
  
  //without gnosis batching 
// /* quantity of sUSD received in exchange for a given quantity of ETH */
// const txnDepot = await Depot.methods.synthsReceivedForEther(web3.utils.toHex((0.01*1e18))).call();
// console.log(JSON.stringify(txnDepot,  null, '\t'));

// /* Sells sUSD to callers who send ether */
// const exchangeEtherForSynths = await Depot.methods.exchangeEtherForSynths().send({from:account.address,value: web3.utils.toHex((0.001*1e18)),gasLimit:9999990});
// console.log(JSON.stringify(exchangeEtherForSynths,  null, '\t'));

// /* exchange sUSD for sXAG */
//   const txn = await Synthetix.methods.exchange(toBytes32('sUSD'), web3.utils.toHex((0.01*1e18)), toBytes32('sXAG')).send({from:account.address, gasLimit:9999990}).on('transactionHash', function(hash){
//     console.log(hash);
// })
// .on('confirmation', function(confirmationNumber, receipt){
//   if(confirmationNumber > 2 )return 
// })
// .on('receipt', function(receipt){
//     // receipt example
//     console.log(receipt);
// }).on('error', function(error, receipt) { // If the transaction was rejected by the network with a receipt, the second parameter will be the receipt.
// console.log(error);
// });



  } catch (err) {
    console.log('Error', err);
  }
})();
