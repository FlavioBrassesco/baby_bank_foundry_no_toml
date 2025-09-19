// SPDX-License-Identifier: UNKNOWN
pragma solidity ^0.8.0;

/**
 * @title BabyToken
 * @dev A simple ERC20 token implementation to complement the baby_bank contract
 */
contract BabyToken {
    string public name = "BabyToken";
    string public symbol = "BABY";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    // Owner of the contract
    address public owner;
    
    // Balances for each account
    mapping(address => uint256) public balanceOf;
    
    // Allowances for each account
    mapping(address => mapping(address => uint256)) public allowance;
    
    // Events required by the ERC20 standard
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    /**
     * @dev Constructor that gives the msg.sender all of existing tokens
     */
    constructor(uint256 initialSupply) {
        owner = msg.sender;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    /**
     * @dev Transfer tokens to a specified address
     * @param _to The address to transfer to
     * @param _value The amount to be transferred
     * @return success Whether the transfer was successful
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Transfer to zero address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        balanceOf[msg.sender] -= _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender
     * @param _spender The address which will spend the funds
     * @param _value The amount of tokens to be spent
     * @return success Whether the approval was successful
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     * @return success Whether the transfer was successful
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Transfer to zero address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    /**
     * @dev Mint new tokens (only callable by the contract owner)
     * @param _to The address that will receive the minted tokens
     * @param _amount The amount of tokens to mint
     * @return success Whether the minting was successful
     */
    function mint(address _to, uint256 _amount) public returns (bool success) {
        require(msg.sender == owner, "Only owner can mint");
        require(_to != address(0), "Mint to zero address");
        
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
        return true;
    }
    
    /**
     * @dev Burn tokens
     * @param _amount The amount of tokens to burn
     * @return success Whether the burning was successful
     */
    function burn(uint256 _amount) public returns (bool success) {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }
}