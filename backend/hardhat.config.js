require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY


module.exports = {
  defaultNetwork: "sepolia",
  networks: {
    hardhat: {
        //  //If you want to do some forking, uncomment this
        // forking: {
        // url: MAINNET_RPC_URL
        // }
    },
    localhost: {
    },
    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: [PRIVATE_KEY],
      saveDeployments: true,
    },
  },
  solidity: "0.8.24",
};
