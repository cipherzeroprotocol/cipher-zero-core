// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.3;

import "./common/Utils.sol";
import "./common/BaseModule.sol";
import "./RelayerManager.sol";
import "./SecurityManager.sol";
import "./TransactionManager.sol";


contract WalletModule is BaseModule, RelayerManager, SecurityManager, TransactionManager {

    bytes32 constant public NAME = "WalletModule";

    constructor (
        IModuleRegistry _registry,
        IGuardianStorage _guardianStorage,
        ITransferStorage _userWhitelist,
        IAuthoriser _authoriser,
        address _uniswapRouter,
        uint256 _securityPeriod,
        uint256 _securityWindow,
        uint256 _recoveryPeriod,
        uint256 _lockPeriod
    )
        BaseModule(_registry, _guardianStorage, _userWhitelist, _authoriser, NAME)
        SecurityManager(_recoveryPeriod, _securityPeriod, _securityWindow, _lockPeriod)
        TransactionManager(_securityPeriod)
        RelayerManager(_uniswapRouter)
    {
        
    }

    /**
     * @inheritdoc IModule
     */
    function init(address _wallet) external override onlyWallet(_wallet) {
        enableDefaultStaticCalls(_wallet);
    }

    /**
    * @inheritdoc IModule
    */
    function addModule(address _wallet, address _module) external override onlyWalletOwnerOrSelf(_wallet) onlyWhenUnlocked(_wallet) {
        require(registry.isRegisteredModule(_module), "AM: module is not registered");
        IWallet(_wallet).authoriseModule(_module, true);
    }
    
    /**
     * @inheritdoc RelayerManager
     */
    function getRequiredSignatures(address _wallet, bytes calldata _data) public view override returns (uint256, OwnerSignature) {
        bytes4 methodId = Utils.functionPrefix(_data);

        if (methodId == TransactionManager.multiCall.selector ||
            methodId == TransactionManager.addToWhitelist.selector ||
            methodId == TransactionManager.removeFromWhitelist.selector ||
            methodId == TransactionManager.enableERC1155TokenReceiver.selector ||
            methodId == TransactionManager.clearSession.selector ||
            methodId == ArgentModule.addModule.selector ||
            methodId == SecurityManager.addGuardian.selector ||
            methodId == SecurityManager.revokeGuardian.selector ||
            methodId == SecurityManager.cancelGuardianAddition.selector ||
            methodId == SecurityManager.cancelGuardianRevokation.selector)
        {
            // owner
            return (1, OwnerSignature.Required);
        }
        if (methodId == TransactionManager.multiCallWithSession.selector) {
            return (1, OwnerSignature.Session);
        }
        if (methodId == SecurityManager.executeRecovery.selector) {
            // majority of guardians
            uint numberOfSignaturesRequired = _majorityOfGuardians(_wallet);
            require(numberOfSignaturesRequired > 0, "AM: no guardians set on wallet");
            return (numberOfSignaturesRequired, OwnerSignature.Disallowed);
        }
        if (methodId == SecurityManager.cancelRecovery.selector) {
            // majority of (owner + guardians)
            uint numberOfSignaturesRequired = Utils.ceil(recoveryConfigs[_wallet].guardianCount + 1, 2);
            return (numberOfSignaturesRequired, OwnerSignature.Optional);
        }
        if (methodId == TransactionManager.multiCallWithGuardians.selector ||
            methodId == TransactionManager.multiCallWithGuardiansAndStartSession.selector ||
            methodId == SecurityManager.transferOwnership.selector)
        {
            // owner + majority of guardians
            uint majorityGuardians = _majorityOfGuardians(_wallet);
            uint numberOfSignaturesRequired = majorityGuardians + 1;
            return (numberOfSignaturesRequired, OwnerSignature.Required);
        }
        if (methodId == SecurityManager.finalizeRecovery.selector ||
            methodId == SecurityManager.confirmGuardianAddition.selector ||
            methodId == SecurityManager.confirmGuardianRevokation.selector)
        {
            // anyone
            return (0, OwnerSignature.Anyone);
        }
        if (methodId == SecurityManager.lock.selector || methodId == SecurityManager.unlock.selector) {
            // any guardian
            return (1, OwnerSignature.Disallowed);
        }
        revert("SM: unknown method");
    }

    function _majorityOfGuardians(address _wallet) internal view returns (uint) {
        return Utils.ceil(guardianStorage.guardianCount(_wallet), 2);
    }
}