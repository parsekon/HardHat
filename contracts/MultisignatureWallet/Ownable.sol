// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Owner {
    // массив владельцев
    address[] public owners;

    // маппинг владелец => true/false
    mapping(address => bool) public isOwner;

    // конструктор принимает массив адресов владельцев
    // (при развертывании необходимов в remix указывать адреса в кавычках)
    // проверяем, что массив не нулевой длины
    // в цикле добавляем владельцев в массив и присваиваем значение true
    // проверяем на ненулевой адрес и что адрес еще не является владельцем
    constructor(address[] memory _owners) {
    
        require(_owners.length > 0, "No owners!");

        for(uint i; i < _owners.length; i++) {
            address owner = _owners[i];
            
            require(owner != address(0), "It is zero address!");
            require(!isOwner[owner], "Not unique!");

            owners.push(owner);
            isOwner[owner] = true;
        }
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
    function addOwner(address _newOwner) external onlyOwners isOwners(_newOwner) {
        owners.push(_newOwner);
        isOwner[_newOwner] = true;      
    } 
}