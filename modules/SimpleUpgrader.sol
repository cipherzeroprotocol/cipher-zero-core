

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.3;

import "./common/IModule.sol";
import "../infrastructure/IModuleRegistry.sol";
import "../wallet/IWallet.sol";

contract SimpleUpgrader is IModule {

    IModuleRegistry private registry;
    address[] public toDisable;
    address[] public toEnable;

    // *************** Constructor ********************** //

    constructor(
        IModuleRegistry _registry,
        address[] memory _toDisable,
        address[] memory _toEnable
    )
    {
        registry = _registry;
        toDisable = _toDisable;
        toEnable = _toEnable;
    }

    // *************** External/Public Functions ********************* //

    /**
     * @notice Perform the upgrade for a wallet. This method gets called when SimpleUpgrader is temporarily added as a module.
     * @param _wallet The target wallet.
     */
    function init(address _wallet) external override {
        require(msg.sender == _wallet, "SU: only wallet can call init");
        require(registry.isRegisteredModule(toEnable), "SU: module not registered");

        uint256 i = 0;
        //add new modules
        for (; i < toEnable.length; i++) {
            IWallet(_wallet).authoriseModule(toEnable[i], true);
        }
        //remove old modules
        for (i = 0; i < toDisable.length; i++) {
            IWallet(_wallet).authoriseModule(toDisable[i], false);
        }
        // SimpleUpgrader did its job, we no longer need it as a module
        IWallet(_wallet).authoriseModule(address(this), false);
    }

    /**
     * @inheritdoc IModule
     */
    function addModule(address /*_wallet*/, address /*_module*/) external pure override {
        revert("SU: method not implemented");
    }

    /**
     * @inheritdoc IModule
     */
    function supportsStaticCall(bytes4 /*_methodId*/) external pure override returns (bool _isSupported) { 
        return false;
    }
}