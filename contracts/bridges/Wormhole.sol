// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


import "./IWormhole.sol";

contract WormholeBridge {
    IWormhole public wormhole;
    address public token;

    constructor(address _wormhole, address _token) {
        wormhole = IWormhole(_wormhole);
        token = _token;
    }

    function transfer(uint256 amount, uint16 recipientChain, bytes32 recipient, uint32 nonce) external {
        // Transfer logic
        wormhole.transferTokens(token, amount, recipientChain, recipient, nonce);
    }

    function complete(bytes memory encodedVm) external {
        // Complete transfer logic
        wormhole.completeTransfer(encodedVm);
    }
}
