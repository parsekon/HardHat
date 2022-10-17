// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC1155MetadataURI.sol";
import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./ERC165.sol";

contract ERC1155 is ERC165, IERC1155, IERC1155MetadataURI {
    mapping(uint => mapping(address => uint)) private _balances;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint) public view virtual returns (string memory) {
        return _uri;
    }

    function balanceOf(address account, uint id) public view returns (uint) {
        require(account != address(0));

        return _balances[id][account];
    }

    function balanceOfBatch(address[] calldata accounts, uint[] calldata ids)
        public
        virtual
        returns (uint[] memory batchBalances)
    {
        require(accounts.length == ids.length);

        batchBalances = new uint[](accounts.length);

        for (uint i; i < accounts.length; i++) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }
    }

    function setApprovalForAll(address operator, bool approved)
        external
        virtual
    {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address account, address operator)
        public
        view
        virtual
        returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint id,
        uint amount,
        bytes calldata data
    ) public virtual {
        require(from == msg.sender || isApprovedForAll(from, msg.sender));
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint[] calldata ids,
        uint[] calldata amounts,
        bytes calldata data
    ) public virtual {
        require(from == msg.sender || isApprovedForAll(from, msg.sender));

        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _mint(
        address to,
        uint id,
        uint amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0));
        address operator = msg.sender;

        uint[] memory ids = _asSingltonArray(id);
        uint[] memory amounts = _asSingltonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;

        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptenceCheck(
            operator,
            address(0),
            to,
            id,
            amount,
            data
        );
    }

    function _mintBatch(
        address to,
        uint[] memory ids,
        uint[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length);
        require(to != address(0));

        address operator = msg.sender;

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptenceCheck(
            operator,
            address(0),
            to,
            ids,
            amounts,
            data
        );
    }

    function _burn(
        address from,
        uint id,
        uint amount
    ) internal virtual {
        require(from != address(0));

        address operator = msg.sender;

        uint[] memory ids = _asSingltonArray(id);
        uint[] memory amounts = _asSingltonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint fromBalance = _balances[id][from];
        require(fromBalance >= amount);

        _balances[id][from] = fromBalance - amount;

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    function _burnBatch(
        address from,
        uint[] memory ids,
        uint[] memory amounts
    ) internal virtual {
        require(ids.length == amounts.length);
        require(from != address(0));

        address operator = msg.sender;

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint i; i < ids.length; i++) {
            uint id = ids[i];
            uint amount = amounts[i];
            uint fromBalance = _balances[id][from];
            require(fromBalance >= amount);
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");

        _doSafeBatchTransferAcceptenceCheck(
            operator,
            from,
            address(0),
            ids,
            amounts,
            ""
        );
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint id,
        uint amount,
        bytes calldata data
    ) internal virtual {
        require(to != address(0));

        address operator = msg.sender;

        uint[] memory ids = _asSingltonArray(id);
        uint[] memory amounts = _asSingltonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint fromBalance = _balances[id][from];
        require(fromBalance >= amount);

        _balances[id][from] = fromBalance - amount;
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptenceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint[] calldata ids,
        uint[] calldata amounts,
        bytes calldata data
    ) internal virtual {
        require(ids.length == amounts.length);
        require(to != address(0));

        address operator = msg.sender;

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint i; i < ids.length; i++) {
            uint id = ids[i];
            uint amount = amounts[i];
            uint fromBalance = _balances[id][from];
            require(fromBalance >= amount);
            _balances[id][from] = fromBalance - amount;
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptenceCheck(
            operator,
            from,
            to,
            ids,
            amounts,
            data
        );
    }

    function _setURI(string memory newUri) internal virtual {
        _uri = newUri;
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator);

        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint[] memory ids,
        uint[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint[] memory ids,
        uint[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptenceCheck(
        address operator,
        address from,
        address to,
        uint id,
        uint amount,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try
                IERC1155Receiver(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    amount,
                    data
                )
            returns (bytes4 resp) {
                if (resp != IERC1155Receiver.onERC1155Received.selector) {
                    revert("Rejected tokens!");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("Non-ERC1155 receiver!");
            }
        }
    }

    function _doSafeBatchTransferAcceptenceCheck(
        address operator,
        address from,
        address to,
        uint[] memory ids,
        uint[] memory amounts,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try
                IERC1155Receiver(to).onERC1155BatchReceived(
                    operator,
                    from,
                    ids,
                    amounts,
                    data
                )
            returns (bytes4 resp) {
                if (resp != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("Rejected tokens!");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("Non-ERC1155 receiver!");
            }
        }
    }

    function _asSingltonArray(uint el)
        private
        pure
        returns (uint[] memory result)
    {
        result = new uint[](1);
        result[0] = el;
    }
}
