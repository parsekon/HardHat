// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract Weth is ERC20 {
    event Deposit(address indexed initiator, uint amount);
    event Withdraw(address indexed initiator, uint amount);

    constructor () ERC20("WrappedEther", "WETH", 18, 0) {}

    function deposit() public payable {
        mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    receive() external payable {
        deposit();
    }

    function withdraw(uint _amount) public {
        burn(msg.sender, _amount);
        (bool success,) = msg.sender.call{value: _amount}("");
        require(success, "Finished!");
        emit Withdraw(msg.sender, _amount);
    }
}