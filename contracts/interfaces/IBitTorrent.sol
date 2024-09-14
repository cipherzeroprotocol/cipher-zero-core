// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IBitTorrent {
    function uploadFile(string calldata fileHash) external;
    function getFiles(address user) external view returns (string[] memory);
}
