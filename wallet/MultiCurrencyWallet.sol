// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title MultiCurrencyWallet
 * @dev A wallet contract that supports multiple ERC20 tokens and native ETH
 */
contract MultiCurrencyWallet is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    using Address for address payable;

    // Mapping from user address to token address to balance
    mapping(address => mapping(address => uint256)) private _balances;

    // Supported tokens
    mapping(address => bool) public supportedTokens;

    // Events
    event Deposit(address indexed user, address indexed token, uint256 amount);
    event Withdrawal(address indexed user, address indexed token, uint256 amount);
    event Transfer(address indexed from, address indexed to, address indexed token, uint256 amount);
    event TokenAdded(address indexed token);
    event TokenRemoved(address indexed token);

    // Custom errors
    error UnsupportedToken(address token);
    error InsufficientBalance(address user, address token, uint256 requested, uint256 available);
    error TransferFailed();

    /**
     * @dev Constructor to initialize supported tokens
     * @param initialTokens Array of initial supported token addresses
     */
    constructor(address[] memory initialTokens) {
        for (uint i = 0; i < initialTokens.length; i++) {
            addSupportedToken(initialTokens[i]);
        }
    }

    /**
     * @dev Deposits ERC20 tokens into the wallet
     * @param token Address of the ERC20 token
     * @param amount Amount of tokens to deposit
     */
    function depositERC20(address token, uint256 amount) external nonReentrant {
        require(supportedTokens[token], "Unsupported token");
        require(amount > 0, "Amount must be greater than 0");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        _balances[msg.sender][token] += amount;

        emit Deposit(msg.sender, token, amount);
    }

    /**
     * @dev Deposits native ETH into the wallet
     */
    function depositETH() external payable nonReentrant {
        require(msg.value > 0, "Amount must be greater than 0");

        _balances[msg.sender][address(0)] += msg.value;

        emit Deposit(msg.sender, address(0), msg.value);
    }

    /**
     * @dev Withdraws ERC20 tokens from the wallet
     * @param token Address of the ERC20 token
     * @param amount Amount of tokens to withdraw
     */
    function withdrawERC20(address token, uint256 amount) external nonReentrant {
        _withdraw(token, amount);

        IERC20(token).safeTransfer(msg.sender, amount);

        emit Withdrawal(msg.sender, token, amount);
    }

    /**
     * @dev Withdraws native ETH from the wallet
     * @param amount Amount of ETH to withdraw
     */
    function withdrawETH(uint256 amount) external nonReentrant {
        _withdraw(address(0), amount);

        payable(msg.sender).sendValue(amount);

        emit Withdrawal(msg.sender, address(0), amount);
    }

    /**
     * @dev Transfers tokens between users within the wallet
     * @param to Recipient address
     * @param token Address of the token (use address(0) for ETH)
     * @param amount Amount to transfer
     */
    function transfer(address to, address token, uint256 amount) external nonReentrant {
        if (token != address(0) && !supportedTokens[token]) revert UnsupportedToken(token);
        if (_balances[msg.sender][token] < amount) {
            revert InsufficientBalance(msg.sender, token, amount, _balances[msg.sender][token]);
        }

        _balances[msg.sender][token] -= amount;
        _balances[to][token] += amount;

        emit Transfer(msg.sender, to, token, amount);
    }

    /**
     * @dev Returns the balance of a specific token for a user
     * @param user Address of the user
     * @param token Address of the token (use address(0) for ETH)
     * @return balance The balance of the token for the user
     */
    function balanceOf(address user, address token) external view returns (uint256) {
        return _balances[user][token];
    }

    /**
     * @dev Adds a supported token (only owner)
     * @param token Address of the token to add
     */
    function addSupportedToken(address token) public onlyOwner {
        supportedTokens[token] = true;
        emit TokenAdded(token);
    }

    /**
     * @dev Removes a supported token (only owner)
     * @param token Address of the token to remove
     */
    function removeSupportedToken(address token) external onlyOwner {
        supportedTokens[token] = false;
        emit TokenRemoved(token);
    }

    /**
     * @dev Internal function to handle withdrawals
     * @param token Address of the token (use address(0) for ETH)
     * @param amount Amount to withdraw
     */
    function _withdraw(address token, uint256 amount) private {
        if (token != address(0) && !supportedTokens[token]) revert UnsupportedToken(token);
        if (_balances[msg.sender][token] < amount) {
            revert InsufficientBalance(msg.sender, token, amount, _balances[msg.sender][token]);
        }

        _balances[msg.sender][token] -= amount;
    }

    /**
     * @dev Fallback function to handle incoming ETH
     */
    receive() external payable {
        _balances[msg.sender][address(0)] += msg.value;
        emit Deposit(msg.sender, address(0), msg.value);
    }
}