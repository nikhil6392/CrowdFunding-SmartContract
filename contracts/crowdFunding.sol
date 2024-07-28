//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract CrowdFunding{
    address public owner;
    uint public goal;
    uint public deadline;
    uint public fundRaised;
    mapping (address=>uint) public contributions;

    modifier onlyOwner(){
        require(msg.sender==owner,"Only Owner can call this function");
        _;
    }

    modifier beforeDeadline(){
        require(block.timestamp<deadline,"Deadline has passed");
        _;
    }

    modifier afterDeadline(){
        require(block.timestamp>=deadline,"Deadline has not passed yet");
        _;
    }

    event ContributionReceived(address contributor,uint amount);
    event GoalReached(uint totalAmounrRaised);
    event RefundIssued(address recipient,uint amount);

    constructor(uint _goal,uint _duration){
        owner=msg.sender;
        goal=_goal;
        deadline=block.timestamp+_duration;
    }

    function contribute() public payable beforeDeadline{
        require(msg.value>0,"Contribution must be greater than zero");
        contributions[msg.sender]+=msg.value;
        fundRaised+=msg.value;
        emit ContributionReceived(msg.sender, msg.value);
    }

    function withdrawFunds() public onlyOwner afterDeadline {
        require(fundRaised>=goal,"Funding goal is not reached");
        payable(owner).transfer(address(this).balance);
        emit GoalReached(fundRaised);
    }

    function requestRefund() public afterDeadline {
        require(fundRaised<goal,"Funding goal is reached no refund");
        uint contributedAmount=contributions[msg.sender];
        require(contributedAmount>0,"No Funds to refund");
        contributions[msg.sender]=0;
        payable(msg.sender).transfer(contributedAmount);
        emit RefundIssued(msg.sender, contributedAmount);
    }
}