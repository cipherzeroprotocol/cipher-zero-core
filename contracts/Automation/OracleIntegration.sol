// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IOracle {
    function getLatestData() external view returns (uint256);
}

contract OracleIntegration {
    IOracle public oracle;

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }

    function getOracleData() external view returns (uint256) {
        return oracle.getLatestData();
    }
}
