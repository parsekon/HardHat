// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SpeedRun {
    address public owner;
    string public telegram;
    string public discord;
    string public desc;

    constructor(string memory _telegram, string memory _discord) {
        owner = msg.sender;
        telegram = _telegram;
        discord = _discord;
    }

    function info() public pure returns(string memory) {
        return "empty";
    }

    function info(string memory _test) public pure returns(string memory) {
        return _test;
    }
}