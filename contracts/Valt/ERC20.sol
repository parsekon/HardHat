// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Owner.sol";
import "./IERC20.sol";

contract ERC20 is IERC20, Owner {
    mapping (address => uint) balances;
    mapping (address => mapping(address => uint)) allowances;

    string name_;
    string symbol_;
    uint decimal;

    uint _totalSupply;

    event ChangeOwner(address owner);

    modifier enoughTokens(address _from, uint _amount) {
        require(balanceOf(_from) >= _amount, "Not enough tokens.");
        _;
    }

    constructor (string memory _name, string memory _symbol, uint _decimal, uint initialSupply) {
        name_ = _name;
        symbol_ = _symbol;
        decimal = _decimal;
        owner = msg.sender;
        mint(msg.sender, initialSupply*10**decimal);
    }

    function name() external view override returns(string memory) {
        return name_;
    }

    function symbol() external view override returns(string memory) {
        return symbol_;
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

    function mint(address _to, uint amount) public {
        balances[_to] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), _to, amount);
    }

    function burn(address from, uint amount) public enoughTokens(msg.sender, amount) {
        balances[from] -= amount;
        _totalSupply -= amount;
        emit Transfer(address(0), from, amount);
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
        emit ChangeOwner(owner);
    }
}


contract TokenValt is ERC20 {
    constructor() ERC20("TokenValt", "TKV", 18, 1000) {}
}