const path = require("path");

const dotenv = require('dotenv').config();
const HDWalletProvider = require('truffle-hdwallet-provider');

const mnemonic = process.env.ETHEREUM_ACCOUNT_MNEMONIC;

module.exports = {
    api_keys: {
        etherscan: process.env.ETHERSCAN_API_KEY
    },
    plugins: [
        'truffle-plugin-verify',
        '@chainsafe/truffle-plugin-abigen'
    ],
    networks: {
        mainnet: {
            provider: function () {
                return new HDWalletProvider(mnemonic, process.env.MAINNET_INFURA_ENDPOINT);
            },
            network_id: '1',
            gasPrice: 36000000000, // 33 gwei
            skipDryRun: true,
        },
        kovan: {
            provider: function () {
                return new HDWalletProvider(mnemonic, process.env.KOVAN_INFURA_ENDPOINT, 0, 15);
            },
            network_id: '42',
            gas: 8000000,
            gasPrice: 3000000000,
            skipDryRun: true,
        },
        rinkeby: {
            provider: function () {
                return new HDWalletProvider(mnemonic, process.env.RINKEBY_INFURA_ENDPOINT, 0, 15);
            },
            network_id: '4',
            gas: 8000000,
            gasPrice: 3000000000,
            skipDryRun: false,
        },
        ropsten: {
            provider: function () {
                return new HDWalletProvider(mnemonic, process.env.ROPSTEN_INFURA_ENDPOINT, 0, 15);
            },
            network_id: '3',
            gas: 8000000,
            gasPrice: 3000000000,
            skipDryRun: false,
        },
    },
    compilers: {
        solc: {
            version: "0.6.0",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                },
            }
        }
    }
}
