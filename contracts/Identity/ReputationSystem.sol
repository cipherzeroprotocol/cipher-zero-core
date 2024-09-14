// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract ReputationSystem {
    mapping(address => uint256) public reputation;
    event ReputationUpdated(address indexed user, uint256 newReputation);

    function updateReputation(address user, uint256 change) external {
        reputation[user] += change;
        emit ReputationUpdated(user, reputation[user]);
    }

    function getReputation(address user) external view returns (uint256) {
        return reputation[user];
    }
}
