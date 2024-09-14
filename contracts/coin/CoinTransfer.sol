// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title CoinTransfer
 * @dev A contract for handling native coin transfers within the Cipher Zero Protocol
 */
contract CoinTransfer is ReentrancyGuard, AccessControl, Pausable {
    using Address for address payable;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant FEE_MANAGER_ROLE = keccak256("FEE_MANAGER_ROLE");

    uint256 public transferFeePercentage = 1; // 0.1% fee (1 = 0.1%, 10 = 1%)
    uint256 public constant MAX_FEE_PERCENTAGE = 50; // 5% max fee
    uint256 public constant FEE_DENOMINATOR = 1000;

    uint256 public dailyTransferLimit = 100 ether;
    mapping(address => uint256) public dailyTransfers;
    mapping(address => uint256) public lastTransferReset;

    event CoinTransferred(address indexed from, address indexed to, uint256 amount, uint256 fee);
    event BatchTransferred(address indexed from, address[] to, uint256[] amounts, uint256 totalFee);
    event TransferFeeUpdated(uint256 newFeePercentage);
    event DailyLimitUpdated(uint256 newLimit);
    event FeesWithdrawn(address indexed to, uint256 amount);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(FEE_MANAGER_ROLE, msg.sender);
    }

    receive() external payable {}

    /**
     * @dev Transfers coins to a single recipient
     * @param to The address to transfer to
     * @param amount The amount to transfer
     */
    function transfer(address payable to, uint256 amount) external payable whenNotPaused nonReentrant {
        require(msg.value == amount, "Sent value does not match amount");
        _checkAndUpdateDailyLimit(msg.sender, amount);

        uint256 fee = (amount * transferFeePercentage) / FEE_DENOMINATOR;
        uint256 amountAfterFee = amount - fee;

        to.sendValue(amountAfterFee);
        emit CoinTransferred(msg.sender, to, amountAfterFee, fee);
    }

    /**
     * @dev Transfers coins to multiple recipients in a single transaction
     * @param to Array of recipient addresses
     * @param amounts Array of amounts to transfer
     */
    function batchTransfer(address payable[] calldata to, uint256[] calldata amounts) external payable whenNotPaused nonReentrant {
        require(to.length == amounts.length, "Arrays length mismatch");
        require(to.length <= 100, "Batch size too large");

        uint256 totalAmount = 0;
        uint256 totalFee = 0;

        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(msg.value == totalAmount, "Sent value does not match total amount");
        _checkAndUpdateDailyLimit(msg.sender, totalAmount);

        for (uint256 i = 0; i < to.length; i++) {
            uint256 fee = (amounts[i] * transferFeePercentage) / FEE_DENOMINATOR;
            uint256 amountAfterFee = amounts[i] - fee;
            totalFee += fee;

            to[i].sendValue(amountAfterFee);
        }

        emit BatchTransferred(msg.sender, to, amounts, totalFee);
    }

    /**
     * @dev Updates the transfer fee percentage
     * @param newFeePercentage The new fee percentage (1 = 0.1%)
     */
    function updateTransferFee(uint256 newFeePercentage) external onlyRole(FEE_MANAGER_ROLE) {
        require(newFeePercentage <= MAX_FEE_PERCENTAGE, "Fee too high");
        transferFeePercentage = newFeePercentage;
        emit TransferFeeUpdated(newFeePercentage);
    }

    /**
     * @dev Updates the daily transfer limit
     * @param newLimit The new daily limit
     */
    function updateDailyLimit(uint256 newLimit) external onlyRole(ADMIN_ROLE) {
        dailyTransferLimit = newLimit;
        emit DailyLimitUpdated(newLimit);
    }

    /**
     * @dev Withdraws accumulated fees
     * @param to Address to send the fees to
     */
    function withdrawFees(address payable to) external onlyRole(ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        require(balance > 0, "No fees to withdraw");
        to.sendValue(balance);
        emit FeesWithdrawn(to, balance);
    }

    /**
     * @dev Checks and updates the daily transfer limit for a user
     * @param user The user's address
     * @param amount The amount being transferred
     */
    function _checkAndUpdateDailyLimit(address user, uint256 amount) internal {
        if (block.timestamp - lastTransferReset[user] >= 1 days) {
            dailyTransfers[user] = 0;
            lastTransferReset[user] = block.timestamp;
        }

        require(dailyTransfers[user] + amount <= dailyTransferLimit, "Daily transfer limit exceeded");
        dailyTransfers[user] += amount;
    }

    /**
     * @dev Pauses the contract
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses the contract
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}