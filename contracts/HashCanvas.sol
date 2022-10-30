// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract HashCanvas {
    event CanvasChange();
    address public owner;
    uint256 public balance;
    uint256 public setFee = 1000000;
    bytes32[128] public bitMap;
    string public backgroundColor = "2a132f";

    constructor() {
        owner = msg.sender;
    }

    function withdraw() public payable {
        require(msg.sender == owner, "Not the owner");
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "transaction failed");
        balance = 0;
    }

    function setOwner(address to) public {
        require(msg.sender == owner, "Not the owner");
        owner = to;
    }

    function setFeeValue(uint256 amount) public {
        require(msg.sender == owner);
        setFee = amount;
    }

    function getMap() public view returns (bytes32[128] memory) {
        return bitMap;
    }

    function setFive(uint256[5] memory indexes, bytes32[5] memory values)
        public
        payable
    {
        require(msg.value >= setFee, "Fee required");
        require(indexes.length == 5);
        require(values.length == 5);
        balance += msg.value;
        bitMap[indexes[0]] = values[0];
        bitMap[indexes[1]] = values[1];
        bitMap[indexes[2]] = values[2];
        bitMap[indexes[3]] = values[3];
        bitMap[indexes[4]] = values[4];
    }
}
