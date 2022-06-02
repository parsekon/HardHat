// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TodoList {
    struct Todo {
        string title;
        string description;
        bool complete;
    }

    struct TodoUser {
        address user;
        uint indexTodo;
        bool isCompleteUser;
    }

    TodoUser[] public todosUsers;
    Todo[] public todos;

    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner!");
        _;
    }
    
    modifier isRedy(uint index) {
        require(todos[index].complete == false, "Todo is already been complete!");
        _;
    }

    function addTodo(string calldata _title, string calldata _description) external onlyOwner {
        todos.push(Todo({
            title: _title,
            description: _description,
            complete: false
        }));
    }

    function editTodo(string calldata _newTitle, string calldata _newDescription, uint index) external onlyOwner isRedy(index) {
        Todo storage myTodo = todos[index];
        myTodo.title = _newTitle;
        myTodo.description = _newDescription;
    }

    function editTitle(string calldata _newTitle, uint index) external onlyOwner isRedy(index) {
        todos[index].title = _newTitle;
    }

    function editDescription(string calldata _newDescription, uint index) external onlyOwner isRedy(index) {
        todos[index].description = _newDescription;
    }

    function isComplete(uint index) external isRedy(index) onlyOwner {
        todos[index].complete = !todos[index].complete;
    }

    function isCompleteUser(uint index) external isRedy(index) {
        todosUsers.push(TodoUser({
            user: msg.sender,
            indexTodo: index,
            isCompleteUser: true
        }));
    }

    function readTodo(uint index) external view onlyOwner returns(string memory, string memory, bool) {
        return(
            todos[index].title,
            todos[index].description,
            todos[index].complete
         );
    }
}