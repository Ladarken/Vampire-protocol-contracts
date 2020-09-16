// ============ Contracts ============

// Token
// deployed first
const VAMPImplementation = artifacts.require("VAMPDelegate");
const VAMPProxy = artifacts.require("VAMPDelegator");

// ============ Main Migration ============

const migration = async (deployer, network, accounts) => {
  await Promise.all([
    deployToken(deployer, network),
  ]);
};

module.exports = migration;

// ============ Deploy Functions ============

//TODO
async function deployToken(deployer, network) {
  await deployer.deploy(VAMPImplementation);
  if (network != "mainnet") {
    await deployer.deploy(VAMPProxy,
      "VAMP",
      "VAMP",
      18,
      "9000000000000000000000000", // print extra few mil for user
      VAMPImplementation.address,
      "0x"
    );
  } else {
    await deployer.deploy(VAMPProxy,
      "VAMP",
      "VAMP",
      18,
      "2000000000000000000000000",
      VAMPImplementation.address,
      "0x"
    );
  }

}
