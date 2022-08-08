// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Owners {
    address owner;

    // массив владельцев
    address[] public owners;

    // маппинг владелец => true/false
    mapping(address => bool) public isOwner;

    // добавляем первогоы владельца в массив и присваиваем значение true
    // проверяем на ненулевой адрес и что адрес еще не является владельцем
    constructor() {
        owner = msg.sender;
        owners.push(owner);
        isOwner[owner] = true;
    }

    modifier onlyOwners() {
        require(isOwner[msg.sender], "Not an owner!");
        _;
    }

    modifier isOwners(address owners_) {
        require(!isOwner[owners_], "Not unique!");
        _;
    }

    // добавляем отдельные адреса в массив owners
    function addOwner(address _newOwner)
        external
        onlyOwners
        isOwners(_newOwner)
    {
        owners.push(_newOwner);
        isOwner[_newOwner] = true;
    }

    // удаляем владельца
    function delOwner(address _delOwner) external onlyOwners {
        isOwner[_delOwner] = false;
    }
}
