const NSender = artifacts.require("NSender");
const ProxyAdmin = artifacts.require("ProxyAdmin");
const NgSenderProxy = artifacts.require("NgSenderProxy");

module.exports = function (deployer) {
  deployer.deploy(NSender);
  // deployer.deploy(ProxyAdmin);
  // deployer.deploy(NgSenderProxy,"0xD60392E604e9cd631BDf053f18f011462d767c83","0x4f09Bc5BdBc516242F3b5614b35ac89AeC749Ea1","0x8129fc1c");
};
