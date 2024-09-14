// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./IWormhole.sol";
import "./WormholeBridge.sol";

/**
 * @title CrossChainToken
 * @dev A token that supports cross-chain transfers using Wormhole.
 */
contract CrossChainToken is ERC20, ERC20Pausable, AccessControl {
    using Math for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    IWormhole public wormhole;
    WormholeBridge public wormholeBridge;
    address public wormholeTokenBridge;

    constructor(
        string memory name,
        string memory symbol,
        address _wormhole,
        address _wormholeBridge,
        address _wormholeTokenBridge
    ) ERC20(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        wormhole = IWormhole(_wormhole);
        wormholeBridge = WormholeBridge(_wormholeBridge);
        wormholeTokenBridge = _wormholeTokenBridge;
    }

    function mint(address account, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(account, amount);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal (ERC20, ERC20Pausable) {
        _beforeTokenTransfer(from, to, amount);
    }

    // Function to bridge tokens to another chain
    function bridgeTokens(uint256 amount, uint16 destinationChainId, address destinationAddress) external whenNotPaused {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        _burn(msg.sender, amount);

        // Prepare Wormhole message
        WormholeBridge.Message memory message = WormholeBridge.Message({
            token: address(this),
            amount: amount,
            destinationChainId: destinationChainId,
            destinationAddress: destinationAddress
        });

        // Send message to Wormhole
        
    }

    // Function to receive bridged tokens
    function receiveBridgedTokens(
        uint256 amount,
        address recipient
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(recipient, amount);
    }
}
