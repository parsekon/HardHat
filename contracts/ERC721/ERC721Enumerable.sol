// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./IERC721Enumerable.sol";

abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // массив, содержащий все уникальные Id
    uint[] private _allTokens;
    // маппинг владелец addr -> index -> Id NFT
    mapping(address => mapping(uint => uint)) private _ownedTokens;
    // маппинг содержит Id токена -> index для упрощения поиска в массиве
    mapping(uint => uint) private _allTokensIndex;
    // сохраняем на каком индексе находится токен
    mapping(uint => uint) private _ownedTokensIndex;

    // функция возвращает длину массива, содержащего все уникальные id токенов
    function totalSupply() public view returns (uint) {
        return _allTokens.length;
    }

    // проверяем что индекс токена не выходит за пределы массива
    // возвращаем Id токена
    function tokenByIndex(uint index) public view returns (uint) {
        require(index < totalSupply(), "out of bounds");

        return _allTokens[index];
    }

    // возвращает id токена по адресу владельца и индексу
    function tokenOfOwnerByIndex(address owner, uint index)
        public
        view
        returns (uint)
    {
        require(index < balanceOf(owner), "out of bonds");

        return _ownedTokens[owner][index];
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns(bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // перед минтом токена
    function _beforeTokenTransfer(
        address from,
        address to,
        uint tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }

        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    // заносим Id токнов в массив _allTokens,
    // но сначала нужно измерить длину массива и присвоить токену индекс
    function _addTokenToAllTokensEnumeration(uint tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromAllTokensEnumeration(uint tokenId) private {
        uint lastTokenIndex = _allTokens.length - 1; // индекс последнего элемента в массиве
        uint tokenIndex = _allTokensIndex[tokenId]; // определяем индекс токена

        uint lastTokenId = _allTokens[lastTokenIndex]; // id последнего токена в массиве

        _allTokens[tokenIndex] = lastTokenId; // присваиваем элементу Id в массиве с нужным индексом значение последнего элемента массива
        // то меняем местами элементы в массиве: последний перемещаем на место удаляемого элемента

        _allTokensIndex[lastTokenId] = tokenIndex; // меняем у перемещенного последнего элемента индекс, на индекс удаленного элемента

        delete _allTokensIndex[tokenId];
        // удаляем последний элемент в массиве
        _allTokens.pop();
    }

    function _addTokenToOwnerEnumeration(address to, uint tokenId) private {
        uint _length = balanceOf(to);

        _ownedTokensIndex[tokenId] = _length;
        _ownedTokens[to][_length] = tokenId;
    }

    function _removeTokenFromOwnerEnumeration(address from, uint tokenId) private {
        uint lastTokenIndex = balanceOf(from) - 1;
        uint tokenIndex = _ownedTokensIndex[tokenId];

        if(tokenIndex != lastTokenIndex) {
            uint lastTokenId = _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }
}
