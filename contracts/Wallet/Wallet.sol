// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SharedWallet.sol";


contract Wallet is SharedWallet {
    event MoneyWithdraw(address indexed _to, uint _amount);
    event ReceivedMoney(address _from, uint _amount);

    function getBallance() public view returns(uint) {
        return address(this).balance;
    }

    function withdraw(uint _amount) external {
        require(getBallance() >= _amount, "not enough funds!");
        bool _isAdmin = members[msg.sender].isAdmin;

        if(isOwner() || _isAdmin) {
            payable(msg.sender).transfer(_amount);
            emit MoneyWithdraw(msg.sender, _amount);
        } else {
            require(members[msg.sender].limit >= _amount, "Not enough Limit");
            deduceFromLimit(msg.sender, _amount);
            payable(msg.sender).transfer(_amount);
            emit MoneyWithdraw(msg.sender, _amount);
        }
    }

    fallback() external payable {}
    receive() external payable {
        emit ReceivedMoney(msg.sender, msg.value);
    }
}