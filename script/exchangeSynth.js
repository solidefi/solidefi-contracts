const request = require('request')
const exchangeForSynth = (value, userAddress, callback) => {

const url ='https://api.1inch.exchange/v1.1/swapQuote?fromTokenSymbol=DAI&toTokenSymbol=sUSD&amount=' + value + '&fromAddress=' + userAddress + '&slippage=1&disableEstimate=true'

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
module.exports = exchangeForSynth