// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import "../contracts/baby_bank.sol";

interface Vm {
    function deal(address who, uint256 newBalance) external;
    function prank(address msgSender) external;
}

contract BabyBankFinding1322Test {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant victim = address(0x2002);
    address private constant attacker = address(0x3003);

    function testThirdPartyCannotOverwriteVictimBalance() public {
        baby_bank bank = new baby_bank();

        vm.deal(victim, 10 ether);
        vm.prank(victim);
        bank.signup("victim-secret");
        vm.prank(victim);
        bank.deposit{value: 5 ether}(100, victim, "victim-secret");

        vm.prank(attacker);
        bank.signup("attacker-secret");
        vm.prank(attacker);
        (bool ok, ) = address(bank).call(
            abi.encodeWithSignature("deposit(uint256,address,string)", 0, victim, "victim-secret")
        );

        require(!ok, "third party overwrite succeeded");
        require(bank.balance(victim) == 5 ether, "victim balance changed");
    }
}

