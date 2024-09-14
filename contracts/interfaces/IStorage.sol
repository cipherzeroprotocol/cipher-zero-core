// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IStorage {
    function storeData(string calldata _data) external;
    function retrieveData(address _address) external view returns (string memory);
}
