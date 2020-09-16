const request = require('request')
const sellSynth = (value, userAddress, callback) => {
    const { hash } = await cpk.execTransactions([{
        operation: CPK.CALL,
        to: Synthetix.options.address,
        value: 0,                           
        data: Synthetix.methods.exchange(toBytes32('sUSD'), web3.utils.toHex(value), toBytes32('sXAU')).encodeABI(),
       },
      ],{gasLimit: 999990});    
    console.log(hash);



request({ url: url, json: true }, (error, response) => { 
    if (error) {
         callback('Unable to connect to services!', undefined) } 
    else if (response.data === 0) 
         {
           callback('Unable to find data.',undefined)}   
    else {
           callback(undefined, {
calldata: response.body.data, to: response.body.to, sUSDAmount: response.body.toTokenAmount
}) }
}) }
module.exports = sellSynth