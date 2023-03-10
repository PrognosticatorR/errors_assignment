// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract BankAccount {
    uint public balance;
    uint public constant MAX_UINT = 2 ** 256 - 1;
    error BalanceUnderFlow();

    address public accountHolder;

    constructor() {
        accountHolder = msg.sender;
    }

    function depositToAccount(uint _amount) public {
        uint prevBalance = balance;
        uint newBalance = balance + _amount;
        require(newBalance >= prevBalance, "Overflow");
        balance = newBalance;
        assert(balance >= prevBalance);
    }

    function withdrawFromAccount(uint _amount) public {
        uint prevBalance = balance;
        require(balance >= _amount, "Balance Underflow");
        if (balance < _amount) {
            revert BalanceUnderFlow();
        }
        balance -= _amount;
        assert(balance <= prevBalance);
    }

    function closeAccountPermanently() external returns (bool success) {
        require(msg.sender == accountHolder, "Only holder can take this action");
        balance = 0;
        assert(balance == 0);
        accountHolder = address(0);
        return true;
    }
}
