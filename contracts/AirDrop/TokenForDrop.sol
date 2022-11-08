// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenDrop is ERC20 {
    constructor() ERC20("TokenDrop", "TAD") {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }

    function decimals() public pure override returns (uint8) {
        return 0;
    }
}