const Vamp = artifacts.require("VAMP")
const VampRebaser = artifacts.require("VAMPRebaser")

const chai = require('chai');
const BN = require('bn.js');
chai.use(require('chai-bn')(BN));
const expect = chai.expect;

// if we need to use the gons calcs
const GONS_PER_FRAGMENT = new BN("8421242853622996030805162546086393298419635248410222");

contract("Test Vamp Deployed", async accounts => {

    let vampToken;
    let rebaser;

    beforeEach(async () => {
        vampToken = await Vamp.deployed();
        assert.isNotNull(vampToken.address);
        rebaser = await VampRebaser.deployed();
        assert.isNotNull(rebaser.address);
        // console.log("Owner:", owner);
        // console.log(accounts);
    })

    it('should deploy successfully and owners set', async () => {
        // who's your daddy?
        let owner = await vampToken.owner.call();
        assert.equal(owner, accounts[0], "Vamp Token Owner doesn't match primary account");
        owner = await rebaser.gov.call();
        assert.equal(owner, accounts[0], "Vamp Rebase Owner doesn't match primary account");
    });

    it('should allow me to set and get balance for my account', async () => {
        // given
        let expectedTokenAmt = new BN('999666333');
        // console.log("amt: ", expectedTokenAmt.toString(), " plus gons:", expectedTokenAmt.mul(GONS_PER_FRAGMENT).toString());

        // when
        let tx = await vampToken.mint(accounts[1], expectedTokenAmt.toString(), {from: accounts[0]});
        // assert.isTrue(mintedOk, "Not minting properly");
        // debug if we change the call above to mint(...)
        // console.log(tx.logs[0]);

        // then - my balance should be
        // let totalSupply = await vampToken.totalSupply();
        // let actualAmt0 = await vampToken.balanceOf.call(accounts[0], {from: accounts[0]});
        let actualAmt1 = await vampToken.balanceOf.call(accounts[1], {from: accounts[1]});
        // console.log("Total supply: ", totalSupply.toString());
        // console.log("Actual Amounts: ", actualAmt0.toString(), "///", actualAmt1.toString());
        expect(actualAmt1).to.be.a.bignumber.that.equals(expectedTokenAmt, "Balance mismatch for account");
    });

    it('should be ready to rebase', async () => {
        assert.fail("Not Implemented");
    });

    it('should rebase VampToken Scenario 1 +Price, +Volume - 1%  ', async () => {
        assert.fail("Not Implemented");
    });


})