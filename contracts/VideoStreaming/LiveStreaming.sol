// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract LiveStreaming {
    event StreamStarted(address indexed user, string streamKey);
    event StreamStopped(address indexed user, string streamKey);

    function startStream(string memory streamKey) external {
        emit StreamStarted(msg.sender, streamKey);
    }

    function stopStream(string memory streamKey) external {
        emit StreamStopped(msg.sender, streamKey);
    }
}
