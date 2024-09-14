// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/**
 * @title AssetRegistry
 * @dev A contract for registering and managing assets in the Cipher Zero Protocol
 */
contract AssetRegistry is AccessControl, Pausable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant REGISTRAR_ROLE = keccak256("REGISTRAR_ROLE");

    enum AssetType { NATIVE, ERC20, ERC721, ERC1155 }

    struct Asset {
        address contractAddress;
        AssetType assetType;
        string name;
        string symbol;
        uint8 decimals;
        bool isActive;
    }

    struct ChainInfo {
        uint256 chainId;
        string name;
        bool isActive;
    }

    mapping(uint256 => mapping(address => Asset)) private _assets;
    mapping(uint256 => ChainInfo) private _chains;
    
    EnumerableSet.UintSet private _supportedChainIds;
    mapping(uint256 => EnumerableSet.AddressSet) private _chainAssets;

    event AssetRegistered(uint256 indexed chainId, address indexed assetAddress, AssetType assetType, string name, string symbol);
    event AssetUpdated(uint256 indexed chainId, address indexed assetAddress, bool isActive);
    event ChainAdded(uint256 indexed chainId, string name);
    event ChainUpdated(uint256 indexed chainId, bool isActive);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(REGISTRAR_ROLE, msg.sender);
    }

    /**
     * @dev Registers a new asset
     * @param chainId The chain ID where the asset exists
     * @param assetAddress The contract address of the asset (address(0) for native coins)
     * @param assetType The type of the asset (NATIVE, ERC20, ERC721, ERC1155)
     * @param name The name of the asset
     * @param symbol The symbol of the asset
     * @param decimals The number of decimals for the asset (0 for non-fungible tokens)
     */
    function registerAsset(
        uint256 chainId,
        address assetAddress,
        AssetType assetType,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) external onlyRole(REGISTRAR_ROLE) whenNotPaused {
        require(_supportedChainIds.contains(chainId), "Chain not supported");
        require(_assets[chainId][assetAddress].contractAddress == address(0), "Asset already registered");

        Asset memory newAsset = Asset({
            contractAddress: assetAddress,
            assetType: assetType,
            name: name,
            symbol: symbol,
            decimals: decimals,
            isActive: true
        });

        _assets[chainId][assetAddress] = newAsset;
        _chainAssets[chainId].add(assetAddress);

        emit AssetRegistered(chainId, assetAddress, assetType, name, symbol);
    }

    /**
     * @dev Updates the active status of an asset
     * @param chainId The chain ID where the asset exists
     * @param assetAddress The contract address of the asset
     * @param isActive The new active status
     */
    function updateAssetStatus(uint256 chainId, address assetAddress, bool isActive) external onlyRole(REGISTRAR_ROLE) {
        require(_assets[chainId][assetAddress].contractAddress != address(0), "Asset not registered");
        _assets[chainId][assetAddress].isActive = isActive;
        emit AssetUpdated(chainId, assetAddress, isActive);
    }

    /**
     * @dev Adds support for a new chain
     * @param chainId The ID of the chain to add
     * @param name The name of the chain
     */
    function addChain(uint256 chainId, string memory name) external onlyRole(REGISTRAR_ROLE) {
        require(!_supportedChainIds.contains(chainId), "Chain already supported");
        _supportedChainIds.add(chainId);
        _chains[chainId] = ChainInfo({
            chainId: chainId,
            name: name,
            isActive: true
        });
        emit ChainAdded(chainId, name);
    }

    /**
     * @dev Updates the active status of a chain
     * @param chainId The ID of the chain to update
     * @param isActive The new active status
     */
    function updateChainStatus(uint256 chainId, bool isActive) external onlyRole(REGISTRAR_ROLE) {
        require(_supportedChainIds.contains(chainId), "Chain not supported");
        _chains[chainId].isActive = isActive;
        emit ChainUpdated(chainId, isActive);
    }

    /**
     * @dev Retrieves asset information
     * @param chainId The chain ID where the asset exists
     * @param assetAddress The contract address of the asset
     * @return Asset struct containing asset information
     */
    function getAsset(uint256 chainId, address assetAddress) external view returns (Asset memory) {
        return _assets[chainId][assetAddress];
    }

    /**
     * @dev Retrieves chain information
     * @param chainId The ID of the chain
     * @return ChainInfo struct containing chain information
     */
    function getChainInfo(uint256 chainId) external view returns (ChainInfo memory) {
        return _chains[chainId];
    }

    /**
     * @dev Retrieves all supported chain IDs
     * @return An array of supported chain IDs
     */
    function getSupportedChainIds() external view returns (uint256[] memory) {
        return _supportedChainIds.values();
    }

    /**
     * @dev Retrieves all asset addresses for a given chain
     * @param chainId The ID of the chain
     * @return An array of asset addresses
     */
    function getChainAssets(uint256 chainId) external view returns (address[] memory) {
        return _chainAssets[chainId].values();
    }

    /**
     * @dev Pauses the contract
     */
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses the contract
     */
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}