// ============ Contracts ============

// Token
// deployed first
const VAMP = artifacts.require("VAMP");

// ============ Main Migration ============

const migration = async (deployer, network, accounts) => {
  await Promise.all([
    deployToken(deployer, network),
  ]);
};

module.exports = migration;

// ============ Deploy Functions ============

async function deployToken(deployer, network) {
  await deployer.deploy(VAMP);
}
