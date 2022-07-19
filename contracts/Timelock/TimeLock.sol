// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Ownable.sol";

contract Lock is Owner {
    // задаем константы:
    // минимально допустимая задержка для выполнения транзакции
    // максимально допустимая задержка,
    // время через которое транзакция считается истекщей
    uint public constant MIN_DELAY = 10;
    uint public constant MAX_DElAY = 100;
    uint public constant EXPIRY_DELAY = 1000;

    // маппинг индентификатор транзакции => поставлена ли транзакция в очередь
    mapping(bytes32 => bool) public queuedTxs;

    // события:
    // постановка транзакции в очередь
    event Queued(
        bytes32 indexed txId,
        address indexed to,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );

    event Executed(
        bytes32 indexed txId,
        address indexed to,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );

    // функция для постановки транзакции в очередь
    // создаем уникальный идентификатор txId транзакции, хешируем
    // проверяем нет ли такой транзакции в очереди
    // проверяем не прошло ли минимальное время в очереди, не истекло ли максимально допустимое время в очереди
    // _func может быть пустым если вызываем функция receive
    function queue(
        address _to,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external onlyOwners returns (bytes32) {
        bytes32 txId = keccak256(
            abi.encode(_to, _value, _func, _data, _timestamp)
        );

        require(!queuedTxs[txId], "Already queued!");
        require(
            _timestamp >= block.timestamp + MIN_DELAY &&
                _timestamp <= block.timestamp + MAX_DElAY,
            "Invalid timestamp!"
        );

        queuedTxs[txId] = true;

        emit Queued(txId, _to, _value, _func, _data, _timestamp);

        return txId;
    }

    // функция выполнить транзакцию
    // проверяем, что транзакция есть в очереди и что настало ее время
    //
    function execute(
        address _to,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external payable onlyOwners returns (bytes memory) {
        bytes32 txId = keccak256(
            abi.encode(_to, _value, _func, _data, _timestamp)
        );

        require(queuedTxs[txId], "Not queued!");
        require(block.timestamp >= _timestamp, "Too early!");
        require(block.timestamp <= _timestamp + EXPIRY_DELAY, "Too late!");

        delete queuedTxs[txId];

        bytes memory data;
        if (bytes(_func).length > 0) {
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
        } else {
            data = _data;
        }

        (bool success, bytes memory resp) = _to.call{value: _value}(data);

        require(success, "TX failed!");
        emit Executed(txId, _to, _value, _func, _data, _timestamp);

        return resp;
    }

    //  функция, которая отменяет транзакцию
    function cancel(bytes32 _txId) external onlyOwners {
        require(queuedTxs[_txId], "Not queued!");

        delete queuedTxs[_txId];
    }
}
