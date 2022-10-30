// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ColorPaletteRepository {
    uint256 public insertColorPaletteFee = 1000000;
    address public owner;
    uint256 public balance;

    mapping(uint256 => bytes12[]) colorPalettes;
    string[] public colorIndex;

    constructor() {
        owner = msg.sender;
    }

    function setOwner(address to) public {
        require(msg.sender == owner, "Not the owner");
        owner = to;
    }

    function insertColorPalette(bytes12[] memory newPalette, string calldata name)
        public
        payable
    {
        require((msg.value >= insertColorPaletteFee));
        balance += msg.value;
        colorPalettes[colorIndex.length] = newPalette;
        colorIndex.push(name);
    }

    function getColorPalette(uint256 index) public view returns (bytes12[] memory) {
        return colorPalettes[index];
    }

    function getColorPaletteIndex() public view returns (string[] memory) {
        return colorIndex;
    }

    function withdraw() public payable {
        require(msg.sender == owner, "Not the owner");
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "transaction failed");
        balance = 0;
    }

    function setInsertColorFee(uint256 amount) public {
        require(msg.sender == owner);
        insertColorPaletteFee = amount;
    }
}
