// ============ Contracts ============

// List of tokens for farming.
let tokens = [
  "LINK",
  "USDT",
  "WBTC",
  "WETH",
  "WETHUNI"
]
//TODO: change amounts
let amountsPerPool = {
  "LINK": web3.utils.toBN(250000).mul(web3.utils.toBN(10**18)),
  "USDT": web3.utils.toBN(250000).mul(web3.utils.toBN(10**18)),
  "WBTC": web3.utils.toBN(250000).mul(web3.utils.toBN(10**18)),
  "WETH": web3.utils.toBN(250000).mul(web3.utils.toBN(10**18)),
  "WETHUNI": web3.utils.toBN(250000).mul(web3.utils.toBN(10**18))
}

let contractName = (name) => `VAMP${name}Pool`

// Protocol
// deployed second
const VAMPImplementation = artifacts.require("VAMPDelegate");
const VAMPProxy = artifacts.require("VAMPDelegator");

// deployed third
const VAMPReserves = artifacts.require("VAMPReserves");
const VAMPRebaser = artifacts.require("VAMPRebaser");

const Timelock = artifacts.require("Timelock");

// Deployed fourth.
let contractArtifacts = tokens.map((tokenName) => artifacts.require(contractName(tokenName)))

// ============ Main Migration ============

const migration = async (deployer, network, accounts) => {
  await Promise.all([
    // deployTestContracts(deployer, network),
   // deployDistribution(deployer, network, accounts),
    // deploySecondLayer(deployer, network)
  ]);
}

module.exports = migration;

// ============ Deploy Functions ============


async function deployDistribution(deployer, network, accounts) {
  console.log(network)
  let VAMP = await VAMPProxy.deployed();
  let yReserves = await VAMPReserves.deployed()
  let yRebaser = await VAMPRebaser.deployed()
  let tl = await Timelock.deployed();

  if (network !== "test") {
    for (let i = 0; i < contractArtifacts.length; i++) {
      await deployer.deploy(contractArtifacts[i], VAMP.address);
    }

    let poolContracts = {}
    for (let i = 0; i < contractArtifacts.length; i++) {
      poolContracts[tokens[i]] = new web3.eth.Contract(contractArtifacts[i].abi, contractArtifacts[i].address)
    }

    console.log("setting distributor");
    for (let i = 0; i < tokens.length; i++) {
      await poolContracts[tokens[i]].methods.setRewardDistribution(accounts[0]).send({from: accounts[0], gas: 100000})
    }

    let two_fifty = web3.utils.toBN(10**3).mul(web3.utils.toBN(10**18)).mul(web3.utils.toBN(250));
    let one_five = two_fifty.mul(web3.utils.toBN(6));

    console.log("transfering");
    console.log("eth");
    for (let i = 0; i < tokens.length; i++) {
      await VAMP.transfer(contractArtifacts[i].address, amountsPerPool[tokens[i]].toString())
    }

    console.log("notifying");
    for (let i = 0; i < tokens.length; i++) {
      await poolContracts[tokens[i]].methods.notifyRewardAmount(amountsPerPool[tokens[i]].toString()).send({from:accounts[0]})
    }

    console.log("setting distribution");
    // Set reward distribution to timelock.
    for (let i = 0; i < tokens.length; i++) {
      await poolContracts[tokens[i]].methods.setRewardDistribution(Timelock.address).send({from: accounts[0], gas: 100000})
    }

    // Set ownership to timelock.
    for (let i = 0; i < tokens.length; i++) {
      await poolContracts[tokens[i]].methods.transferOwnership(Timelock.address).send({from: accounts[0], gas: 100000})
    }
  }

  await Promise.all([
    VAMP._setPendingGov(Timelock.address),
    yReserves._setPendingGov(Timelock.address),
    yRebaser._setPendingGov(Timelock.address),
  ]);

  await Promise.all([
      tl.executeTransaction(
        VAMPProxy.address,
        0,
        "_acceptGov()",
        "0x",
        0
      ),

      tl.executeTransaction(
        VAMPReserves.address,
        0,
        "_acceptGov()",
        "0x",
        0
      ),

      tl.executeTransaction(
        VAMPRebaser.address,
        0,
        "_acceptGov()",
        "0x",
        0
      ),
  ]);
  // TODO - what will timelocks admin be?
  // await tl.setPendingAdmin(Gov.address);

  // await gov.__acceptAdmin();
  // await gov.__abdicate();
}
