// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LinkToken is ERC20,ERC677 {
    constructor(uint256 initialSupply) ERC20("Link", "GLD") {
        _mint(msg.sender, initialSupply);
    }
}