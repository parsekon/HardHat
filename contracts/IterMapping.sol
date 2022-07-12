// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IterMapping {
    mapping(string => uint) public ages;
    string[] public keys;
    mapping(string => bool) public isInserted;

    function setAges(string memory _names, uint _ages) public {
        ages[_names] = _ages;

        if (!isInserted[_names]) {
            keys.push(_names);
            isInserted[_names] = true;
        }
    }

    function lengthAges() public view returns (uint) {
        return keys.length;
    }

    function getNanes(uint _index) public view returns (string memory) {
        return keys[_index];
    }

    function getAges() public view returns (uint[] memory) {
        uint[] memory allAges = new uint[](keys.length);

        for (uint i = 0; i < keys.length; i++) {
            allAges[i] = ages[keys[i]];
        }
        return allAges;
    }
}
