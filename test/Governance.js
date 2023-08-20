const Governance = artifacts.require("Governance");

contract("Governance", (accounts) => {
    let governance;
    const owner = accounts[0];
    const voter1 = accounts[1];
    const voter2 = accounts[2];

    beforeEach(async () => {
        governance = await Governance.new();
    });

    it("should create a proposal", async () => {
        await governance.createProposal("Test proposal", {from: owner});
        const proposal = await governance.proposals(1);
        assert.equal(proposal.description, "Test proposal");
        assert.equal(proposal.proposer, owner);
    });

    it("should allow voting on proposals", async () => {
        await governance.createProposal("Test proposal", {from: owner});
        await governance.vote(1, true, {from: voter1});
        await governance.vote(1, false, {from: voter2});

        const proposal = await governance.proposals(1);
        assert.equal(proposal.votesFor, 1);
        assert.equal(proposal.votesAgainst, 1);
    });

    it("should execute a proposal", async () => {
        await governance.createProposal("Test proposal", {from: owner});
        await governance.vote(1, true, {from: voter1});
        await governance.vote(1, true, {from: voter2});
        await governance.executeProposal(1, {from: owner});

        const proposal = await governance.proposals(1);
        assert.equal(proposal.executed, true);
    });
});

