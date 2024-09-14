// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


interface IWormhole {
    function transferTokens(address token, uint256 amount, uint16 recipientChain, bytes32 recipient, uint32 nonce) external returns (uint64 sequence);
    function completeTransfer(bytes memory encodedVm) external;
}