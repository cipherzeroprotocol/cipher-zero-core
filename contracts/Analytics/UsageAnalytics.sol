// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract UsageAnalytics {
    mapping(address => uint256) public dataUsage;
    event UsageRecorded(address indexed user, uint256 amount);

    function recordUsage(address user, uint256 amount) external {
        dataUsage[user] += amount;
        emit UsageRecorded(user, amount);
    }

    function getUsage(address user) external view returns (uint256) {
        return dataUsage[user];
    }
}
