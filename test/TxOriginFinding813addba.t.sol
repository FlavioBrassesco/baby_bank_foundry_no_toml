// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.0;

import "../contracts/tx_origin.sol";

interface Vm {
    function prank(address msgSender, address txOrigin) external;
}

contract Forwarder {
    function callLegit0(TxOrigin target) external returns (bool) {
        (bool ok, ) = address(target).call(abi.encodeWithSignature("legit0()"));
        return ok;
    }
}

contract TxOriginFinding813addbaTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private user = address(0x4004);

    function testLegit0AllowsContractRoutedCaller() public {
        TxOrigin target = new TxOrigin();
        Forwarder forwarder = new Forwarder();

        vm.prank(user, user);
        bool ok = forwarder.callLegit0(target);

        require(ok, "contract-routed call failed");
    }
}

