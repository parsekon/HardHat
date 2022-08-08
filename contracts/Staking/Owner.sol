// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Owner {
    address public owner;
    constructor () {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }
}