// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract CashLess {

    address  authority;
    uint authorityMobile;
    
    struct Person {
        string name;
        uint mobile;
        string password;
        uint balance;
        address walletAddress;
        bool created;
    }

    struct Mobile{
        uint mobile;
    }

    struct Transaction {
        uint from;
        uint to;
        uint amount;
        uint timestamp;
    }

    mapping (uint => Person)  users;
    mapping  (address => Mobile) userMobile;
    mapping (address => Transaction[]) transactionHistory;

    constructor (string memory _name, uint _mobile, string memory _password) {
        authority = msg.sender;
        authorityMobile = _mobile;
        createAccount(_name, _mobile, _password);
    }

    function createAccount (string memory _name, uint _mobile,  string memory _password) public {

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

    
    function addMoney (uint _amount) public {
        require(msg.sender == authority, "You cannot add tokens to authority account");
        users[authorityMobile].balance += _amount;
        addToTransactionHistory(authorityMobile, authorityMobile, _amount);
    }

    function transfer (uint _from, uint _to, uint _amount) internal {
        users[_from].balance -= _amount;
        users[_to].balance += _amount;
        addToTransactionHistory(_from, _to, _amount);
    }

    function addToTransactionHistory(uint _from, uint _to, uint _amount) private {
        transactionHistory[users[_from].walletAddress].push(Transaction({
            from: _from,
            to: _to,
            amount: _amount,
            timestamp: block.timestamp
        }));
    }
    function getTransactionHistory() public view returns (Transaction[] memory) {
        return transactionHistory[msg.sender];
    }

    function setBalance (uint _mobile, uint _amount) public {
        require(msg.sender==authority, "Only Authority can give tokens");
        require(users[authorityMobile].balance >= _amount, "You don't have sufficient balance. Pelease add tokens.");
        require(users[_mobile].created == true, "Account not created yet.");
        transfer(authorityMobile, _mobile, _amount);
    }

    function makePayment (uint _seller, uint _amount) external {
        uint _mobile = userMobile[msg.sender].mobile;
        require(users[_mobile].balance >= _amount, "You don't have sufficient balance to payment. Please add tokens.");
        require(users[_seller].created == true, "Account not created yet.");
        transfer(_mobile, _seller, _amount);
    }

    function withDraw (uint _amount) external {
        uint _mobile = userMobile[msg.sender].mobile;
        require(users[_mobile].balance >= _amount, "You don't have sufficient balance to withdraw.");
        require(msg.sender != authority, "Authority can't withdraw.");
        transfer(_mobile, authorityMobile, _amount);
    }

    function getBalance () public view returns (uint) {
        uint _mobile = userMobile[msg.sender].mobile;
        return users[_mobile].balance;
    }

    function Details () public view returns (string memory, uint, address) {
        uint _mobile = userMobile[msg.sender].mobile;
        return (
            users[_mobile].name,
            users[_mobile].mobile,
            users[_mobile].walletAddress

        );
    }
    function authorityDetails () public view returns (string memory, uint, address) {
         return (
            users[authorityMobile].name,
            users[authorityMobile].mobile,
            users[authorityMobile].walletAddress
        );
    }

    function loginCheck (string memory _password) external view returns (string memory) {
        uint _mobile = userMobile[msg.sender].mobile;
        if ( (_mobile == authorityMobile) &&
            keccak256(bytes(users[authorityMobile].password)) == keccak256(bytes(_password))
        ) {
            return "athority";
        }
        if (
            keccak256(bytes(users[_mobile].password)) == keccak256(bytes(_password)))
        {
            return "user";
        }
        return "notUser";
    }
}