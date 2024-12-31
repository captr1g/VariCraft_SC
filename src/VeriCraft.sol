// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract ArtistProfile {
    error invalidInput();
    error invalidUserName();
    error invalidUser();
    address owner;

    constructor(address _owner){
        if(_owner == address(0x0)) revert invalidInput();
        owner = _owner;
    }
    struct Artist {
        string signature;      // ZK or other signature
        bytes32 username;       // Username of the artist
        address walletAddress; // Wallet address of the artist
        uint256 timestamp;     // Timestamp of the record
    }

    // Mapping to store artist data by wallet address
    mapping(address => Artist) private artists;

    // Function to save artist details
    function saveArtist(
        string memory _signature,
        bytes32  _username,
        address _walletAddress,
        uint256 _timestamp
    ) public {
        if(_timestamp == 0) revert invalidInput();
        if(_walletAddress == address(0x0)) revert invalidInput();
        if(_username.length == 0) revert invalidUserName();
        if(bytes(_signature).length == 0) revert invalidInput();

        // Save the artist details
        artists[_walletAddress] = Artist({
            signature: _signature,
            username: _username,
            walletAddress: _walletAddress,
            timestamp: _timestamp
        });
    }

    // Function to retrieve artist's username using their wallet address
    function getArtistUsername(address _walletAddress) public view returns (bytes32) {
        if(_walletAddress == address(0x0)) revert invalidInput();
        if(artists[_walletAddress].username.length == 0) revert invalidUser();

        return artists[_walletAddress].username;
    }
}
