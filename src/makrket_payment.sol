// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtMarketplace is ReentrancyGuard, Ownable {
    uint256 public platformFeePercentage;
    uint256 public totalFeesCollected; // Tracks total fees collected
    uint256 public lastFeeCollected;   // Tracks the last fee collected

    event PaymentProcessed(address indexed artist, address indexed buyer, uint256 amount, uint256 platformFee);
    event PlatformFeePercentageUpdated(uint256 newPercentage);

    constructor(uint256 _platformFeePercentage) Ownable(msg.sender) {
        require(_platformFeePercentage <= 100, "Platform fee cannot exceed 100%");
        platformFeePercentage = _platformFeePercentage;
        totalFeesCollected = 0; // Initialize total fees
        lastFeeCollected = 0;   // Initialize last fee
    }

    // Only the owner can set the platform fee percentage
    function setPlatformFeePercentage(uint256 _platformFeePercentage) public onlyOwner {
        require(_platformFeePercentage <= 100, "Platform fee cannot exceed 100%");
        platformFeePercentage = _platformFeePercentage;
        emit PlatformFeePercentageUpdated(_platformFeePercentage);
    }

    function purchaseArt(address payable artist) public payable nonReentrant {
        require(msg.value > 0, "Payment must be greater than zero.");

        uint256 platformFee = (msg.value * platformFeePercentage) / 100;
        uint256 artistPayment = msg.value - platformFee;

        // Update fee tracking before transferring funds
        totalFeesCollected += platformFee;
        lastFeeCollected = platformFee;

        // Transfer funds
        artist.transfer(artistPayment);
        payable(owner()).transfer(platformFee);

        emit PaymentProcessed(artist, msg.sender, msg.value, platformFee);
    }

    // Only the owner can withdraw funds
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw.");

        totalFeesCollected -= balance; // Deduct from total fees collected
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdrawal failed.");
    }

    // Functions to view fee information
    function getTotalFeesCollected() public view returns (uint256) {
        return totalFeesCollected;
    }

    function getLastFeeCollected() public view returns (uint256) {
        return lastFeeCollected;
    }
}
