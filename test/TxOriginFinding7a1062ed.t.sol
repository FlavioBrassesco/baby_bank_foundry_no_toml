// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.0;

import "../contracts/tx_origin.sol";

interface Vm {
    function prank(address msgSender, address txOrigin) external;
}

contract ForceSender {
    constructor() public payable {}

    function destroy(address payable target) external {
        selfdestruct(target);
    }
}

contract TxOriginFinding7a1062edTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address payable private owner = address(uint160(0x1001));
    address payable private attacker = address(uint160(0x3003));

    function testArbitraryCallerCannotDrainForcedBalance() public {
        vm.prank(owner, owner);
        TxOrigin target = new TxOrigin();
        ForceSender forceSender = (new ForceSender).value(1 ether)();
        forceSender.destroy(address(uint160(address(target))));

        uint256 beforeBalance = attacker.balance;
        vm.prank(attacker, attacker);
        (bool ok, ) = address(target).call(abi.encodeWithSignature("legit1()"));

        require(!ok, "attacker drain succeeded");
        require(attacker.balance == beforeBalance, "attacker received funds");
        require(address(target).balance == 1 ether, "target balance changed");
    }

    function testOwnerReceivesForcedBalance() public {
        vm.prank(owner, owner);
        TxOrigin target = new TxOrigin();
        ForceSender forceSender = (new ForceSender).value(1 ether)();
        forceSender.destroy(address(uint160(address(target))));

        uint256 beforeBalance = owner.balance;
        vm.prank(owner, owner);
        target.legit1();

        require(owner.balance == beforeBalance + 1 ether, "owner did not receive balance");
        require(address(target).balance == 0, "target balance was not drained");
    }
}

