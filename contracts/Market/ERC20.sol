// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Owner.sol";

interface IERC20 {
    function decimals() external view returns(uint);

    function totalSupply() external view returns(uint);

    function balanceOf(address account) external view returns(uint);

    function transfer(address to, uint amount) external returns(bool);

    function allowance(address owner, address spender) external view returns(uint);

    function approve(address spender, uint amount) external;

    function transferFrom(address sender, address recipient, uint amount) external;

    event Transfer(address indexed from, address indexed to, uint amount);

    event Approval(address indexed owner, address indexed to, uint amount);
}

contract ERC20 is IERC20, Owner {
    mapping (address => uint) balances;
    mapping (address => mapping(address => uint)) allowances;

    string public name;
    string public symbol;

    uint decimal;

    uint _totalSupply;

    event ChangeOwner(address owner);

    constructor (string memory _name, string memory _symbol, uint _decimal, uint _total) {
        name = _name;
        symbol = _symbol;
        decimal = _decimal;

        owner = msg.sender;

        mint(_total*10**decimal);

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier enoughTokens(address _from, uint _amount) {
        require(balanceOf(_from) >= _amount, "Not enough tokens.");
        _;
    }

    function decimals() external view override returns(uint) {
        return decimal;
    }

    function totalSupply() external view override returns(uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns(uint) {
        return balances[account];
    }

    function transfer(address to, uint amount) external override enoughTokens(msg.sender, amount) returns(bool) {
        balances[msg.sender] -= amount;
        balances[address(to)] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address _owner, address spender) external view override returns(uint) {
        return allowances[_owner][spender];
    }

    function approve(address spender, uint amount) public virtual override {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint amount) public override enoughTokens(sender, amount) {
        allowances[sender][recipient] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function mint(uint amount) public onlyOwner {
        balances[msg.sender] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) public onlyOwner enoughTokens(msg.sender, amount) {
        balances[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
        emit ChangeOwner(owner);
    }

    fallback() external payable {

    }

    receive() external payable {

    }
}