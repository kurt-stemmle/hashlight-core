// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract AudioPaletteRepository {
    uint256 public insertAudioPaletteFee = 1000000;
    address public owner;
    uint256 public balance;

    mapping(uint256 => bytes12[]) audioPalettes;
    string[] public audioIndex;

    constructor() {
        owner = msg.sender;
    }

    function setOwner(address to) public {
        require(msg.sender == owner, "Not the owner");
        owner = to;
    }

    function insertAudioPalette(bytes12[] memory newPalette, string calldata name)
        public
        payable
    {
        require((msg.value >= insertAudioPaletteFee));
        balance += msg.value;
        audioPalettes[audioIndex.length] = newPalette;
        audioIndex.push(name);
    }

    function getAudioPalette(uint256 index) public view returns (bytes12[] memory) {
        require(index >= 0);
        require(index < audioIndex.length);
        return audioPalettes[index];
    }

    function getAudioPaletteIndex() public view returns (string[] memory) {
        return audioIndex;
    }

    function withdraw() public payable {
        require(msg.sender == owner, "Not the owner");
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "transaction failed");
        balance = 0;
    }

    function setInsertAudioFee(uint256 amount) public {
        require(msg.sender == owner);
        insertAudioPaletteFee = amount;
    }
}
