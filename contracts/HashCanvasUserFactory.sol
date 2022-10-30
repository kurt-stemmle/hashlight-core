// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./HashCanvasUser.sol";
import "./lib/NoDelegateCall.sol";

contract HashCanvasUserFactory is NoDelegateCall {
    uint256 public createCanvasFee = 1000000;
    address public owner;
    uint256 public balance;
    mapping(address => bool) canvasLookUp;
    mapping(address => address[]) usersCanvases;

    address public audioPaletteRepoAddress;
    address public colorPaletteRepoAddress;

    constructor(address audioPalette, address colorPalette) {
        owner = msg.sender;
        audioPaletteRepoAddress = audioPalette;
        colorPaletteRepoAddress = colorPalette;
    }

    function setColorPaletteAddress(address to) public {
        require(msg.sender == owner, "Not the owner");
        colorPaletteRepoAddress = to;
    }

    function setAudiopaletteAddress(address to) public {
        require(msg.sender == owner, "Not the owner");
        audioPaletteRepoAddress = to;
    }

    function setOwner(address to) public {
        require(msg.sender == owner, "Not the owner");
        owner = to;
    }

    function withdraw() public payable {
        require(msg.sender == owner, "Not the owner");
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "transaction failed");
        balance = 0;
    }

    function setCanvasFee(uint256 amount) public {
        require(msg.sender == owner);
        createCanvasFee = amount;
    }

    function getUserCanvases(address who)
        public
        view
        returns (address[] memory)
    {
        return usersCanvases[who];
    }

    function createCanvas(string memory name, string memory symbol)
        public
        payable
        noDelegateCall
    {
        require((msg.value >= createCanvasFee));
        balance += msg.value;
        address canvasAddress = address(
            new HashCanvasUser(name, symbol, msg.sender, address(this), audioPaletteRepoAddress, colorPaletteRepoAddress)
        );
        canvasLookUp[canvasAddress] = true;
        usersCanvases[msg.sender].push(canvasAddress);
    }

}
