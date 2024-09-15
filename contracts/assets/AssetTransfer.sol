// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./AssetRegistry.sol";

/**
 * @title AssetTransfer
 * @dev A contract for handling asset transfers within the Cipher Zero Protocol
 */
contract AssetTransfer is ReentrancyGuard, AccessControl, Pausable {
    using SafeERC20 for IERC20;

    bytes32 public constant TRANSFER_ADMIN_ROLE = keccak256("TRANSFER_ADMIN_ROLE");
    bytes32 public constant BRIDGE_ROLE = keccak256("BRIDGE_ROLE");

    AssetRegistry public assetRegistry;

    uint256 public transferFeePercentage; // 0.1% fee (1 = 0.1%, 10 = 1%)
    uint256 public constant MAX_FEE_PERCENTAGE = 50; // 5% max fee
    uint256 public constant FEE_DENOMINATOR = 1000;

    mapping(uint256 => mapping(address => uint256)) public noncesPerChain;

    event AssetTransferred(
        uint256 indexed sourceChainId,
        uint256 indexed targetChainId,
        address indexed assetAddress,
        address from,
        address to,
        uint256 amount,
        uint256 nonce
    );
    event TransferFeeUpdated(uint256 newFeePercentage);
    event BridgeCompleted(
        uint256 indexed sourceChainId,
        uint256 indexed targetChainId,
        address indexed assetAddress,
        address to,
        uint256 amount,
        uint256 nonce
    );

    constructor(address _assetRegistry) {
        assetRegistry = AssetRegistry(_assetRegistry);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TRANSFER_ADMIN_ROLE, msg.sender);
        _grantRole(BRIDGE_ROLE, msg.sender);
    }

    /**
     * @dev Initiates an asset transfer
     * @param sourceChainId The source chain ID
     * @param targetChainId The target chain ID
     * @param assetAddress The address of the asset to transfer
     * @param to The recipient address
     * @param amount The amount to transfer
     */
    function initiateTransfer(
        uint256 sourceChainId,
        uint256 targetChainId,
        address assetAddress,
        address to,
        uint256 amount
    ) external payable whenNotPaused nonReentrant {
        require(sourceChainId != targetChainId, "Same chain transfer not allowed");
        AssetRegistry.Asset memory asset = assetRegistry.getAsset(sourceChainId, assetAddress);
        require(asset.isActive, "Asset not active");

        uint256 fee = (amount * transferFeePercentage) / FEE_DENOMINATOR;
        uint256 amountAfterFee = amount - fee;

        uint256 nonce = noncesPerChain[targetChainId][msg.sender]++;

        if (asset.assetType == AssetRegistry.AssetType.NATIVE) {
            require(msg.value == amount, "Incorrect ETH amount");
        } else if (asset.assetType == AssetRegistry.AssetType.ERC20) {
            IERC20(assetAddress).safeTransferFrom(msg.sender, address(this), amount);
        } else if (asset.assetType == AssetRegistry.AssetType.ERC721) {
            IERC721(assetAddress).transferFrom(msg.sender, address(this), amount);
        } else if (asset.assetType == AssetRegistry.AssetType.ERC1155) {
            IERC1155(assetAddress).safeTransferFrom(msg.sender, address(this), amount, 1, "");
        }

        emit AssetTransferred(sourceChainId, targetChainId, assetAddress, msg.sender, to, amountAfterFee, nonce);
    }

    /**
     * @dev Completes a cross-chain asset transfer (called by bridge)
     * @param sourceChainId The source chain ID
     * @param targetChainId The target chain ID
     * @param assetAddress The address of the asset to transfer
     * @param to The recipient address
     * @param amount The amount to transfer
     * @param nonce The transfer nonce
     */
    function completeBridgeTransfer(
        uint256 sourceChainId,
        uint256 targetChainId,
        address assetAddress,
        address to,
        uint256 amount,
        uint256 nonce
    ) external onlyRole(BRIDGE_ROLE) whenNotPaused nonReentrant {
        AssetRegistry.Asset memory asset = assetRegistry.getAsset(targetChainId, assetAddress);
        require(asset.isActive, "Asset not active");

        if (asset.assetType == AssetRegistry.AssetType.NATIVE) {
            payable(to).transfer(amount);
        } else if (asset.assetType == AssetRegistry.AssetType.ERC20) {
            IERC20(assetAddress).safeTransfer(to, amount);
        } else if (asset.assetType == AssetRegistry.AssetType.ERC721) {
            IERC721(assetAddress).transferFrom(address(this), to, amount);
        } else if (asset.assetType == AssetRegistry.AssetType.ERC1155) {
            IERC1155(assetAddress).safeTransferFrom(address(this), to, amount, 1, "");
        }

        emit BridgeCompleted(sourceChainId, targetChainId, assetAddress, to, amount, nonce);
    }

    /**
     * @dev Updates the transfer fee percentage
     * @param newFeePercentage The new fee percentage (1 = 0.1%)
     */
    function updateTransferFee(uint256 newFeePercentage) external onlyRole(TRANSFER_ADMIN_ROLE) {
        require(newFeePercentage <= MAX_FEE_PERCENTAGE, "Fee too high");
        transferFeePercentage = newFeePercentage;
        emit TransferFeeUpdated(newFeePercentage);
    }

    /**
     * @dev Withdraws accumulated fees
     * @param assetAddress The address of the asset to withdraw
     * @param to The address to send the fees to
     * @param amount The amount to withdraw
     */
    function withdrawFees(address assetAddress, address payable to, uint256 amount) external onlyRole(TRANSFER_ADMIN_ROLE) {
        AssetRegistry.Asset memory asset = assetRegistry.getAsset(block.chainid, assetAddress);
        require(asset.isActive, "Asset not active");

        if (asset.assetType == AssetRegistry.AssetType.NATIVE) {
            to.transfer(amount);
        } else if (asset.assetType == AssetRegistry.AssetType.ERC20) {
            IERC20(assetAddress).safeTransfer(to, amount);
        } else {
            revert("Unsupported asset type for fee withdrawal");
        }
    }

    /**
     * @dev Pauses the contract
     */
    function pause() external onlyRole(TRANSFER_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses the contract
     */
    function unpause() external onlyRole(TRANSFER_ADMIN_ROLE) {
        _unpause();
    }

    receive() external payable {}
}