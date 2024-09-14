// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract DIDIntegration {
    mapping(address => string) public didRegistry;
    event DIDRegistered(address indexed user, string did);

    function registerDID(string calldata did) external {
        didRegistry[msg.sender] = did;
        emit DIDRegistered(msg.sender, did);
    }

    function getDID(address user) external view returns (string memory) {
        return didRegistry[user];
    }
}
