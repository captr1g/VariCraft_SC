// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract ArtistProfile {
    struct Artist {
        string signature;      // ZK or other signature
        string provider;       // Provider information
        string username;       // Username of the artist
        address walletAddress; // Wallet address of the artist
        uint256 timestamp;     // Timestamp of the record
    }

    // Mapping to store artist data by wallet address
    mapping(address => Artist) private artists;

    // Function to save artist details
    function saveArtist(
        string memory _signature,
        string memory _provider,
        string memory _username,
        address _walletAddress,
        uint256 _timestamp
    ) public {
        require(_walletAddress != address(0), "Invalid wallet address");
        require(bytes(_username).length > 0, "Username cannot be empty");

        // Save the artist details
        artists[_walletAddress] = Artist({
            signature: _signature,
            provider: _provider,
            username: _username,
            walletAddress: _walletAddress,
            timestamp: _timestamp
        });
    }

    // Function to retrieve artist's username using their wallet address
    function getArtistUsername(address _walletAddress) public view returns (string memory) {
        require(_walletAddress != address(0), "Invalid wallet address");
        require(bytes(artists[_walletAddress].username).length > 0, "Artist not found");

        return artists[_walletAddress].username;
    }
}
