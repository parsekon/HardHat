// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Owner.sol";
import "./ERC20.sol";

contract TokenSell is Owner {
    IERC20 public token;
    address addrThis = address(this);
    uint public rate;

    event Buyer(address indexed buyer, uint amount);
    event Seller(address indexed seller, uint amount);

    constructor(IERC20 _token) {
        owner = msg.sender;
        token = _token;
        rate = 0.001 ether;
    }

    function balanceThis() public view returns (uint) {
        return addrThis.balance;
    }

    function balanceToken() public view returns (uint) {
        return token.balanceOf(addrThis);
    }

    function setRate(uint _rate) public onlyOwner {
        rate = _rate;
    }

    function buy() public payable {
        uint tokenAvalable = token.balanceOf(addrThis);
        uint tokenBuy = msg.value / rate;
        require(msg.value >= rate, "Incorrect sum");
        require(tokenAvalable >= tokenBuy, "Not enough tokens");
        token.transfer(msg.sender, tokenBuy);
        emit Buyer(msg.sender, tokenBuy);
    }

    function sell(uint _value) public {
        require(_value > 0, "Tokens must be greater then 0");
        uint allowans = token.allowance(msg.sender, addrThis);
        require(allowans >= _value, "Wrong allowance");
        require(addrThis.balance >= _value * rate, "Market have not Ether");
        token.transferFrom(msg.sender, addrThis, _value);
        payable(msg.sender).transfer(_value * rate);
        emit Seller(msg.sender, _value);
    }

    function withdraw(uint amount) public onlyOwner {
        require(amount <= balanceThis(), "Not enough fonds!");
        payable(owner).transfer(amount);
    }

    function withdrawToken(uint amount) public onlyOwner {
        require(token.balanceOf(addrThis) >= amount, "Not enough token!");
        token.transfer(owner, amount);
    }

    fallback() external payable {
        buy();
    }

    receive() external payable {
        buy();
    }
}
