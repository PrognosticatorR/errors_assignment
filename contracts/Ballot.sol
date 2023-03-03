// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Ballot {
    struct Voter {
        uint weight;
        bool alreadyVoted;
        address delegate;
        uint vote;
    }

    struct Proposal {
        bytes32 name;
        uint voteCounts;
    }
    address public chairPerson;
    mapping(address => Voter) voters;
    Proposal[] public proposals;
    uint private winningProposal;
    bool public winnerDecalred = false;

    modifier onlyChairperson() {
        require(msg.sender == chairPerson, "Only chairperson can add to voters list.");
        _;
    }

    error AlreadyVotedError();
    error OutOfBoundAccessError();

    constructor(bytes32[] memory proposalNames) {
        chairPerson = msg.sender;
        voters[chairPerson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCounts: 0}));
        }
    }

    function addToVotersList(address voter) external onlyChairperson {
        require(!voters[voter].alreadyVoted, "Already submitted the vote.");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        require(sender.alreadyVoted == false);
        assert(to != msg.sender);

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender);
        }

        Voter storage delegate_ = voters[to];
        require(delegate_.weight >= 1);
        sender.alreadyVoted = true;
        sender.delegate = to;

        if (delegate_.alreadyVoted) {
            proposals[delegate_.vote].voteCounts += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no rights");
        if (sender.alreadyVoted == true) {
            revert AlreadyVotedError();
        }
        require(!winnerDecalred, "winner is alreday declared");
        sender.alreadyVoted = true;
        sender.vote = proposal;
        if (proposal < proposals.length) {
            revert OutOfBoundAccessError();
        }
        proposals[proposal].voteCounts += sender.weight;
        if (winningProposal == 0) {
            winningProposal = proposal += 1;
        } else if (proposals[proposal].voteCounts > proposals[winningProposal - 1].voteCounts) {
            winningProposal = proposal += 1;
        }
    }

    function decalreWinner() external onlyChairperson {
        winnerDecalred = true;
    }

    function winnerName() external view returns (bytes32 winnerName_) {
        require(winnerDecalred == true, "Winner is not decalred yet!");
        winnerName_ = proposals[winningProposal - 1].name;
    }
}
