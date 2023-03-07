require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  solidity: {
    compilers: [
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
        },
      },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
        },
      },
      {
        version: "0.5.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
        },
      },
      {
        version: "0.4.18",
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
        },
      },
    ]
  },

  networks: {
    hardhat: {
      forking: {
        url: process.env.MAINNET,
        blockNumber: 16600000
      },

      mining: {
        auto: true,
        interval: 10000
      }
    },

    localhost: {
      url: "http://127.0.0.1:8545/",
    },

    goerli: {
      url: process.env.GOERLI,
      accounts: [process.env.DEPLOYER_TEST]
    },

    fuji: {
      url: process.env.FUJI,
      accounts: [process.env.DEPLOYER_TEST]
    },

    arbitrum: {
      url: process.env.ARBITRUM,
      accounts: [process.env.DEPLOYER_MAIN]
    }
  },
  
  etherscan: {
    apiKey: process.env.ARBISCAN,
  }
}
