// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract receiver {
    string public message;
    function getBalalnce() external view returns(uint) {
        return address(this).balance;
    }

    function getMoney(string memory _message) external payable {
        message = _message;
    }
}