// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./Counters.sol";


/**
 * @title Upload
 * @dev This contract handles file uploads by managing metadata and associating files with their hashes.
 */
contract Upload is AccessControl {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using Counters for Counters.Counter;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPLOADER_ROLE = keccak256("UPLOADER_ROLE");

    // Structure to store file metadata
    struct FileMetadata {
        bytes32 fileHash;
        string fileName;
        string fileType;
        uint256 fileSize; // Size in bytes
        uint256 uploadTimestamp;
    }

    // Mapping from file ID to file metadata
    mapping(bytes32 => FileMetadata) private _fileMetadata;

    // Set of file IDs
    EnumerableSet.Bytes32Set private _fileIds;

    // File ID counter
    Counters.Counter private _fileIdCounter;

    event FileUploaded(bytes32 indexed fileId, string fileName, string fileType, uint256 fileSize, uint256 uploadTimestamp);
    event FileMetadataUpdated(bytes32 indexed fileId, string fileName, string fileType, uint256 fileSize);
    event FileRemoved(bytes32 indexed fileId);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(UPLOADER_ROLE, msg.sender);
    }

    /**
     * @dev Allows an uploader to upload a file with its metadata.
     * @param fileHash The hash of the file.
     * @param fileName The name of the file.
     * @param fileType The type/extension of the file.
     * @param fileSize The size of the file in bytes.
     */
    function uploadFile(
        bytes32 fileHash,
        string calldata fileName,
        string calldata fileType,
        uint256 fileSize
    ) external onlyRole(UPLOADER_ROLE) {
        require(!_fileIds.contains(fileHash), "Upload: File already uploaded");

        // Generate a new file ID
        bytes32 fileId = fileHash;

        // Store file metadata
        _fileMetadata[fileId] = FileMetadata({
            fileHash: fileHash,
            fileName: fileName,
            fileType: fileType,
            fileSize: fileSize,
            uploadTimestamp: block.timestamp
        });
        _fileIds.add(fileId);

        emit FileUploaded(fileId, fileName, fileType, fileSize, block.timestamp);
    }

    /**
     * @dev Updates metadata for a given file ID.
     * @param fileId The ID of the file.
     * @param fileName The new name of the file.
     * @param fileType The new type/extension of the file.
     * @param fileSize The new size of the file in bytes.
     */
    function updateFileMetadata(
        bytes32 fileId,
        string calldata fileName,
        string calldata fileType,
        uint256 fileSize
    ) external onlyRole(ADMIN_ROLE) {
        require(_fileIds.contains(fileId), "Upload: File not found");

        FileMetadata storage metadata = _fileMetadata[fileId];
        metadata.fileName = fileName;
        metadata.fileType = fileType;
        metadata.fileSize = fileSize;

        emit FileMetadataUpdated(fileId, fileName, fileType, fileSize);
    }

    /**
     * @dev Removes a file and its metadata.
     * @param fileId The ID of the file to remove.
     */
    function removeFile(bytes32 fileId) external onlyRole(ADMIN_ROLE) {
        require(_fileIds.contains(fileId), "Upload: File not found");

        delete _fileMetadata[fileId];
        _fileIds.remove(fileId);

        emit FileRemoved(fileId);
    }

    /**
     * @dev Retrieves metadata for a given file ID.
     * @param fileId The ID of the file.
     * @return The file metadata.
     */
    function getFileMetadata(bytes32 fileId) external view returns (FileMetadata memory) {
        require(_fileIds.contains(fileId), "Upload: File not found");

        return _fileMetadata[fileId];
    }

    /**
     * @dev Checks if a file ID exists.
     * @param fileId The ID of the file.
     * @return True if the file exists, false otherwise.
     */
    function fileExists(bytes32 fileId) external view returns (bool) {
        return _fileIds.contains(fileId);
    }

    /**
     * @dev Returns the total number of files.
     * @return The number of files.
     */
    function totalFiles() external view returns (uint256) {
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
