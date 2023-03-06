require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
        },
      }
    ]
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545/",
    },
    goerli: {
      url: process.env.GOERLI,
      accounts: [process.env.DEPLOYER_TEST]
    },
    arbitrum: {
      url: process.env.ARBITRUM,
      accounts: [process.env.DEPLOYER_MAIN]
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN,
  }
}
