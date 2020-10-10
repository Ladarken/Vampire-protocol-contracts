// ============ Contracts ============

// Token
// deployed first
const VAMP = artifacts.require("VAMP");

// Rs
// deployed second
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
    // VAMP-WETH Pair
    let reserveToken = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2";
    let uniswap_factory = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
    //await deployer.deploy(VAMPReserves, reserveToken, VAMPProxy.address);
    await deployer.deploy(VAMPRebaser,
        VAMP.address,
        reserveToken,
        uniswap_factory
    );

    let rebase = new web3.eth.Contract(VAMPRebaser.abi, VAMPRebaser.address);
    let pair = await rebase.methods.uniswap_pair().call();
    console.log("Uniswap Pair: ", pair)
    // set rebaser address
    let VAMPToken = await VAMP.deployed();
    await VAMPToken.setRebaser(VAMPRebaser.address);

}
