// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import "./Storage.sol";
import "../../infrastructure/storage/ITransferStorage.sol";


contract TransferStorage is ITransferStorage, Storage {

    // wallet specific storage
    mapping (address => mapping (address => uint256)) internal whitelist;

    // *************** External Functions ********************* //

    /**
     * @notice Lets an authorised module add or remove an account from the whitelist of a wallet.
     * @param _wallet The target wallet.
     * @param _target The account to add/remove.
     * @param _value The epoch time at which an account starts to be whitelisted, or zero if the account is not whitelisted
     */
    function setWhitelist(address _wallet, address _target, uint256 _value) external onlyModule(_wallet) {
        whitelist[_wallet][_target] = _value;
    }

    /**
     * @notice Gets the whitelist state of an account for a wallet.
     * @param _wallet The target wallet.
     * @param _target The account.
     * @return The epoch time at which an account starts to be whitelisted, or zero if the account is not whitelisted
     */
    function getWhitelist(address _wallet, address _target) external view returns (uint256) {
        return whitelist[_wallet][_target];
    }
}