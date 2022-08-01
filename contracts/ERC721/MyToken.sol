// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./ERC721.sol";
import "./ERC721URIStorage.sol";
import "./ERC721Enumerable.sol";

contract MyToken is ERC721, ERC721Enumerable, ERC721URIStorage {
    address public owner;
    // счетчик наминченных токенов
    uint currentTokenId;

    constructor() ERC721("MyToken", "MTK") {
        owner = msg.sender;
    }

    // для tokenId содержащего строковые значения необходимо дополнительное расшиерение ERC721URIStorage и функция _setTokenURI
    function safeMint(address to, string calldata tokenId) public {
        require(owner == msg.sender, "Not an owner!");

        _safeMint(to, currentTokenId);
        _setTokenURI(currentTokenId, tokenId);
        currentTokenId++;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns(bool) {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function _burn(uint tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
