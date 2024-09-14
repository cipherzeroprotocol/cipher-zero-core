// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./Interoperability.sol";
import "./CrossChainTransfers.sol";
import "./IWormhole.sol";

contract InteroperabilityManager {
    Interoperability public interoperability;
    CrossChainTransfers public crossChainTransfers;

    event InteroperabilityInitialized(address interoperability, address crossChainTransfers);

    constructor(address _interoperability, address _crossChainTransfers) {
        interoperability = Interoperability(_interoperability);
        crossChainTransfers = CrossChainTransfers(_crossChainTransfers);
        emit InteroperabilityInitialized(_interoperability, _crossChainTransfers);
    }

    function transferTokens(
        address token,
        address to,
        uint256 amount,
        string memory targetChain
    ) external {
        interoperability.transferTokens(token, to, amount, targetChain);
    }

    function initiateCrossChainTransfer(address to, uint256 amount, string memory targetChain) external {
        crossChainTransfers.transferToOtherChain(to, amount, targetChain);
    }
}
