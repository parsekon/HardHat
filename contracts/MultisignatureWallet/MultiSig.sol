// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Ownable.sol";

contract MultiSig is Owner {
    // количество подтверждений
    uint public requiredApprovals;

    // структура транзакции поставленной в очередь
    struct  Transaction {
        address _to;
        uint _value;
        bytes _data;
        bool _executed;
    }

    // создаем массив транзакций
    Transaction[] public transactions;

    // индекс транзакции => количество подтверждений
    mapping(uint => uint) public approvalsCount;
    // индекс транзакции => адрес кто подтвердил и булево значение, подтверждена ли транзакция этим адресом или еще нет
    mapping(uint => mapping(address => bool)) public approved;

    // события
    event Deposit(address _from, uint _amount);
    event Submit(uint _txId);
    event Approve(address _owner, uint _txId);
    event Revoke(address _owner, uint _txId);
    event Executed(uint _txId);

    // конструктор задает нербходимое количество подтверждений
    // проверяет чтобы значение было больше 0 и на больше количества владельцев в массиве
    constructor(address[] memory _owners, uint _requireApprovals) Owner(_owners) {
        require(_requireApprovals > 0 && _requireApprovals <= _owners.length, "Invalid approvals count!");
        requiredApprovals = _requireApprovals;
    }

    function deposit() public payable {
        emit Deposit(msg.sender, msg.value);
    }

    receive() external payable {
        deposit();
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }

    // ставит транзакцию в очередь на выполнение
    function submit(
        address _to,
        uint _value,
        bytes calldata _data
    ) external onlyOwners {
        Transaction memory newTx = Transaction({
            _to: _to,
            _value: _value,
            _data: _data,
            _executed: false
            });
        transactions.push(newTx);
        emit Submit(transactions.length -1);
    }

    // изменяем количество подтверждений
    function changeRequiredApprovals(uint _requiredApprovals) external onlyOwners {
        requiredApprovals = _requiredApprovals;
    }

    // функция кодирует в bytes данные, необходимые для создания транзакции
    function encode(string memory _func, string memory _arg) public pure returns(bytes memory) {
        return abi.encodeWithSignature(_func, _arg);
    }

    // модификаторы: транзакция существует 
    modifier txExist(uint _txId) {
        require(_txId < transactions.length, "tx does not exist");
        _;
    }

    // не подтверждена
    modifier notApproved(uint _txId) {
        require(!_isApproved(_txId, msg.sender), "tx already approved");
        _;
    }

    // не выполнена
    modifier notExecuted(uint _txId) {
        require(!transactions[_txId]._executed, "tx already executed!");
        _;
    }

    // функция для модификатора notApproval
    function _isApproved(uint _txId, address _addr) private view returns(bool) {
        return approved[_txId][_addr];
    }

    // подтверждаем транзакцию
    function approve(uint _txId)
    external
    onlyOwners
    txExist(_txId)
    notApproved(_txId)
    notExecuted(_txId)
    {
        approved[_txId][msg.sender] = true;
        approvalsCount[_txId] += 1;
        emit Approve(msg.sender, _txId);
    }

    // модификатора проверяет, что транзакция была ранее одобрена эти владельцем
    modifier  wasApproved(uint _txId) {
        require(_isApproved(_txId, msg.sender), "tx not yet approved");
        _;
    }

    // функция позволяет отозвать разрешение на запуск транзакции
    function revoke(uint _txId)
    external
    onlyOwners
    wasApproved(_txId)
    txExist(_txId)
    notExecuted(_txId) {
        approved[_txId][msg.sender] = false;
        approvalsCount[_txId] -= 1;
        emit Revoke(msg.sender, _txId);
    }

    // проверяем достаточно ли подтвержедний
    modifier enoughEpprovals(uint _txId) {
        require(approvalsCount[_txId] >= requiredApprovals, "Not enough epprovals!");
        _;
    }

    // выполняет транзакцию
    function execute(uint _txId) 
    external
    txExist(_txId)
    notExecuted(_txId)
    enoughEpprovals(_txId) {
        Transaction storage myTx = transactions[_txId];
        (bool success,) = myTx._to.call{value: myTx._value}(myTx._data);
        require(success, "tx failed");
        myTx._executed = true;
        emit Executed(_txId);
    }
}