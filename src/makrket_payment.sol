// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ArtMarketplace {

    address payable public owner;
    uint256 public platformFeePercentage;
    uint256 public totalFeesCollected; // Tracks total fees collected
    uint256 public lastFeeCollected;   // Tracks the last fee collected

    event PaymentProcessed(address indexed artist, address indexed buyer, uint256 amount, uint256 platformFee);
    event PlatformFeePercentageUpdated(uint256 newPercentage);

    constructor(uint256 _platformFeePercentage) {
        owner = payable(msg.sender);
        platformFeePercentage = _platformFeePercentage;
        require(_platformFeePercentage <= 100, "Platform fee cannot exceed 100%");
        totalFeesCollected = 0; // Initialize total fees
        lastFeeCollected = 0;   // Initialize last fee
    }

    function setPlatformFeePercentage(uint256 _platformFeePercentage) public onlyOwner {
        require(_platformFeePercentage <= 100, "Platform fee cannot exceed 100%");
        platformFeePercentage = _platformFeePercentage;
        emit PlatformFeePercentageUpdated(_platformFeePercentage);
    }

    function purchaseArt(address payable artist) public payable {
        require(msg.value > 0, "Payment must be greater than zero.");

        uint256 platformFee = (msg.value * platformFeePercentage) / 100;
        uint256 artistPayment = msg.value - platformFee;

        // Transfer funds
        (bool successArtist, ) = artist.call{value: artistPayment}("");
        require(successArtist, "Artist payment failed.");

        (bool successOwner, ) = owner.call{value: platformFee}("");
        require(successOwner, "Platform fee transfer failed.");

        // Update fee tracking
        totalFeesCollected += platformFee;
        lastFeeCollected = platformFee;

        emit PaymentProcessed(artist, msg.sender, msg.value, platformFee);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function withdraw() public onlyOwner {
        totalFeesCollected -= address(this).balance;
        (bool success, ) = owner.call{value: address(this).balance}("");
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