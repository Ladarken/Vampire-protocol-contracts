const Vamp = artifacts.require("VAMP")

contract("Test Vamp Deployed", async accounts => {
    it('should deploy successfully', async () => {
        let instance = await Vamp.deployed();
        let balance = await instance.getBalance.call(accounts[0]);
        assert.equal(balance.valueOf(), 10000);
    });
})