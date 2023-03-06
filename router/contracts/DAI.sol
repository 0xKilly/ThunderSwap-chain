// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/MockERC20.sol";

contract DAI is MockERC20("DAI Token", "DAI", 1_000_000 * 1e18) {
    constructor() {}
}
