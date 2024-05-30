// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract FinalProject {

    address  authority;
    string authorityMobile;
    
    struct Person {
        string name;
        string mobile;
        string password;
        uint balance;
        address walletAddress;
        bool created;
    }

    struct Mobile{
        string mobile;
    }

    struct Transaction {
        string from;
        string to;
        uint amount;
        uint timestamp;
    }

    mapping (string => Person)  users;
    mapping  (address => Mobile) userMobile;
    mapping (address => Transaction[]) transactionHistory;

    constructor () {

        string memory _name = "ru";
        string memory _mobile = "01521234916";
        string memory _password = "@ru";

        authority = msg.sender;
        authorityMobile = _mobile;

        users[_mobile] = Person({
            name: _name,
            mobile : _mobile,
            password: _password,
            balance: users[_mobile].balance,
            walletAddress: msg.sender,
            created : true
        });

        userMobile[msg.sender] = Mobile({
            mobile: _mobile
        });
    }

    function createAccount (string memory _name, string memory _mobile,  string memory _password) public {

        require(users[_mobile].created == false,"You already have an account.");
        users[_mobile] = Person({
            name: _name,
            mobile : _mobile,
            password: _password,
            balance: users[_mobile].balance,
            walletAddress: msg.sender,
            created : true
        });

        userMobile[msg.sender] = Mobile({
            mobile: _mobile
        });
    }

    function updateInfo (string memory _name, string memory _mobile,  string memory _password) public {
        require(users[_mobile].created == true,"You have n't any account. Please register.");
        require(users[_mobile].walletAddress == msg.sender, "You have no permission to update info.");
        users[_mobile] = Person({
            name: _name,
            mobile : _mobile,
            password: _password,
            balance: users[_mobile].balance,
            walletAddress: msg.sender,
            created : true
        });

        userMobile[msg.sender] = Mobile({
            mobile: _mobile
        });
    }

    
    function addMoneyToAuthority (uint _amount) public {
        require(msg.sender == authority, "You cannot add tokens to authority account");
        users[authorityMobile].balance += _amount;
        addToTransactionHistory(authorityMobile, authorityMobile, _amount);
    }

    function transfer (string memory _from, string memory _to, uint _amount) internal {
        users[_from].balance -= _amount;
        users[_to].balance += _amount;
        addToTransactionHistory(_from, _to, _amount);
    }

    function addToTransactionHistory(string memory _from, string memory _to, uint _amount) private {
        transactionHistory[users[_from].walletAddress].push(Transaction({
            from: _from,
            to: _to,
            amount: _amount,
            timestamp: block.timestamp
        }));
        transactionHistory[users[_to].walletAddress].push(Transaction({
            from: _from,
            to: _to,
            amount: _amount,
            timestamp: block.timestamp
        }));
    }
    function getTransactionHistory() public view returns (Transaction[] memory) {
        return transactionHistory[msg.sender];
    }

    function setBalanceToUser (string memory _mobile, uint _amount) public {
        require(msg.sender==authority, "Only Authority can give tokens");
        require(users[authorityMobile].balance >= _amount, "You don't have sufficient balance. Pelease add tokens.");
        require(users[_mobile].created == true, "Account not created yet.");
        transfer(authorityMobile, _mobile, _amount);
    }

    function makePayment (string memory _seller, uint _amount) external {
        string memory _mobile = userMobile[msg.sender].mobile;
        require(users[_mobile].balance >= _amount, "You don't have sufficient balance to payment. Please add tokens.");
        require(users[_seller].created == true, "Account not created yet.");
        transfer(_mobile, _seller, _amount);
    }

    function withDraw (uint _amount) external {
        string memory _mobile = userMobile[msg.sender].mobile;
        require(users[_mobile].balance >= _amount, "You don't have sufficient balance to withdraw.");
        require(msg.sender != authority, "Authority can't withdraw.");
        transfer(_mobile, authorityMobile, _amount);
    }

    function getBalance () public view returns (uint) {
        string memory _mobile = userMobile[msg.sender].mobile;
        return users[_mobile].balance;
    }

    function Details () public view returns (string memory, string memory, address) {
        string memory _mobile = userMobile[msg.sender].mobile;
        return (
            users[_mobile].name,
            users[_mobile].mobile,
            users[_mobile].walletAddress

        );
    }
    function authorityDetails () public view returns (string memory, string memory, address) {
         return (
            users[authorityMobile].name,
            users[authorityMobile].mobile,
            users[authorityMobile].walletAddress
        );
    }

    function loginCheck (string memory _password) external view returns (string memory) {
    string memory _mobile = userMobile[msg.sender].mobile;
    string memory _authorityMobile = authorityMobile;

    if (keccak256(bytes(_mobile)) == keccak256(bytes(_authorityMobile))) {
        if (keccak256(bytes(users[_authorityMobile].password)) == keccak256(bytes(_password))) {
            return "authority";
        } else {
            return "notUser";
        }
    } else {
        if (keccak256(bytes(users[_mobile].password)) == keccak256(bytes(_password))) {
            return "user";
        } else {
            return "notUser";
        }
    }
}

}