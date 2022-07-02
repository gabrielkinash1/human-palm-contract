// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../src/HumanPalm.sol";
import "los-bears-contract/contracts/LosBears.sol";

contract HumanPalmTest is Test {
    HumanPalm private humanPalm;
    LosBears private losBears;

    function setUp() public {
        // Deploy Los Bears
        losBears = new LosBears();
        // Deploy Human Palm
        humanPalm = new HumanPalm("human.palm/token/", address(losBears));
    }

    function testPresaleMint() public {
        uint256 quantity = humanPalm.maxDuringPresale();
        losBears.give(msg.sender, 1);
        humanPalm.startPresale();
        // Mint
        vm.prank(msg.sender);
        humanPalm.presaleMint(quantity);
        assertEq(humanPalm.balanceOf(msg.sender), quantity);
    }

    function testFailPresaleMintWhenPaused() public {
        uint256 quantity = humanPalm.maxDuringPresale();
        losBears.give(msg.sender, 1);
        humanPalm.startPresale();
        // Pause
        humanPalm.togglePause();
        // Mint
        vm.prank(msg.sender);
        humanPalm.presaleMint(quantity);
        assertEq(humanPalm.balanceOf(msg.sender), quantity);
    }

    function testFailPresaleMint1Above() public {
        // Quantity higher than max permitted per wallet during presale
        uint256 quantity = humanPalm.maxDuringPresale() + 1;
        losBears.give(msg.sender, 1);
        humanPalm.startPresale();
        // Mint
        vm.prank(msg.sender);
        humanPalm.presaleMint(quantity);
        assertEq(humanPalm.balanceOf(msg.sender), quantity);
    }

    function testFailPresaleMintAfterPresale() public {
        uint256 quantity = humanPalm.maxDuringPresale();
        losBears.give(msg.sender, 1);
        humanPalm.startPresale();
        // Skip Presale
        vm.warp(block.timestamp + 20 minutes);
        // Mint
        vm.prank(msg.sender);
        humanPalm.presaleMint(quantity);
        assertEq(humanPalm.balanceOf(msg.sender), quantity);
    }

    function testPublicMint() public {
        uint256 quantity = humanPalm.maxDuringSale();
        humanPalm.startPresale();
        // Skip Presale
        vm.warp(block.timestamp + 20 minutes);
        // Mint
        vm.prank(msg.sender);
        humanPalm.mint(quantity);
        assertEq(humanPalm.balanceOf(msg.sender), quantity);
    }

    function testFailPublicMintWhenPaused() public {
        uint256 quantity = humanPalm.maxDuringSale();
        humanPalm.startPresale();
        // Skip Presale
        vm.warp(block.timestamp + 20 minutes);
        // Pause
        humanPalm.togglePause();
        // Mint
        vm.prank(msg.sender);
        humanPalm.mint(quantity);
        assertEq(humanPalm.balanceOf(msg.sender), quantity);
    }

    function testFailPublicMint1Above() public {
        // Quantity higher than max permitted per wallet during public sale
        uint256 quantity = humanPalm.maxDuringSale() + 1;
        humanPalm.startPresale();
        // Skip Presale
        vm.warp(block.timestamp + 20 minutes);
        // Mint
        vm.prank(msg.sender);
        humanPalm.mint(quantity);
        assertEq(humanPalm.balanceOf(msg.sender), quantity);
    }

    function testFailPublicMintDuringPresale() public {
        uint256 quantity = humanPalm.maxDuringSale();
        humanPalm.startPresale();
        // Mint
        vm.prank(msg.sender);
        humanPalm.mint(quantity);
        assertEq(humanPalm.balanceOf(msg.sender), quantity);
    }
}