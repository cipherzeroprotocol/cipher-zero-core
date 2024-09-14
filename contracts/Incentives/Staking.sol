// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Staking {
    mapping(address => uint256) public stakes;
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    function stake(uint256 amount) external {
        stakes[msg.sender] += amount;
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(stakes[msg.sender] >= amount, "Insufficient stake");
        stakes[msg.sender] -= amount;
        emit Unstaked(msg.sender, amount);
    }
}
