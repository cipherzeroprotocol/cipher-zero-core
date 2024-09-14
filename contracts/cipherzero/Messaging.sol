// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./interfaces/IMessaging.sol";

contract Messaging is IMessaging {
    struct Message {
        address sender;
        string content;
    }

    mapping(address => Message[]) private messages;

    function sendMessage(address _to, string calldata _message) external override {
        messages[_to].push(Message(msg.sender, _message));
    }

    function getMessages(address _address) external view override returns (Message[] memory) {
        return messages[_address];
    }
}
