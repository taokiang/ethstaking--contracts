require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { SEPOLIA_RPC, PRIVATE_KEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    // ✅ 本地 Node（Hardhat node）也使用 localhost
    localhost: {
      url: "http://127.0.0.1:8545",
      type: "http",
    },

    // ✅ 部署到测试网时可以在 .env 填入私钥和 RPC
    sepolia: {
      url: SEPOLIA_RPC,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      type: "http",
    },
  },
};
