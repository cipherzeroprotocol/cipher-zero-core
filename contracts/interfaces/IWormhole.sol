// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

interface IWormhole {
    function publishMessage(
        uint256 _nonce,
        bytes calldata _payload,
        uint256 _fee
    ) external returns (uint64);

    function completeTransfer(
        uint256 _nonce,
        bytes calldata _payload
    ) external;

    function getMessageStatus(uint64 _messageId) external view returns (bool);

    function getCurrentGuardianSet() external view returns (address[] memory);

    function getGuardianSetExpiry() external view returns (uint64);
}
