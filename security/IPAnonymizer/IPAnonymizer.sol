// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IZKVerifier.sol";

contract IPAnonymizer is Ownable {
    IZKVerifier public verifier;
    
    // Mapping to store anonymized IP hashes
    mapping(bytes32 => bool) public anonymizedIPs;
    
    // Event emitted when a new anonymized IP is registered
    event AnonymizedIPRegistered(bytes32 indexed ipHash);
    
    // Event emitted when the verifier contract is updated
    event VerifierUpdated(address newVerifier);

    constructor(address _verifier) {
        verifier = IZKVerifier(_verifier);
    }

    /**
     * @dev Registers an anonymized IP
     * @param ipHash The hash of the IP address
     * @param proof The zk-SNARK proof
     * @param publicInputs The public inputs for the proof verification
     */
    function registerAnonymizedIP(
        bytes32 ipHash,
        uint256[8] calldata proof,
        uint256[1] calldata publicInputs
    ) external {
        require(!anonymizedIPs[ipHash], "IP already anonymized");
        require(verifier.verifyProof(proof, publicInputs), "Invalid proof");

        anonymizedIPs[ipHash] = true;
        emit AnonymizedIPRegistered(ipHash);
    }

    /**
     * @dev Checks if an IP is anonymized
     * @param ipHash The hash of the IP address to check
     * @return bool indicating if the IP is anonymized
     */
    function isIPAnonymized(bytes32 ipHash) external view returns (bool) {
        return anonymizedIPs[ipHash];
    }

    /**
     * @dev Updates the verifier contract address
     * @param _newVerifier Address of the new verifier contract
     */
    function updateVerifier(address _newVerifier) external onlyOwner {
        require(_newVerifier != address(0), "Invalid verifier address");
        verifier = IZKVerifier(_newVerifier);
        emit VerifierUpdated(_newVerifier);
    }
}