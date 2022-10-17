// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract Crowd {
    struct Campaing {
        address owner;
        uint goal;
        uint pledged;
        uint startAt;
        uint endAt;
        bool clamed;
    }

    IERC20 public immutable token;

    mapping(uint => Campaing) public campaings;
    mapping(uint => mapping(address => uint)) public pledges;

    uint public constant MAX_DURATION = 100 days;
    uint public constant MIN_DURATION = 10;
    uint public currentId;

    event Launched(uint id, address owner, uint goal, uint start, uint end);
    event Cancel(uint id);
    event Pledged(uint id, address sender, uint amount);
    event Unpledged(uint id, address sender, uint amount);
    event Clamed(uint _id);
    event Refunded(uint id, address sender, uint amount);

    constructor (address _token) {
        token = IERC20(_token);
    }

    function luched(uint _goal, uint _startAt, uint _endAt) external {
        require(_startAt >= block.timestamp, "");
        require(_endAt >= _startAt + MIN_DURATION, "");
        require(_endAt <= _startAt + MAX_DURATION, "");

        campaings[currentId] = Campaing({
            owner: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            clamed: false
        });

        emit Launched(currentId, msg.sender, _goal, _startAt, _endAt);
        currentId++;
    }

    function cancel(uint _id) external {
        Campaing memory campaing = campaings[_id];

        require(msg.sender == campaing.owner, "");
        require(block.timestamp < campaing.startAt, "");

        delete campaings[_id];

        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        Campaing storage campaing = campaings[_id];

        require(block.timestamp >= campaing.startAt, "");
        require(block.timestamp < campaing.endAt, "");

        campaing.pledged += _amount;
        pledges[_id][msg.sender] += _amount;

        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledged(_id, msg.sender, _amount);
    }

    function unpledge(uint _id, uint _amount) external {
        Campaing storage campaing = campaings[_id];

        require(block.timestamp < campaing.endAt, "");

        campaing.pledged -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledged(_id, msg.sender, _amount);
    }

    function claim(uint _id) external {
        Campaing storage campaing = campaings[_id];

        require(msg.sender == campaing.owner, "");
        require(block.timestamp > campaing.endAt, "");
        require(campaing.pledged >= campaing.goal, "");
        require(!campaing.clamed, "");

        campaing.clamed = true;
        token.transfer(msg.sender, campaing.pledged);

        emit Clamed(_id);
    }

    function refund(uint _id) external {
        Campaing storage campaing = campaings[_id];
        require(block.timestamp > campaing.endAt, "");
        require(campaing.pledged < campaing.goal, "");

        uint pledgedAmount = pledges[_id][msg.sender];
        pledges[_id][msg.sender] = 0;
        token.transfer(msg.sender, pledgedAmount);

        emit Refunded(_id, msg.sender, pledgedAmount);
    }
}