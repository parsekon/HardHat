// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Multisender is Ownable {
    IERC20 public token;
    // address[] public addressForSend;
    // uint[] public amount;

    event SendSingleSuccess(string success, uint lengthArr, uint amount);
    event SendSingleBatch(string successBatch, uint lengthArrBatch);
    event ChangeToken(address newToken);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function changeToken(address _token_) external onlyOwner {
        require(_token_ != address(0), "Address should not be zero!");
        token = IERC20(_token_);

        emit ChangeToken(_token_);
    }

    function multisendSingle(address[] memory _addressForSend, uint _amount) external {
        for(uint i = 0; i < _addressForSend.length; i++) {
            require(_addressForSend[i] != address(0));
            token.transferFrom(msg.sender, _addressForSend[i], _amount);
        }

        emit SendSingleSuccess("Success!", _addressForSend.length, _amount);
    }

    function multisendBatch(address[] memory _addressForSend, uint[] memory value) external {
        for(uint i = 0; i < _addressForSend.length; i++) {
            require(_addressForSend[i] != address(0));
            require(_addressForSend.length == value.length);
            token.transferFrom(msg.sender, _addressForSend[i], value[i]);
        }

        emit SendSingleBatch("Success!", _addressForSend.length);
    }
}


    // [
    //     "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB",
    //     "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
    //     "0x617F2E2fD72FD9D5503197092aC168c91465E7f2",
    //     "0x17F6AD8Ef982297579C203069C1DbfFE4348c372",
    //     "0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678",
    //     "0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7",
    //     "0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C",
    //     "0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC",
    //     "0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c",
    //     "0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C",
    //     "0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB", 
    //     "0x583031D1113aD414F02576BD6afaBfb302140225",
    //     "0xdD870fA1b7C4700F2BD7f44238821C26f7392148"
    // ]

    // [
    //     1,
    //     2,
    //     3,
    //     4,
    //     5,
    //     6,
    //     7,
    //     8,
    //     9,
    //     10,
    //     11,
    //     12,
    //     13
    // ]