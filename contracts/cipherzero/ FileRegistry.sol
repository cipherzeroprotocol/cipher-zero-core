// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

contract FileRegistry {
    struct File {
        string fileName;
        string fileHash;
        address owner;
        uint256 timestamp;
    }

    mapping(uint256 => File) private files;
    uint256 private fileCount;

    event FileRegistered(uint256 indexed fileId, string fileName, string fileHash, address indexed owner);

    function registerFile(string memory _fileName, string memory _fileHash) public {
        fileCount++;
        files[fileCount] = File(_fileName, _fileHash, msg.sender, block.timestamp);
        emit FileRegistered(fileCount, _fileName, _fileHash, msg.sender);
    }

    function getFile(uint256 _fileId) public view returns (string memory, string memory, address, uint256) {
        File memory file = files[_fileId];
        return (file.fileName, file.fileHash, file.owner, file.timestamp);
    }

    function getFileCount() public view returns (uint256) {
        return fileCount;
    }
}
