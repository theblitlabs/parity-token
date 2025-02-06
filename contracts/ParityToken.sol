// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ParityToken {
    string public constant name = "Parity Token";
    string public constant symbol = "PRTY";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(to != address(0), "Invalid recipient");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(
        address spender,
        uint256 value
    ) public returns (bool success) {
        require(spender != address(0), "Invalid spender");
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool success) {
        require(to != address(0), "Invalid recipient");
        require(value <= balanceOf[from], "Insufficient balance");
        require(value <= allowance[from][msg.sender], "Allowance exceeded");
        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    function mint(address to, uint256 value) public returns (bool success) {
        require(to != address(0), "Invalid recipient");
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
        return true;
    }

    function burn(uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        totalSupply -= value;
        balanceOf[msg.sender] -= value;
        emit Transfer(msg.sender, address(0), value);
        return true;
    }

    function transferWithData(
        address to,
        uint256 value,
        bytes memory
    ) public returns (bool success) {
        require(to != address(0), "Invalid recipient");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferWithDataAndCallback(
        address to,
        uint256 value,
        bytes memory data
    ) public returns (bool success) {
        require(to != address(0), "Invalid recipient");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        _transfer(msg.sender, to, value);
        (bool callSuccess, ) = to.call(data);
        require(callSuccess, "Callback failed");
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }
}
