// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./_setupRole.sol";
/**
 * @title HashStorage
 * @dev This contract is used to store and manage hashes for files or data. 
 * It allows storing and retrieving hashes securely.
 */
contract HashStorage is AccessControl {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Mapping from file ID to hash
    mapping(bytes32 => bytes32) private _fileHashes;

    // Set of file IDs
    EnumerableSet.Bytes32Set private _fileIds;

    event HashStored(bytes32 indexed fileId, bytes32 hash);
    event HashRemoved(bytes32 indexed fileId);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Stores a hash for a given file ID.
     * @param fileId Unique identifier for the file.
     * @param hash The hash of the file.
     */
    function storeHash(bytes32 fileId, bytes32 hash) external onlyRole(ADMIN_ROLE) {
        require(!_fileIds.contains(fileId), "HashStorage: Hash already exists for the file ID");
        
        _fileHashes[fileId] = hash;
        _fileIds.add(fileId);

        emit HashStored(fileId, hash);
    }

    /**
     * @dev Retrieves the hash for a given file ID.
     * @param fileId Unique identifier for the file.
     * @return The hash of the file.
     */
    function getHash(bytes32 fileId) external view returns (bytes32) {
        require(_fileIds.contains(fileId), "HashStorage: Hash not found for the file ID");
        
        return _fileHashes[fileId];
    }

    /**
     * @dev Removes the hash for a given file ID.
     * @param fileId Unique identifier for the file.
     */
    function removeHash(bytes32 fileId) external onlyRole(ADMIN_ROLE) {
        require(_fileIds.contains(fileId), "HashStorage: Hash not found for the file ID");
        
        delete _fileHashes[fileId];
        _fileIds.remove(fileId);

        emit HashRemoved(fileId);
    }

    /**
     * @dev Checks if a file ID has a stored hash.
     * @param fileId Unique identifier for the file.
     * @return True if the hash exists, false otherwise.
     */
    function hasHash(bytes32 fileId) external view returns (bool) {
        return _fileIds.contains(fileId);
    }

    /**
     * @dev Returns the total number of file IDs stored.
     * @return The number of file IDs.
     */
    function totalFileIds() external view returns (uint256) {
        return _fileIds.length();
    }

    /**
     * @dev Returns a file ID at a specific index.
     * @param index The index of the file ID.
     * @return The file ID at the given index.
     */
    function fileIdAt(uint256 index) external view returns (bytes32) {
        return _fileIds.at(index);
    }
}
