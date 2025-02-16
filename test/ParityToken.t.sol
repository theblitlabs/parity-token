// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {ParityToken} from "../src/ParityToken.sol";

contract ParityTokenTest is Test {
    ParityToken public token;
    address public owner;
    address public user1;
    address public user2;
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10 ** 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        token = new ParityToken(INITIAL_SUPPLY);

        // Fund users with some ETH for gas
        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
    }

    function test_InitialState() public view {
        assertEq(token.name(), "Parity Token");
        assertEq(token.symbol(), "PRTY");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function test_Transfer() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.expectEmit(true, true, false, true);
        emit Transfer(owner, user1, amount);

        bool success = token.transfer(user1, amount);
        assertTrue(success);
        assertEq(token.balanceOf(user1), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
    }

    function test_TransferFail_InsufficientBalance() public {
        uint256 amount = INITIAL_SUPPLY + 1;
        vm.expectRevert("Insufficient balance");
        token.transfer(user1, amount);
    }

    function test_Approve() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.expectEmit(true, true, false, true);
        emit Approval(owner, user1, amount);

        bool success = token.approve(user1, amount);
        assertTrue(success);
        assertEq(token.allowance(owner, user1), amount);
    }

    function test_TransferFrom() public {
        uint256 amount = 1000 * 10 ** 18;
        token.approve(user1, amount);

        vm.prank(user1);
        bool success = token.transferFrom(owner, user2, amount);

        assertTrue(success);
        assertEq(token.balanceOf(user2), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
        assertEq(token.allowance(owner, user1), 0);
    }

    function test_TransferFrom_Fail_InsufficientAllowance() public {
        uint256 amount = 1000 * 10 ** 18;
        token.approve(user1, amount - 1);

        vm.prank(user1);
        vm.expectRevert("Allowance exceeded");
        token.transferFrom(owner, user2, amount);
    }

    function test_Mint() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), user1, amount);

        bool success = token.mint(user1, amount);
        assertTrue(success);
        assertEq(token.balanceOf(user1), amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + amount);
    }

    function test_Burn() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.expectEmit(true, true, false, true);
        emit Transfer(owner, address(0), amount);

        bool success = token.burn(amount);
        assertTrue(success);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - amount);
    }

    function test_TransferWithData() public {
        uint256 amount = 1000 * 10 ** 18;
        bytes memory data = "0x";

        bool success = token.transferWithData(user1, amount, data);
        assertTrue(success);
        assertEq(token.balanceOf(user1), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
    }

    function test_TransferWithDataAndCallback() public {
        // Deploy a mock contract that accepts callbacks
        MockCallback mockReceiver = new MockCallback();
        uint256 amount = 1000 * 10 ** 18;
        bytes memory data = abi.encodeWithSignature("onTokenReceived(address,uint256)", owner, amount);

        bool success = token.transferWithDataAndCallback(address(mockReceiver), amount, data);
        assertTrue(success);
        assertEq(token.balanceOf(address(mockReceiver)), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
        assertTrue(mockReceiver.callbackReceived());
    }

    function testFuzz_Transfer(uint256 amount) public {
        // Bound the amount to be within the total supply
        amount = bound(amount, 0, INITIAL_SUPPLY);

        bool success = token.transfer(user1, amount);
        assertTrue(success);
        assertEq(token.balanceOf(user1), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
    }
}

// Mock contract for testing callbacks
contract MockCallback {
    bool public callbackReceived;

    function onTokenReceived(address, /* from */ uint256 /* amount */ ) external {
        callbackReceived = true;
    }
}
