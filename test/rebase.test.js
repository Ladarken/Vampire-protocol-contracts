const Vamp = artifacts.require("VAMP")
const VampRebaser = artifacts.require("VAMPRebaser")

contract("Test Vamp Deployed", async accounts => {
    it('should deploy successfully', async () => {
        let vampToken = await Vamp.deployed();
        assert.isNotNull(vampToken.address);
        let rebaser = await VampRebaser.deployed();
        assert.isNotNull(rebaser.address);
    });
})