pragma solidity ^0.8.0;

contract Governance {
    struct Proposal {
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        address proposer;
    }

    address public owner;
    uint256 public totalProposals;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public votes;

    event ProposalCreated(uint256 proposalId, string description);
    event Voted(uint256 proposalId, address voter, bool voteFor);
    event ProposalExecuted(uint256 proposalId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier hasNotVoted(uint256 proposalId) {
        require(votes[msg.sender] != proposalId, "You have already voted for this proposal");
        _;
    }

    constructor() {
        owner = msg.sender;
        totalProposals = 0;
    }

    function createProposal(string calldata description) external onlyOwner {
        totalProposals++;
        Proposal storage newProposal = proposals[totalProposals];
        newProposal.description = description;
        newProposal.proposer = msg.sender;
        newProposal.executed = false;
        newProposal.votesFor = 0;
        newProposal.votesAgainst = 0;

        emit ProposalCreated(totalProposals, description);
    }

    function vote(uint256 proposalId, bool voteFor) external hasNotVoted(proposalId) {
        require(proposalId <= totalProposals && proposalId > 0, "Invalid proposalId");

        Proposal storage proposal = proposals[proposalId];

        if(voteFor) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        votes[msg.sender] = proposalId;

        emit Voted(proposalId, msg.sender, voteFor);
    }

    function executeProposal(uint256 proposalId) external onlyOwner {
        require(proposalId <= totalProposals && proposalId > 0, "Invalid proposalId");

        Proposal storage proposal = proposals[proposalId];

        require(!proposal.executed, "Proposal already executed");

        if(proposal.votesFor > proposal.votesAgainst) {
            proposal.executed = true;
            emit ProposalExecuted(proposalId);
        }
    }
}

