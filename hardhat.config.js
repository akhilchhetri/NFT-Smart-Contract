require("@nomiclabs/hardhat-waffle");
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.3",
      },
      {
        version: "0.8.0",
      },
    ],
  },
  networks: {
    ropsten: {
      url: "", //Infura url with projectId
      accounts: [""], // add the account that will deploy the contract (private key)
    },
  },
};
