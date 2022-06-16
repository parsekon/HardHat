// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SharedWallet is Ownable {
    struct User {
        string name;
        uint limit;
        bool isAdmin;
    }

    mapping(address => User) public members;

    event AddMember(address _member, uint _limit);
    event LimitChanged(address _member, uint _oldLimit, uint _newLimit);

    function isOwner() internal view returns(bool) {
        return owner() == msg.sender;
    }

    function deduceFromLimit(address _member, uint _amount) internal {
        uint _oldLimit = members[_member].limit;
        members[_member].limit -= _amount;
        uint _newLimit = members[_member].limit;

        emit LimitChanged(_member, _oldLimit, _newLimit);
    }

    function addUser (
        string memory _name,
        address _member,
        uint _limit,
        bool _isAdmin
        ) external onlyOwner  {
        if(members[_member].limit > 0) {
            uint _oldLimit = members[_member].limit;
            members[_member].limit = _limit;
            uint _newLimit = members[_member].limit;

            emit LimitChanged(_member, _oldLimit, _newLimit);
        }

        User memory newUser = User(_name, _limit, _isAdmin); 
        members[_member] = newUser;

        emit AddMember(_member, _limit);
    }

    function makeAdmin(address _member) external onlyOwner {
        members[_member].isAdmin = true;
    }

    function revokeAdmin(address _member) external onlyOwner {
        members[_member].isAdmin = false;
    }

    function deleteMember(address _member) external onlyOwner {
        delete members[_member];
    }

    function renounceOwnership() public pure override {
        revert("Can't renounce");
    }
}