// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.26;

import "./Owned.sol";

contract Managed is Owned {

    // The managers
    mapping (address => bool) public managers;

    /**
     * @notice Throws if the sender is not a manager.
     */
    modifier onlyManager {
        require(managers[msg.sender] == true, "M: Must be manager");
        _;
    }

    event ManagerAdded(address indexed _manager);
    event ManagerRevoked(address indexed _manager);

    /**
    * @notice Adds a manager.
    * @param _manager The address of the manager.
    */
    function addManager(address _manager) external onlyOwner {
        require(_manager != address(0), "M: Address must not be null");
        if (managers[_manager] == false) {
            managers[_manager] = true;
            emit ManagerAdded(_manager);
        }
    }

    /**
    * @notice Revokes a manager.
    * @param _manager The address of the manager.
    */
    function revokeManager(address _manager) external virtual onlyOwner {
        // solhint-disable-next-line reason-string
        require(managers[_manager] == true, "M: Target must be an existing manager");
        delete managers[_manager];
        emit ManagerRevoked(_manager);
    }
}