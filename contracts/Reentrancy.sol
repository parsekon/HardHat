// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionRe {
    mapping(address => uint) public bidders;
    bool private locked;

    modifier reentrancyGuard() {
        require(!locked, "denied");
        locked = true;
        _;
        locked = false;
    }

    function bid() external payable {
        bidders[msg.sender] += msg.value;
    }

    function refund() external reentrancyGuard {
        address bidder = msg.sender;

        if(bidders[bidder] > 0) {
            bidders[bidder] = 0;
            (bool success,) = bidder.call{value: bidders[bidder]}("");
            require(success, "failed");
        }
    }

    function currentBalance() public view returns(uint) {
        return address(this).balance;
    }
}

contract AttakRe {
    uint constant SUM = 1 ether;
    AuctionRe auction;

    constructor(address _auction) {
        auction = AuctionRe(_auction);
    }
    
    function doBid() external payable {
        auction.bid{value: SUM}();
    }

    function attack() external {
        auction.refund();
    }
     
    receive() external payable {
        if(auction.currentBalance() >= SUM) {
            auction.refund();
        }
    }
}