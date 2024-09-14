// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract EscrowServices {
    mapping(address => uint256) public deposits;
    event Deposited(address indexed user, uint256 amount);
    event Released(address indexed user, uint256 amount);

    function deposit() external payable {
        deposits[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function release(address payable user) external {
        uint256 amount = deposits[user];
        require(amount > 0, "No funds to release");
        deposits[user] = 0;
        user.transfer(amount);
        emit Released(user, amount);
    }
}
