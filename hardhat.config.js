require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();
const { INFURA, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
  	version: "0.8.17",
  	setting: {
  		optimizer: {
  			enabled: true,
  			runs: 200
  		}
  	}
  },
  paths: {
  	artifacts: './src/artifacts'
  },
  networks: {
  	goerli: {
  		url: INFURA,
  		accounts:[`0x${PRIVATE_KEY}`] 
  	}
  },
  etherscan: {
  	apiKey: {
  		goerli: ETHERSCAN_API_KEY
  	}
  }
};
