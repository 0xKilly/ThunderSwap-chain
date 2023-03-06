// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/MockERC20.sol";

contract USDT is MockERC20("USDT Token", "USDT", 1_000_000 * 1e18) {
    constructor() {}
}
