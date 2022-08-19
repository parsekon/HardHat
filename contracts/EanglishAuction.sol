// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* 
    для аукциона устанавливается минимальная стартовая ставка, время окончания andAt, 
    bool переменная старта и окончания аукциона
    последняя максимальная ставка и адрес
*/

contract EanglishAuction {
    address public seller;
    string public item;
    uint public timeOpen;
    uint public endTime;
    bool public start;
    bool public end;
    address public higestBidder;
    uint public higestBid;
    mapping (address => uint) public bids;

    event AuctionStart(string _item, uint _higestBid);
    event MakeBid(uint _bid, address _bidder);
    event AuctionEnd(address _higestBidder, uint _higestBid);
    event Withdraw(address _bidder, uint _amoutWithdraw);

    constructor(string memory _item, uint _startingBid, uint _timeOpen) {
        seller = msg.sender;
        item = _item;
        higestBid = _startingBid;
        timeOpen = _timeOpen;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "You can not to make this action");
        _;
    }

    modifier notEnded() {
        require(block.timestamp < endTime, "Already ended!");
        _;
    }

    modifier hasStarted() {
        require(start, "Auction not started");
        _;
    }

    modifier hasNotStarted() {
        require(!start, "Auction alredy started");
        _;
    }

    modifier balanceBidsNotZero() {
        require(bids[msg.sender] > 0, "You have not a withdraw");
        _;
    }

    modifier notHigestBidder() {
        if(!end) {
            require(msg.sender != higestBidder, "You are higest bidder and can not withdraw money!");
        }
        _;
    }

    function balanceAuction() public view onlySeller returns(uint balance) {
        balance = address(this).balance;
    }

    function newAuction(uint _time, string memory _item, uint _startBid) external hasNotStarted {
        seller = msg.sender;
        require(balanceAuction() == 0, "Not everyone has withdraw their funds yet!");
        timeOpen = _time;
        item = _item;
        higestBid = _startBid;
        higestBidder = address(0);
        end = false;
    }

    function auctionStarted() external onlySeller hasNotStarted {
        start = true;
        endTime = block.timestamp + timeOpen;

        emit AuctionStart(item, higestBid);
    }

    function auctionEnded() external onlySeller hasStarted {
        require(!end, "Already ended!");
        require(block.timestamp >= endTime, "Too early stop auction");
        end = true;
        start = false;

        if(higestBidder != address(0)) {
            payable(seller).transfer(higestBid);
            bids[higestBidder] -= higestBid;
        }

        emit AuctionEnd(higestBidder, higestBid);
    }

    function  makeBid() external payable notEnded hasStarted {
        require(msg.value > higestBid, "Bid is small");
        bids[msg.sender] += msg.value;
        
        higestBidder = msg.sender;
        higestBid = msg.value;

        emit MakeBid(msg.value, msg.sender);
    }

    function withdraw() external balanceBidsNotZero notHigestBidder {
        uint amoutWithdraw = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amoutWithdraw);

        emit Withdraw(msg.sender, amoutWithdraw);
    }  
}