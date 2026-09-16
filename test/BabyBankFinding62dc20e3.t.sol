// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import "../contracts/baby_bank.sol";

interface Vm {
    function deal(address who, uint256 newBalance) external;
    function prank(address msgSender) external;
    function roll(uint256 newHeight) external;
}

contract BabyBankFinding62dc20e3Test {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant depositor = address(0x1001);
    address private constant beneficiary = address(0x2002);

    function testPrincipalCannotBeWithdrawnBeforeWithdrawTime() public {
        baby_bank bank = new baby_bank();

        vm.deal(depositor, 10 ether);
        vm.prank(depositor);
        bank.signup("depositor-secret");
        vm.prank(beneficiary);
        bank.signup("beneficiary-secret");

        vm.roll(10);
        vm.prank(depositor);
        bank.deposit{value: 1 ether}(10, beneficiary, "beneficiary-secret");

        vm.roll(11);
        vm.prank(beneficiary);
        (bool ok, ) = address(bank).call(abi.encodeWithSignature("withdraw()"));

        require(!ok, "early withdrawal succeeded");
        require(bank.balance(beneficiary) == 1 ether, "balance changed");
    }

    function testPrincipalCanBeWithdrawnAfterWithdrawTime() public {
        baby_bank bank = new baby_bank();

        vm.deal(depositor, 10 ether);
        vm.prank(depositor);
        bank.signup("depositor-secret");
        vm.prank(beneficiary);
        bank.signup("beneficiary-secret");

        vm.roll(10);
        vm.prank(depositor);
        bank.deposit{value: 1 ether}(1, beneficiary, "beneficiary-secret");

        vm.roll(12);
        uint256 beforeBalance = beneficiary.balance;
        vm.prank(beneficiary);
        bank.withdraw();

        require(beneficiary.balance >= beforeBalance + 1 ether, "principal was not paid");
        require(bank.balance(beneficiary) == 0, "balance was not cleared");
    }
}

