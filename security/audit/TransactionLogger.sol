// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


import "@openzeppelin/contracts/access/AccessControl.sol";
import "./_setupRole.sol";
/**
 * @title TransactionLogger
 * @dev This contract logs transaction details for auditing and monitoring purposes.
 */
contract TransactionLogger is AccessControl {
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    event TransactionLogged(
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        uint256 timestamp,
        bytes details
    );

    // Mapping to store transaction logs
    mapping(uint256 => Transaction) private transactions;
    uint256 private transactionCount;

    struct Transaction {
        address sender;
        address receiver;
        uint256 amount;
        uint256 timestamp;
        bytes details;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(AUDITOR_ROLE, msg.sender);
    }

    /**
     * @dev Log a transaction with relevant details.
     * @param receiver The recipient of the transaction.
     * @param amount The amount transferred.
     * @param details Additional details about the transaction, encoded as bytes.
     */
    function logTransaction(address receiver, uint256 amount, bytes memory details) external onlyRole(AUDITOR_ROLE) {
        transactions[transactionCount] = Transaction({
            sender: msg.sender,
            receiver: receiver,
            amount: amount,
            timestamp: block.timestamp,
            details: details
        });

        emit TransactionLogged(msg.sender, receiver, amount, block.timestamp, details);
        transactionCount++;
    }

    /**
     * @dev Retrieve transaction details by index.
     * @param index The index of the transaction to retrieve.
     * @return sender Address that initiated the transaction.
     * @return receiver Address that received the transaction.
     * @return amount Amount of the transaction.
     * @return timestamp Timestamp when the transaction occurred.
     * @return details Additional details about the transaction.
     */
    function getTransaction(uint256 index) external view returns (
        address sender,
        address receiver,
        uint256 amount,
        uint256 timestamp,
        bytes memory details
    ) {
        require(index < transactionCount, "TransactionLogger: Index out of bounds");
        Transaction memory transaction = transactions[index];
        return (transaction.sender, transaction.receiver, transaction.amount, transaction.timestamp, transaction.details);
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
