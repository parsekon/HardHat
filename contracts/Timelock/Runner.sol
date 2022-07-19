// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Runner {
    // адрес контракта timelock
    address public lock;

    // сообщение, которое можно менять
    string public massage;

    // сопоставление с платежами
    mapping(address => uint) public payments;

    constructor(address _lock) {
        lock = _lock;
    }

    // функция меняет сообщение
    function run(string memory newMsg) external payable {
        require(msg.sender == lock, "Invalid address!");
        payments[msg.sender] += msg.value;

        massage = newMsg;
    }

    // вспомогательная функция для расчета timestamp
    function newTimestamp() external view returns(uint) {
        return block.timestamp + 20;
    }

    // функция подготовки сообщения
    function prepareDate(string calldata _msg) external pure returns(bytes memory) {
        return abi.encode(_msg);
    }
}