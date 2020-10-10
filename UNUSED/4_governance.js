// ============ Contracts ============


// Token
// deployed first
const VAMPImplementation = artifacts.require("VAMPDelegate");
const VAMPProxy = artifacts.require("VAMPDelegator");

// Rs
// deployed second
const VAMPReserves = artifacts.require("VAMPReserves");
const VAMPRebaser = artifacts.require("VAMPRebaser");

// deployed third
const Timelock = artifacts.require("Timelock");

// ============ Main Migration ============

const migration = async (deployer, network, accounts) => {
  await Promise.all([
    deployGovernance(deployer, network),
  ]);
};

module.exports = migration;

// ============ Deploy Functions ============
// This is split across multiple files so that
// if the web3 provider craps out, all progress isn't lost.
//
// This is at the expense of having to do 6 extra txs to sync the migrations
// contract

async function deployGovernance(deployer, network) {
  await deployer.deploy(Timelock);
  // TODO - what is the alternative here?
  // await deployer.deploy(Gov,
  //     Timelock.address,
  //     VAMPProxy.address
  // );
}
