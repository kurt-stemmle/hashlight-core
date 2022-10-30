// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Hashlight {
    struct Report {
        address sender;
        string message;
    }

    address public owner;
    uint256 public balance;
    uint256 public repUpFee = 200000000000000;
    uint256 public repDownFee = 400000000000000;
    uint256 public reviewFee = 1000000000000000;
    uint256 public descriptonFee = 1000000000000000;
    mapping(address => int256) memberRep;
    mapping(address => Report[]) reports;
    mapping(address => string) accountDescription;

    constructor() {
        owner = msg.sender;
    }

    function withdraw() public payable {
        require(msg.sender == owner, "Not the owner");
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "transaction failed");
        balance = 0;
    }

    function setUpFee(uint256 amount) public {
        require(msg.sender == owner, "Not the owner");
        repUpFee = amount;
    }

    function setDownFee(uint256 amount) public {
        require(msg.sender == owner, "Not the owner");
        repDownFee = amount;
    }

    function setReviewFee(uint256 amount) public {
        require(msg.sender == owner, "Not the owner");
        reviewFee = amount;
    }

    function setDescription(string memory description) public payable {
        require(msg.value >= descriptonFee);
        balance += msg.value;
        accountDescription[msg.sender] = description;
    }

    function getAccountDescription(address account)
        public
        view
        returns (string memory)
    {
        return accountDescription[account];
    }

    function getReports(address account) public view returns (Report[] memory) {
        return reports[account];
    }

    function getRep(address acount) public view returns (int256) {
        return memberRep[acount];
    }

    function setOwner(address newOwner) public {
        require(msg.sender == owner, "Not the owner");
        owner = newOwner;
    }

    function insertReport(address account, string memory reason)
        public
        payable
    {
        require(msg.value >= reviewFee);
        balance += msg.value;
        reports[account].push(Report({message: reason, sender: msg.sender}));
    }

    function setRepUpOne(address account) public payable {
        require(msg.value >= repUpFee);
        balance += msg.value;
        memberRep[account] += 1;
    }

    function setRepDownOne(address account) public payable {
        require(msg.value >= repDownFee);
        balance += msg.value;
        memberRep[account] -= 1;
    }
}
