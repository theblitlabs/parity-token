// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract ParityToken is Ownable {
    string public constant name = "Parity Token";
    string public constant symbol = "PRTY";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply) Ownable(msg.sender) {
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

    function approve(address spender, uint256 value) public returns (bool success) {
        require(spender != address(0), "Invalid spender");
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
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

    function transferWithData(address to, uint256 value, bytes memory) public returns (bool success) {
        require(to != address(0), "Invalid recipient");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        _transfer(msg.sender, to, value);
        return true;
    }

    /// @notice Transfer tokens with additional data and callback
    /// @dev This function performs a callback after the transfer.
    ///      The receiving contract MUST implement a callback function.
    /// @param to The recipient address
    /// @param value The amount of tokens to transfer
    /// @param data The callback data to be passed to the recipient
    /// @return True if transfer and callback succeeded
    function transferWithDataAndCallback(address to, uint256 value, bytes memory data) public returns (bool) {
        require(to != address(0), "Invalid recipient");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        require(to.code.length > 0, "Recipient must be a contract");

        // Update balances before the callback to prevent reentrancy
        _transfer(msg.sender, to, value);

        // Perform the callback
        (bool callSuccess, bytes memory returnData) = to.call(data);
        require(callSuccess, returnData.length > 0 ? _getRevertMsg(returnData) : "Callback failed");

        return true;
    }

    /// @dev Extract revert message from return data
    /// @param returnData The return data from the call
    /// @return The revert message string
    function _getRevertMsg(bytes memory returnData) internal pure returns (string memory) {
        // If the returnData length is less than 68, then the transaction failed silently (without a revert message)
        if (returnData.length < 68) return "Transaction reverted silently";
        // Extract the revert message
        bytes memory revertData = slice(returnData, 4, returnData.length - 4);
        return abi.decode(revertData, (string));
    }

    /// @dev Slice a bytes array
    /// @param data The bytes array to slice
    /// @param start The start index
    /// @param length The length to slice
    /// @return result The sliced bytes array
    function slice(bytes memory data, uint256 start, uint256 length) internal pure returns (bytes memory result) {
        require(start + length <= data.length, "Slice out of bounds");
        result = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            result[i] = data[start + i];
        }
        return result;
    }

    function _transfer(address from, address to, uint256 value) internal {
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }
}