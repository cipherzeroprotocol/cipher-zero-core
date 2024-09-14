// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract RealTimeMonitoring {
    event TransferMonitored(address indexed from, address indexed to, uint256 amount);

    function monitorTransfer(address from, address to, uint256 amount) external {
        emit TransferMonitored(from, to, amount);
    }
}
