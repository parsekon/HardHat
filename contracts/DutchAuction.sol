// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// контракт английский аукцион
// устанавливается стартовая цена startingPrice товара item, шаг уменьшения цены в зависимости от времени которое прошло со старта аукциона
// время старта startAt и время окончания endAt
// модификатор checkEnds проверяет не закончился ли аукцион
// getPrice проверяет актуальную цену товара
// buy покупается товар

contract DucthAuction {
    uint public DURATION = 2 days;
    address public seller;
    uint public startingPrice;
    uint public discountPrice;
    uint public startAt;
    uint public endAt;
    string public item;
    bool public stopped;

    modifier checkEnds() {
        require(!stopped, "Auction ended!");
        _;
    }

    constructor (
        uint _startingPrice, uint _discountPrice, string memory _item
    ) {
        seller = payable(msg.sender);
        item = _item;
        startingPrice = _startingPrice;
        discountPrice = _discountPrice;
        startAt = block.timestamp;
        endAt = block.timestamp + DURATION;
        require(_startingPrice >= discountPrice * DURATION, "Starting price and discount incorrect!");
    }

    function startNewAuction(uint _startingPrice, string memory _item, uint _discountPrice, uint _duration) external {
        require(stopped, "The auction is still going on");
        stopped = false;
        seller = msg.sender;
        startingPrice = _startingPrice;
        item = _item;
        discountPrice = _discountPrice;
        startAt = block.timestamp;
        endAt = startAt + DURATION;
        DURATION = _duration;
        require(_startingPrice >= discountPrice * DURATION, "Starting price and discount incorrect!");
    }

    // getPrice
    function getPrice() public view checkEnds returns(uint) {
        return (startingPrice - (block.timestamp - startAt) * discountPrice);
    }

    // buy
    function buy() payable public checkEnds {
        require(block.timestamp < endAt, "Auction ended!");
        uint currentPrice = getPrice();
        require(msg.value >= currentPrice, "Not enougth value");
        uint _refund = msg.value - currentPrice;
        if(_refund > 0) {
            payable(msg.sender).transfer(_refund);
        } 
        payable(seller).transfer(currentPrice);
        stopped = true;
    }
}