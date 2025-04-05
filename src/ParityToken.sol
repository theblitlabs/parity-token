// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {Initializable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";

contract ParityToken is Initializable, UUPSUpgradeable, OwnableUpgradeable {
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

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(uint256 initialSupply) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();

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

    function mint(
        address to,
        uint256 value
    ) public onlyOwner returns (bool success) {
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
    ) public returns (bool) {
        require(to != address(0), "Invalid recipient");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        require(to.code.length > 0, "Recipient must be a contract");

        // Update balances before the callback to prevent reentrancy
        _transfer(msg.sender, to, value);

        // Perform the callback
        (bool callSuccess, bytes memory returnData) = to.call(data);
        require(
            callSuccess,
            returnData.length > 0
                ? _getRevertMsg(returnData)
                : "Callback failed"
        );

        return true;
    }

    function _getRevertMsg(
        bytes memory returnData
    ) internal pure returns (string memory) {
        if (returnData.length < 68) return "Transaction reverted silently";
        bytes memory revertData = slice(returnData, 4, returnData.length - 4);
        return abi.decode(revertData, (string));
    }

    function slice(
        bytes memory data,
        uint256 start,
        uint256 length
    ) internal pure returns (bytes memory result) {
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

    /// @dev Required override for UUPS proxy pattern
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
