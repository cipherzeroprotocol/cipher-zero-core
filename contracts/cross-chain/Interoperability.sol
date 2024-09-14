// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IBridge {
    function transferToOtherChain(
        address token,
        address to,
        uint256 amount,
        string memory targetChain
    ) external;
}

contract Interoperability is Ownable(address(0)) {
    IBridge public bridge;

    event TokenTransferred(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 amount,
        string targetChain
    );

    constructor(address _bridge) {
        bridge = IBridge(_bridge);
    }

    function setBridge(address _bridge) external onlyOwner {
        bridge = IBridge(_bridge);
    }

    function transferTokens(
        address token,
        address to,
        uint256 amount,
        string memory targetChain
    ) external {
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        bridge.transferToOtherChain(token, to, amount, targetChain);
        emit TokenTransferred(token, msg.sender, to, amount, targetChain);
    }
}
