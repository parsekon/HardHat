// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract Timelock is TimelockController {
    constructor(
        uint _minDelay,
        address[] memory _proposers,
        address[] memory _executors
    ) TimelockController(_minDelay, _proposers, _executors) {}
}