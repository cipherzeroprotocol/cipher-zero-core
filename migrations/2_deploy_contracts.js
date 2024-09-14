const CipherZeroToken = artifacts.require("CipherZeroToken");
const AssetRegistry = artifacts.require("AssetRegistry");
const AssetTransfer = artifacts.require("AssetTransfer");

module.exports = function(deployer) {
  deployer.deploy(CipherZeroToken, '100000000000000000000000000') // 100 million tokens
    .then(() => deployer.deploy(AssetRegistry))
    .then(() => deployer.deploy(AssetTransfer, AssetRegistry.address));
};