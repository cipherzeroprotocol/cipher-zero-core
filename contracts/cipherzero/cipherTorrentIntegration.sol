// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./interfaces/IBitTorrent.sol";

contract BitTorrentIntegration is IBitTorrent {
    mapping(address => string[]) private userFiles;

    function uploadFile(string calldata fileHash) external override {
        userFiles[msg.sender].push(fileHash);
    }

    function getFiles(address user) external view override returns (string[] memory) {
        return userFiles[user];
    }
}
