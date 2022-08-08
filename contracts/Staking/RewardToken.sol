// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract RewardToken is ERC20 {
    constructor() ERC20("RewardToken", "RTK", 18, 10000) {}
}