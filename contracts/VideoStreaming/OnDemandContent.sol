// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract OnDemandContent {
    event ContentUploaded(address indexed user, string contentId);
    event ContentMonetized(address indexed user, string contentId, uint256 amount);

    function uploadContent(string memory contentId) external {
        emit ContentUploaded(msg.sender, contentId);
    }

    function monetizeContent(string memory contentId, uint256 amount) external {
        emit ContentMonetized(msg.sender, contentId, amount);
    }
}
