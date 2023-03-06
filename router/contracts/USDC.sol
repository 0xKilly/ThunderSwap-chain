// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/MockERC20.sol";

contract USDC is MockERC20("USDC Token", "USDC", 1_000_000 * 1e18) {
    constructor() {}
}
