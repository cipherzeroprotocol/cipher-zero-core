// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./interfaces/IStorage.sol";

contract Storage is IStorage {
    mapping(address => string) private data;

    function storeData(string calldata _data) external override {
        data[msg.sender] = _data;
    }

    function retrieveData(address _address) external view override returns (string memory) {
        return data[_address];
    }
}
