const cipherzero = artifacts.require("cipherzero");
const Token = artifacts.require("Token");
const Storage = artifacts.require("Storage");
const Messaging = artifacts.require("Messaging");
const cipherTorrentIntegration = artifacts.require("cipherTorrentIntegration");


module.exports = async function(deployer) {
  await deployer.deploy(Token, 1000000);
  const token = await Token.deployed();
  const { ethers } = require("hardhat");

  async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    // Deploy contracts
    const ZkSnarks = await ethers.getContractFactory("ZkSnarks");
    const zkSnarks = await ZkSnarks.deploy();
    console.log("ZkSnarks deployed to:", zkSnarks.address);
  
    // Repeat for other contracts
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  
  await deployer.deploy(Storage);
  const storage = await Storage.deployed();

  await deployer.deploy(Messaging);
  const messaging = await Messaging.deployed();

  await deployer.deploy(BitTorrentIntegration);
  const bitTorrent = await BitTorrentIntegration.deployed();

  await deployer.deploy(ThetaIntegration);
  const theta = await ThetaIntegration.deployed();

  await deployer.deploy(BitThetaSecure, token.address, storage.address, messaging.address, bitTorrent.address, theta.address);
};
