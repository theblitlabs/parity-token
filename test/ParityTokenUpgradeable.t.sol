// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {ParityToken} from "../src/ParityToken.sol";
import {ParityTokenProxy} from "../src/ParityTokenProxy.sol";
import {UUPSUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

contract ParityTokenUpgradeableTest is Test {
    ParityToken public implementation;
    ParityTokenProxy public proxy;
    ParityToken public token;
    address public owner;
    address public user1;
    address public user2;
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10 ** 18;

    event Upgraded(address indexed implementation);

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Deploy implementation
        implementation = new ParityToken();

        // Prepare initialization data
        bytes memory initData = abi.encodeWithSelector(ParityToken.initialize.selector, INITIAL_SUPPLY);

        // Deploy proxy
        proxy = new ParityTokenProxy(address(implementation), initData);

        // Setup token interface
        token = ParityToken(address(proxy));

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

    function test_UpgradeToNewImplementation() public {
        // Deploy new implementation
        ParityToken newImplementation = new ParityToken();

        // Get the proxy admin address
        address proxyAdmin = address(this);

        // Expect Upgraded event
        vm.expectEmit(true, false, false, false);
        emit Upgraded(address(newImplementation));

        // Upgrade through the proxy
        vm.prank(proxyAdmin);
        token.upgradeToAndCall(address(newImplementation), "");

        // Verify state is maintained
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function test_UpgradeAndMaintainState() public {
        // Initial transfer to test state persistence
        uint256 transferAmount = 1000 * 10 ** 18;
        token.transfer(user1, transferAmount);

        // Deploy new implementation
        ParityToken newImplementation = new ParityToken();

        // Upgrade
        UUPSUpgradeable(address(proxy)).upgradeToAndCall(address(newImplementation), "");

        // Verify state is maintained
        assertEq(token.balanceOf(user1), transferAmount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - transferAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function test_RevertUnauthorizedUpgrade() public {
        ParityToken newImplementation = new ParityToken();

        // Try to upgrade from unauthorized account
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, user1));
        UUPSUpgradeable(address(proxy)).upgradeToAndCall(address(newImplementation), "");
    }

    function test_RevertInvalidImplementation() public {
        // Try to upgrade to an invalid implementation (zero address)
        vm.expectRevert();
        UUPSUpgradeable(address(proxy)).upgradeToAndCall(address(0), "");
    }
}
