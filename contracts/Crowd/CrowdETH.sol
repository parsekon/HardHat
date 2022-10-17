// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdETH {
    struct Campaing {
        address owner;
        uint goal;
        uint pledged;
        uint startAt;
        uint endAt;
        bool clamed;
    }

    mapping(uint => Campaing) public campaings;
    mapping(uint => mapping(address => uint)) public pledges;

    // uint public constant MAX_DURATION = 100 days;
    // uint public constant MIN_DURATION = 10;
    uint public currentId;

    event Launched(uint id, address owner, uint goal, uint start, uint end);
    event Cancel(uint id);
    event Pledged(uint id, address sender, uint amount);
    event Unpledged(uint id, address sender, uint amount);
    event Clamed(uint _id);
    event Refunded(uint id, address sender, uint amount);

    function luched(uint _goal, uint _startAt, uint _endAt) external {
        // require(_startAt >= block.timestamp, "");
        // require(_endAt >= _startAt + MIN_DURATION, "");
        // require(_endAt <= _startAt + MAX_DURATION, "");

        campaings[currentId] = Campaing({
            owner: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: block.timestamp,
            endAt: block.timestamp + 40,
            clamed: false
        });

        emit Launched(currentId, msg.sender, _goal, _startAt, _endAt);
        currentId++;
    }

    function cancel(uint _id) external {
        Campaing memory campaing = campaings[_id];

        require(msg.sender == campaing.owner, "1");
        require(block.timestamp < campaing.startAt, "2");

        delete campaings[_id];

        emit Cancel(_id);
    }

    function pledge(uint _id) public payable {
        Campaing storage campaing = campaings[_id];
        uint amount = msg.value;

        require(block.timestamp >= campaing.startAt, "3");
        require(block.timestamp < campaing.endAt, "4");

        campaing.pledged += amount;
        pledges[_id][msg.sender] += amount;

        payable(address(this)).transfer(amount);

        emit Pledged(_id, msg.sender, amount);
    }

    function unpledge(uint _id, uint _amount) external {
        Campaing storage campaing = campaings[_id];

        require(block.timestamp < campaing.endAt, "5");

        campaing.pledged -= _amount;
        payable(msg.sender).transfer(_amount);

        emit Unpledged(_id, msg.sender, _amount);
    }

    function claim(uint _id) external {
        Campaing storage campaing = campaings[_id];

        require(msg.sender == campaing.owner, "6");
        require(block.timestamp > campaing.endAt, "7");
        require(campaing.pledged >= campaing.goal, "8");
        require(!campaing.clamed, "9");

        campaing.clamed = true;
        payable(msg.sender).transfer(campaing.pledged);

        emit Clamed(_id);
    }

    function refund(uint _id) external {
        Campaing storage campaing = campaings[_id];
        require(block.timestamp > campaing.endAt, "10");
        require(campaing.pledged < campaing.goal, "11");

        uint pledgedAmount = pledges[_id][msg.sender];
        pledges[_id][msg.sender] = 0;
        payable(msg.sender).transfer(pledgedAmount);

        emit Refunded(_id, msg.sender, pledgedAmount);
    }

    function getBalance() public view returns(uint balance) {
        balance = address(this).balance;
    }

    receive() external payable {
        pledge(currentId - 1);
    }

    fallback() external payable {}
}