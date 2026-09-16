// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import "../contracts/baby_bank.sol";

interface Vm {
    function deal(address who, uint256 newBalance) external;
    function prank(address msgSender) external;
    function roll(uint256 newHeight) external;
}

contract BabyBankFinding2da717ddTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant attacker = address(0x3003);

    function testWithdrawTimeOverflowIsRejected() public {
        baby_bank bank = new baby_bank{value: 1 ether}();

        vm.deal(attacker, 1 ether);
        vm.prank(attacker);
        bank.signup("attacker-secret");

        vm.roll(2000);
        uint256 overflowDelay = uint256(-1) - block.number + 1000 + 1;
        vm.prank(attacker);
        (bool ok, ) = address(bank).call{value: 1 wei}(
            abi.encodeWithSignature("deposit(uint256,address,string)", overflowDelay, attacker, "attacker-secret")
        );

        require(!ok, "overflowed withdraw_time accepted");
        require(bank.balance(attacker) == 0, "attacker balance changed");
    }

    function testMatureWithdrawDoesNotPayGift() public {
        baby_bank bank = new baby_bank{value: 1 ether}();

        vm.deal(attacker, 1 ether);
        vm.prank(attacker);
        bank.signup("attacker-secret");
        vm.prank(attacker);
        bank.deposit{value: 1 wei}(0, attacker, "attacker-secret");

        uint256 winningBlock = _nextWinningBlock(attacker, block.number + 1);
        vm.roll(winningBlock);
        uint256 beforeBalance = attacker.balance;
        vm.prank(attacker);
        bank.withdraw();

        require(attacker.balance == beforeBalance + 1 wei, "gift was paid");
    }

    function _nextWinningBlock(address who, uint256 start) private pure returns (uint256) {
        for (uint256 candidate = start; candidate < start + 1000; candidate++) {
            if (uint256(keccak256(abi.encodePacked(candidate, who))) % 10 == 0) {
                return candidate;
            }
        }
        revert("no winning block found");
    }
}

