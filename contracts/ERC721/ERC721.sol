// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./ERC165.sol";
import "./IERC721Metadata.sol";
import "./IERC721.sol";
import "./Strings.sol";
import "./IERC721Receiver.sol";

abstract contract ERC721 is ERC165, IERC721, IERC721Metadata {
    using Strings for uint;
    string private _name;
    string private _symbol;

    // баланс токенов на адресе владельца
    mapping(address => uint) private _balances;

    // id -> владелец токена
    mapping(uint => address) private _owners;

    // структура approve
    mapping(uint => address) private _tokenApprovals;

    // структура разрешений на управление всеми токенами
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // в конструкторе задаем только имя и символ
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    // проверяем право на распоряжение токенами
    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "not approved or owner!"
        );

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes memory data
    ) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "not an owner!");
        _safeTransfer(from, to, tokenId, data);
    }

    // модификатор проверяет сущестовование токена
    modifier _requireMinted(uint tokenId) {
        require(_exists(tokenId), "not minted");
        _;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    // возвращает баланс токенов на адресе
    function balanceOf(address owner) public view returns (uint) {
        require(owner != address(0), "owner cannot be zero");

        return _balances[owner];
    }

    // возвращает владельца токена по ID
    function ownerOf(uint tokenId)
        public
        view
        _requireMinted(tokenId)
        returns (address)
    {
        return _owners[tokenId];
    }

    // аппрув может вызывать либо сам владелец токена, либо адрес, которому доверили управление всеми токенами
    function approve(address to, uint tokenId) public {
        address _owner = _owners[tokenId];

        require(
            _owner == msg.sender || isApprovedForAll(_owner, msg.sender),
            "not an owner!"
        );
        require(to != _owner, "cannot approve to self");
        _tokenApprovals[tokenId] = to;

        emit Approval(_owner, to, tokenId);
    }

    // разрешает адресу operator распоряжаться всеми токенами, находящимися на адресе
    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "cannot approve to self");

        _operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // проверят какой адрес может распоряжаться токеном
    function getApproved(uint tokenId) public view returns (address) {
        return _tokenApprovals[tokenId];
    }

    // возвращает true/false может ли адрес распоряжаться всеми токенами
    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns(bool) {
        return interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _safeMint(address to, uint tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);

        require(_checkOnERC721Received(address(0), to, tokenId, data), "non erc721-receiver");
    }

    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "zero address to");
        require(!_exists(tokenId), "this token is already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _owners[tokenId] = to;
        _balances[to]++;

        emit Transfer(address(0), to, tokenId);
        _afterTokenTransfer(address(0), to, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(msg.sender, tokenId), "not an owner");
        _burn(tokenId);
    }

    function _burn(uint tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        delete(_tokenApprovals[tokenId]);
        _balances[owner]--;
        delete(_owners[tokenId]);

        emit Transfer(owner, address(0), tokenId);
        _afterTokenTransfer(owner, address(0), tokenId);

    }

    // префикс, начальная часть ссылки вида ipfs://, либо mydomen.com/nft/
    // к ней будет пристыковываться tokenId
    // в контракте, который будет наследовать базовый контракт ERC721 baseURI будет определен
    function _baseURI() internal pure virtual returns (string memory) {
        return "";
    }

    // проверяем задан ли baseURI и если да, то делается "склейка"
    // для преобразования tokenId в строку используем библиотеку OpenZeppelin Strings.sol
    // также проверяем что запрошенный токен существует
    function tokenURI(uint tokenId)
        public
        view
        virtual
        _requireMinted(tokenId)
        returns (string memory)
    {
        string memory baseURI = _baseURI();

        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    // проверяем существует ли владелец
    function _exists(uint tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    // функция проверяет право управления токеном
    function _isApprovedOrOwner(address spender, uint tokenId)
        internal
        view
        returns (bool)
    {
        address owner = ownerOf(tokenId);

        return (spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender);
    }

    // главное отличие этой функции от transfer проверка на возможность получения NFT 
    function _safeTransfer(
        address from,
        address to,
        uint tokenId,
        bytes memory data
    ) internal {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, data),
            "transfer to non-erc721 receiver"
        );
    }

    // проверяет может ли адрес принимать токены ERC721
    // возвращает true / false
    // проверка логична, если адресом получателя является смарт-контракт
    // для обычного адреса проблем нет
    // контракт, который будет принимать NFT должен импортировать интерфейс IERC721Receiver и содержать функцию onERC721Received(msg.sender, from, tokenId, data), 
    // которая при отправке запроса должна возвращать собственный селектор
    // те смарт-контракт сообщает: Да, у меня есть такая функция onERC721Received, и это означает, что я могу принимать NFT
    // если такое сообщение не возвращается, то в catch обрабатывается сообщение об ошибке:
    // - такой функции в контракте нет, либо она пустая
    // - такая функция все-таки есть, но она возвращает ошибку. Мы не знаем длину reason поэтому используем assembly, 
    // где обрезаем первые 32 байта, которые содержат информацию о длине массива, а все остальное считываем и возвращаем в качестве ошибки
    function _checkOnERC721Received(
        address from,
        address to,
        uint tokenId,
        bytes memory data
    ) private returns(bool) {
        if(to.code.length > 0) {
           try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns(bytes4 retval) {
            return retval == IERC721Receiver.onERC721Received.selector;
           } catch (bytes memory reason) {
            if(reason.length == 0) {
                revert("Transfer to  non-erc721 receiver");
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
           }
        } else {
            return true;
        }
    }

    // внутренняя функция отправки токенов
    function _transfer(
        address from,
        address to,
        uint tokenId
    ) internal {
        require(ownerOf(tokenId) == from, "incorrect owner");
        require(to != address(0), "to address is zero");

        _beforeTokenTransfer(from, to, tokenId);

        delete _tokenApprovals[tokenId];

        _balances[from]--;
        _balances[to]++;

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address _from,
        address _to,
        uint tokenId
    ) internal virtual {}
}
