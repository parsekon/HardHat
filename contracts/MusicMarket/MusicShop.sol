// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Ownable.sol";

contract MusicShop is Owner {
    // объект альбом индекс, товарный номер, название, цена, количество
    struct Album {
        uint index;
        string uid;
        string title;
        uint price;
        uint quantity;
    }

    Album[] public albums;

    // маппинг содержит информацию о количестве альбомов одного исполнителя
    mapping(string => uint) public quantityAlbum;

    // объект заказа тованый номер альбома, покупатель, дата покупки, статус заказа
    struct Order {
        string albumUid;
        address customer;
        uint orderdAt;
        uint quantityPaid;
        OrderStatus status;
    }

    Order[] public orders;

    // статус заказа
    enum OrderStatus {
        Paid,
        Delivered
    }

    // текущий индекс
    uint currentIndex;

    // события появился новый альбом, продажа альбома, альбом отправлен
    event AddAlbum(string _title, uint _price);
    event AlbumBought(
        string indexed uid,
        address indexed customer,
        uint indexed timestamp
    );
    event OrderDelivered(string indexed albumUid, address indexed customer);

    // добавляем новый альбом
    function addAlbum(
        string calldata uid,
        string calldata title,
        uint price,
        uint quantity
    ) external onlyOwners {
        Album memory addedAlbum = Album({
            index: currentIndex,
            uid: uid,
            title: title,
            price: price,
            quantity: quantity
        });
        albums.push(addedAlbum);
        quantityAlbum[addedAlbum.title] += addedAlbum.quantity;
        currentIndex++;
        emit AddAlbum(title, price);
    }

    // выводим список всех альбомов
    function allAlbums() external view returns (Album[] memory) {
        Album[] memory AlbumList = new Album[](albums.length);
        for (uint i = 0; i < albums.length; i++) {
            AlbumList[i] = albums[i];
        }
        return AlbumList;
    }

    // покупка альбома
    function buy(uint _index, uint _quantity) external payable {
        Album storage albumToBuy = albums[_index];
        require(msg.value == albumToBuy.price * _quantity, "invalid price");
        require(quantityAlbum[albumToBuy.title] >= _quantity, "out of stock!");
        require(_quantity > 0, "Not zero!");
        quantityAlbum[albumToBuy.title] -= _quantity;
        orders.push(
            Order({
                albumUid: albumToBuy.uid,
                customer: msg.sender,
                orderdAt: block.timestamp,
                quantityPaid: _quantity,
                status: OrderStatus.Paid
            })
        );
        emit AlbumBought(albumToBuy.uid, msg.sender, block.timestamp);
    }

    // изменяем статус на отправлено
    function delivered(uint _index) external onlyOwners {
        Order storage cOrder = orders[_index];
        require(cOrder.status != OrderStatus.Delivered, "invalid status");
        cOrder.status = OrderStatus.Delivered;
        emit OrderDelivered(cOrder.albumUid, cOrder.customer);
    }

    function withdraw(uint amount) external onlyOwners {
        require(address(this).balance >= amount, "Not enough funds");
        payable(msg.sender).transfer(amount);
    }

    function balanceShop() external view onlyOwners returns (uint balance) {
        balance = address(this).balance;
    }

    // ограничиваем воод средств напрямую, тк нет информации какой альбом хочет преобрести человек
    receive() external payable {
        revert("");
    }
}
