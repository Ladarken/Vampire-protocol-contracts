// ============ Contracts ============

// Token
// deployed first
const VAMPImplementation = artifacts.require("VAMPDelegate");
const VAMPProxy = artifacts.require("VAMPDelegator");

// Rs
// deployed second
const VAMPReserves = artifacts.require("VAMPReserves");
const VAMPRebaser = artifacts.require("VAMPRebaser");

// ============ Main Migration ============

const migration = async (deployer, network, accounts) => {
  await Promise.all([
    deployRs(deployer, network),
  ]);
};

module.exports = migration;

// ============ Deploy Functions ============


async function deployRs(deployer, network) {
  let reserveToken = "0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8";
  let uniswap_factory = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
  //await deployer.deploy(VAMPReserves, reserveToken, VAMPProxy.address);
 /* await deployer.deploy(VAMPRebaser,
      VAMPProxy.address,
      reserveToken,
      uniswap_factory,
      VAMPReserves.address
  );*/
  //let rebase = new web3.eth.Contract(VAMPRebaser.abi, VAMPRebaser.address);

  //let pair = await rebase.methods.uniswap_pair().call();
  //console.log(pair)
 // let VAMP = await VAMPProxy.deployed();
 // await VAMP._setRebaser(VAMPRebaser.address);
  //let reserves = await VAMPReserves.deployed();
  //await reserves._setRebaser(VAMPRebaser.address)
}
