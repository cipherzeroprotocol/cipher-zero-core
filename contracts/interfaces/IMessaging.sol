// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

struct Message {
    // Define the properties of the Message struct
    uint256 id;
}

interface IMessaging {
    function sendMessage(address _to, string calldata _message) external;
    function getMessages(address _address) external view returns (Message[] memory);
}
