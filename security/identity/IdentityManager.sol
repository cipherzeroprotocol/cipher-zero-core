// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712Domain.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./_setupRole.sol";
/**
 * @title IdentityManager
 * @dev This contract manages identities using Decentralized Identifiers (DIDs) and associated metadata.
contract IdentityManager is AccessControl, EIP712Domain {
contract IdentityManager is AccessControl {
    using ECDSA for bytes32;
    using Strings for string;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VERIFY_ROLE = keccak256("VERIFY_ROLE");

    // Event emitted when a DID is registered
    event DIDRegistered(string did, address owner);

    // Event emitted when a DID's metadata is updated
    event DIDMetadataUpdated(string did, string metadata);

    // Mapping from DID to the owner address
    mapping(string => address) private _didOwners;

    // Mapping from DID to metadata
    mapping(string => string) private _didMetadata;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Register a new DID and associate it with the caller's address.
     * @param did The DID to register.
     * @param metadata Metadata associated with the DID.
     */
    function registerDID(string calldata did, string calldata metadata) external {
        require(!_exists(did), "IdentityManager: DID already registered");
        _didOwners[did] = msg.sender;
        _didMetadata[did] = metadata;
        emit DIDRegistered(did, msg.sender);
    }

    /**
     * @dev Update the metadata for an existing DID.
     * @param did The DID to update.
     * @param metadata The new metadata.
     */
    function updateDIDMetadata(string calldata did, string calldata metadata) external {
        require(_exists(did), "IdentityManager: DID not found");
        require(_didOwners[did] == msg.sender, "IdentityManager: Only the DID owner can update metadata");
        _didMetadata[did] = metadata;
        emit DIDMetadataUpdated(did, metadata);
    }

    /**
     * @dev Retrieve the owner of a DID.
     * @param did The DID to query.
     * @return The address of the DID owner.
     */
    function getDIDOwner(string calldata did) external view returns (address) {
        require(_exists(did), "IdentityManager: DID not found");
        return _didOwners[did];
    }

    /**
     * @dev Retrieve the metadata associated with a DID.
     * @param did The DID to query.
     * @return The metadata associated with the DID.
     */
    function getDIDMetadata(string calldata did) external view returns (string memory) {
        require(_exists(did), "IdentityManager: DID not found");
        return _didMetadata[did];
    }

    /**
     * @dev Verify the authenticity of a DID signature.
     * @param did The DID associated with the signature.
     * @param signature The signature to verify.
     * @param message The message that was signed.
     * @return True if the signature is valid, false otherwise.
     */
    function verifyDIDSignature(string calldata did, bytes calldata signature, string calldata message) external view onlyRole(VERIFY_ROLE) returns (bool) {
        address owner = _didOwners[did];
        bytes32 messageHash = EIP712.hashMessage(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(bytes(message).length), message)));
        return messageHash.recover(signature) == owner;
    }

    /**
     * @dev Check if a DID exists.
     * @param did The DID to check.
     * @return True if the DID exists, false otherwise.
     */
    function _exists(string calldata did) internal view returns (bool) {
        return _didOwners[did] != address(0);
    }

    /**
     * @dev Grant the verify role to an account.
     * @param account The account to grant the verify role to.
     */
    function grantVerifyRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(VERIFY_ROLE, account);
    }

    /**
     * @dev Revoke the verify role from an account.
     * @param account The account to revoke the verify role from.
     */
    function revokeVerifyRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(VERIFY_ROLE, account);
    }

    /**
     * @dev Check if an account has the verify role.
     * @param account The account to check.
     * @return True if the account has the verify role, false otherwise.
     */
    function hasVerifyRole(address account) external view returns (bool) {
        return hasRole(VERIFY_ROLE, account);
    }
}
