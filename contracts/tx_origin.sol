pragma solidity ^0.5.0;

contract TxOrigin {
    address payable owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function bug0() public {
        require(tx.origin == owner);
    }

    function bug2() public {
        if (tx.origin != owner) {
            revert();
        }
    }

    function legit0() public {
        require(tx.origin == msg.sender);
    }

    function legit1() public onlyOwner {
        owner.transfer(address(this).balance);
    }
}

// added a comment to trigger a new build
