require("@nomicfoundation/hardhat-toolbox");

require('dotenv').config();
// require('@nomiclabs/hardhat-etherscan');

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.0",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
  networks: {
    dev: {
        url: "http://localhost:7545",
        gasPrice: 20,
        saveDeployments: true
    },
    goerli: {
        url: `https://eth-goerli.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
        accounts: [process.env.PRIV_KEY]
      
    },
    bsc: {
        url: "https://bsc-dataseed.binance.org",
        accounts: [process.env.PRIV_KEY],
        gasPrice: 20000000000,
        saveDeployments: true,
        blockGasLimit: 1000000
    }
},
etherscan:{
  apiKey:process.env.API_KEY,
}
};