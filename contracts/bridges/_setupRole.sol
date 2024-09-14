// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title RoleManager
 * @dev Role-based access control contract with detailed setup
 */
contract RoleManager is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    /**
     * @dev Constructor that sets up initial roles
     */
    constructor(address admin, address manager, address user) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(MANAGER_ROLE, manager);
        _grantRole(USER_ROLE, user);
    }

    /**
     * @dev Function to add a new role with specified account
     */
    function addRole(bytes32 role, address account) external onlyRole(ADMIN_ROLE) {
        grantRole(role, account);
    }

    /**
     * @dev Function to remove a role from a specified account
     */
    function removeRole(bytes32 role, address account) external onlyRole(ADMIN_ROLE) {
        revokeRole(role, account);
    }

    /**
     * @dev Function to check if an account has a specific role
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return super.hasRole(role, account);
    }

    /**
     * @dev Function to renounce a role by the caller
     */
    function renounceRole(bytes32 role) public  {
        super.renounceRole(role, msg.sender);
    }
}
