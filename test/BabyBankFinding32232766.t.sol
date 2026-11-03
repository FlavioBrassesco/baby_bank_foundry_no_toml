// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import "../contracts/baby_bank.sol";

interface Vm {
    function deal(address who, uint256 newBalance) external;
    function prank(address msgSender) external;
}

contract HeavyRecipient {
    baby_bank private bank;
    address payable private payout;
    uint256 private stored;

    constructor(baby_bank _bank, address payable _payout) {
        bank = _bank;
        payout = _payout;
    }

    function signup(string calldata name) external {
        bank.signup(name);
    }

    function withdraw() external {
        bank.withdraw();
    }

    function withdrawToPayout() external {
        bank.withdrawTo(payout);
    }

    receive() external payable {
        stored = stored + msg.value;
    }
}

contract BabyBankFinding32232766Test {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant depositor = address(0x1001);
    address payable private recipientOwner = address(uint160(0x2002));

    function testContractRecipientCanWithdrawWithCall() public {
        baby_bank bank = new baby_bank();
        HeavyRecipient recipient = new HeavyRecipient(bank, recipientOwner);

        recipient.signup("recipient-secret");
        vm.deal(depositor, 10 ether);
        vm.prank(depositor);
        bank.signup("depositor-secret");
        vm.prank(depositor);
        bank.deposit{value: 1 ether}(0, address(recipient), "recipient-secret");

        recipient.withdraw();

        require(bank.balance(address(recipient)) == 0, "balance was not cleared");
        require(address(recipient).balance == 1 ether, "recipient did not receive funds");
    }

    function testRecipientCanWithdrawToAlternateAddress() public {
        baby_bank bank = new baby_bank();
        HeavyRecipient recipient = new HeavyRecipient(bank, recipientOwner);

        recipient.signup("recipient-secret");
        vm.deal(depositor, 10 ether);
        vm.prank(depositor);
        bank.signup("depositor-secret");
        vm.prank(depositor);
        bank.deposit{value: 1 ether}(0, address(recipient), "recipient-secret");

        uint256 beforeBalance = recipientOwner.balance;
        recipient.withdrawToPayout();

        require(bank.balance(address(recipient)) == 0, "balance was not cleared");
        require(recipientOwner.balance == beforeBalance + 1 ether, "alternate recipient was not paid");
    }
}

