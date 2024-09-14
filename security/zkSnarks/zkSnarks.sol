// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26

import "./Verifier.sol";

contract SecureTransfer {
    ZkSnarkVerifier private verifier;

    event TransferCompleted(address indexed from, address indexed to, uint256 value);

    constructor(address _verifier) {
        verifier = ZkSnarkVerifier(_verifier);
    }

    function secureTransfer(address to, uint256 value, bytes memory proof, bytes memory inputs) public {
        require(verifier.verify(proof, inputs), "Invalid proof");
        // Perform transfer logic
        emit TransferCompleted(msg.sender, to, value);
    }
}
