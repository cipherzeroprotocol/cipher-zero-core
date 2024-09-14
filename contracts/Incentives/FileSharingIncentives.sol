// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract FileSharingIncentives {
    mapping(address => uint256) public rewards;
    event RewardGiven(address indexed user, uint256 amount);

    function rewardUser(address user, uint256 amount) external {
        rewards[user] += amount;
        emit RewardGiven(user, amount);
    }

    function claimRewards() external {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards to claim");
        rewards[msg.sender] = 0;
        // Transfer tokens logic
    }
}
