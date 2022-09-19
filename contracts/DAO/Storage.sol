// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Storage is Ownable {
    uint myVal;

    event Stored(uint newVal);

    function store(uint _newVal) external {
        myVal = _newVal;

        emit Stored(_newVal);
    }

    function read() public view returns(uint) {
        return myVal;
    }
}