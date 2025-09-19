// SPDX-License-Identifier: UNKNOWN 
pragma solidity ^0.8.0;

import "./baby_bank.sol";

contract BabyBankProxy {
    address public implementation;
    address public admin;
    bool public initialized = false;
    
    // Storage for the proxied contract
    mapping(address => uint256) public balance;
    mapping(address => uint256) public withdraw_time;
    mapping(address => bytes32) public user;
    
    event Upgraded(address indexed implementation);
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    constructor() payable {
        admin = msg.sender;
    }
    
    function initialize(address _implementation) external payable {
        require(!initialized, "Proxy already initialized");
        require(_implementation != address(0), "Implementation cannot be zero address");
        
        implementation = _implementation;
        initialized = true;
        
        emit Upgraded(_implementation);
    }
    
    function upgrade(address _newImplementation) external onlyAdmin {
        require(_newImplementation != address(0), "New implementation cannot be zero address");
        implementation = _newImplementation;
        
        emit Upgraded(_newImplementation);
    }
    
    // Fallback function to delegate calls to the implementation contract
    fallback() external payable {
        require(initialized, "Proxy not initialized");
        
        address _impl = implementation;
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())
            
            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            
            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())
            
            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    
    // Needed to receive ETH
    receive() external payable {}
}