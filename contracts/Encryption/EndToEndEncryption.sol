// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract EndToEndEncryption {
    mapping(address => string) private keys;

    function setPublicKey(string memory publicKey) external {
        keys[msg.sender] = publicKey;
    }

    function getPublicKey(address user) external view returns (string memory) {
        return keys[user];
    }
}
