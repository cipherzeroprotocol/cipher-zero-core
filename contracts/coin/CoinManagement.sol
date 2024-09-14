// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title CoinManagement
 * @dev A contract for managing native coins within the Cipher Zero Protocol
 */
contract CoinManagement is ReentrancyGuard, AccessControl, Pausable {
    using Address for address payable;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant BRIDGE_ROLE = keccak256("BRIDGE_ROLE");

    mapping(address => uint256) private _balances;
    mapping(uint256 => bool) private _supportedChainIds;

    uint256 public constant TRANSFER_FEE = 0.1 ether; // 0.1% fee
    uint256 public constant MIN_DEPOSIT = 0.01 ether;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Transferred(address indexed from, address indexed to, uint256 amount);
    event BridgeInitiated(address indexed user, uint256 indexed targetChainId, uint256 amount);
    event BridgeCompleted(address indexed user, uint256 indexed sourceChainId, uint256 amount);
    event ChainSupported(uint256 indexed chainId);
    event ChainRemoved(uint256 indexed chainId);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, msg.sender);
        _supportedChainIds[1] = true; // Ethereum mainnet
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable whenNotPaused nonReentrant {
        require(msg.value >= MIN_DEPOSIT, "Deposit below minimum");
        _balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external whenNotPaused nonReentrant {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        payable(msg.sender).sendValue(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) external whenNotPaused nonReentrant {
        require(_balances[msg.sender] >= amount + TRANSFER_FEE, "Insufficient balance");
        _balances[msg.sender] -= amount + TRANSFER_FEE;
        _balances[to] += amount;
        emit Transferred(msg.sender, to, amount);
    }

    function initiateBridge(uint256 targetChainId, uint256 amount) external whenNotPaused nonReentrant {
        require(_supportedChainIds[targetChainId], "Unsupported chain");
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        emit BridgeInitiated(msg.sender, targetChainId, amount);
        // Additional logic for initiating cross-chain transfer
    }

    function completeBridge(address user, uint256 sourceChainId, uint256 amount) external onlyRole(BRIDGE_ROLE) whenNotPaused nonReentrant {
        require(_supportedChainIds[sourceChainId], "Unsupported chain");
        _balances[user] += amount;
        emit BridgeCompleted(user, sourceChainId, amount);
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function addSupportedChain(uint256 chainId) external onlyRole(MANAGER_ROLE) {
        _supportedChainIds[chainId] = true;
        emit ChainSupported(chainId);
    }

    function removeSupportedChain(uint256 chainId) external onlyRole(MANAGER_ROLE) {
        _supportedChainIds[chainId] = false;
        emit ChainRemoved(chainId);
    }

    function isChainSupported(uint256 chainId) external view returns (bool) {
        return _supportedChainIds[chainId];
    }

    function pause() external onlyRole(MANAGER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(MANAGER_ROLE) {
        _unpause();
    }

    function withdrawFees(address payable recipient) external onlyRole(MANAGER_ROLE) {
        uint256 fees = address(this).balance - getTotalUserBalance();
        recipient.sendValue(fees);
    }

    function getTotalUserBalance() public view returns (uint256) {
        return address(this).balance - TRANSFER_FEE * address(this).balance / 1000;
    }
}