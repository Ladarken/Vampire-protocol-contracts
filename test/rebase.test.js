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
        let tx = await vampToken.transfer(accounts[1], expectedTokenAmt.toString(), {from: accounts[0]});
        // console.log(tx.logs[0]);

        // then - my balance should be
        let actualAmt1 = await vampToken.balanceOf.call(accounts[1], {from: accounts[1]});
        expect(actualAmt1).to.be.a.bignumber.that.equals(expectedTokenAmt, "Balance mismatch for account");
    });

    it('Vamp Token should rebase - +ve value', async () => {
        // given I have a basic total
        let origTotalSupply = await vampToken.totalSupply();
        let newDeltaAmt = new BN('55555');

        // when I have the rebaser account configured
        await vampToken.setRebaser(accounts[3]);
        // and I add some new rebase delta
        let newTotalSupply = await vampToken.rebase.call(newDeltaAmt, {from: accounts[3]});
        // console.log(origTotalSupply.toString(), " :: ", newTotalSupply.toString());

        // then I should get a new amount
        expect(newTotalSupply).to.be.a.bignumber.that.equals(origTotalSupply.add(newDeltaAmt), "Rebase broken");
        // and the totals for each person should be altered too...

    });

    it('Vamp Token should rebase - -ve value', async () => {
        // given I have a basic total
        let origTotalSupply = await vampToken.totalSupply();
        let newDeltaAmt = new BN('-55555');

        // when I have the rebaser account configured
        await vampToken.setRebaser(accounts[3]);
        // and I add some new rebase delta
        let newTotalSupply = await vampToken.rebase.call(newDeltaAmt, {from: accounts[3]});
        // console.log(origTotalSupply.toString(), " :: ", newTotalSupply.toString());

        // then I should get a new amount
        expect(newTotalSupply).to.be.a.bignumber.that.equals(origTotalSupply.add(newDeltaAmt), "Rebase broken");
        // and the totals for each person should be altered too...

    });

    it('should rebase VampToken Scenario 1 +Price, +Volume - 1%  ', async () => {
        assert.fail("Not Implemented");
    });


})