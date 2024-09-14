// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./_setupRole.sol";
/**
 * @title AuditLogger
 * @dev This contract logs and tracks important security events and actions.
 */
contract AuditLogger is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    event SecurityEventLogged(
        address indexed actor,
        string action,
        uint256 timestamp,
        bytes details
    );

    // Mapping to store logs by action type
    mapping(string => bytes[]) private actionLogs;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(AUDITOR_ROLE, msg.sender);
    }

    /**
     * @dev Log a security event with relevant details.
     * @param action A string describing the action that occurred.
     * @param details Additional details about the action, encoded as bytes.
     */
    function logSecurityEvent(string memory action, bytes memory details) external onlyRole(AUDITOR_ROLE) {
        emit SecurityEventLogged(msg.sender, action, block.timestamp, details);
        actionLogs[action].push(details);
    }

    /**
     * @dev Retrieve logs for a specific action type.
     * @param action The action type to retrieve logs for.
     * @return An array of bytes containing the logs for the specified action type.
     */
    function getActionLogs(string memory action) external view returns (bytes[] memory) {
        return actionLogs[action];
    }

    /**
     * @dev Grant the auditor role to a new account.
     * @param account The account to grant the auditor role to.
     */
    function grantAuditorRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(AUDITOR_ROLE, account);
    }

    /**
     * @dev Revoke the auditor role from an account.
     * @param account The account to revoke the auditor role from.
     */
    function revokeAuditorRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(AUDITOR_ROLE, account);
    }

    /**
     * @dev Check if an account has the auditor role.
     * @param account The account to check.
     * @return True if the account has the auditor role, false otherwise.
     */
    function hasAuditorRole(address account) external view returns (bool) {
        return hasRole(AUDITOR_ROLE, account);
    }
}
