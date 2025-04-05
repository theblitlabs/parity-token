// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {ParityToken} from "../src/ParityToken.sol";
import {ParityTokenProxy} from "../src/ParityTokenProxy.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract DeployUpgradeable is Script {
    using stdJson for string;

    error InvalidPrivateKey();
    error EnvironmentError(string message);

    // Initial supply of 100 million tokens with 18 decimals
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10 ** 18;

    // Default Anvil private key (for testing only)
    uint256 constant ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    function run() external {
        console2.log("\n=== Parity Token Deployment ===");

        // Check if we're in CI environment
        bool isCI = _isCI();

        // Get and validate private key
        uint256 deployerPrivateKey = _getPrivateKey();
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("\n=== Deployment Information ===");
        console2.log("Deployer:", deployer);
        console2.log("Initial Supply:", INITIAL_SUPPLY);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation
        ParityToken implementation = new ParityToken();
        console2.log("\nImplementation deployed to:", address(implementation));

        // Prepare initialization data
        bytes memory initData = abi.encodeWithSelector(ParityToken.initialize.selector, INITIAL_SUPPLY);

        // Deploy proxy with implementation and initialization
        ParityTokenProxy proxy = new ParityTokenProxy(address(implementation), initData);

        vm.stopBroadcast();

        console2.log("\n=== Deployment Successful! ===");
        console2.log("Implementation deployed to:", address(implementation));
        console2.log("Proxy deployed to:", address(proxy));

        // Save addresses to .env if not in CI
        if (!isCI) {
            _saveAddresses(address(proxy), address(implementation));
        }

        // Deployment verification instructions
        string memory etherscanKey = vm.envOr("ETHERSCAN_API_KEY", string(""));
        if (block.chainid == 11155111 || block.chainid == 1) {
            console2.log("\n=== Next Steps ===");
            console2.log("1. Addresses saved to .env");
            console2.log("2. To verify on Etherscan, run:");

            if (bytes(etherscanKey).length > 0) {
                console2.log(
                    string.concat(
                        "   forge verify-contract ",
                        vm.toString(address(implementation)),
                        " ParityToken --chain ",
                        vm.toString(block.chainid),
                        " --api-key ",
                        etherscanKey
                    )
                );
                console2.log(
                    string.concat(
                        "   forge verify-contract ",
                        vm.toString(address(proxy)),
                        " ParityTokenProxy --chain ",
                        vm.toString(block.chainid),
                        " --api-key ",
                        etherscanKey
                    )
                );
            } else {
                console2.log(
                    string.concat(
                        "   forge verify-contract ",
                        vm.toString(address(implementation)),
                        " ParityToken --chain ",
                        vm.toString(block.chainid)
                    )
                );
                console2.log(
                    string.concat(
                        "   forge verify-contract ",
                        vm.toString(address(proxy)),
                        " ParityTokenProxy --chain ",
                        vm.toString(block.chainid)
                    )
                );
            }
        }
    }

    function _isCI() internal view returns (bool) {
        try vm.envBool("CI") returns (bool ci) {
            return ci;
        } catch {
            return false;
        }
    }

    function _getPrivateKey() internal view returns (uint256) {
        bool isCI = _isCI();

        try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
            if (key == 0) revert InvalidPrivateKey();
            return key;
        } catch {
            // Use default key for local testing or CI
            if (block.chainid == 31337 || isCI) {
                return ANVIL_PRIVATE_KEY;
            }
            revert InvalidPrivateKey();
        }
    }

    function _saveAddresses(address proxy, address implementation) internal {
        string[] memory proxyCmd = new string[](4);
        proxyCmd[0] = "bash";
        proxyCmd[1] = "-c";
        proxyCmd[2] = string.concat("sed -i '' 's/^PROXY_ADDRESS=.*$/PROXY_ADDRESS=", vm.toString(proxy), "/' .env");

        string[] memory tokenCmd = new string[](4);
        tokenCmd[0] = "bash";
        tokenCmd[1] = "-c";
        tokenCmd[2] = string.concat("sed -i '' 's/^TOKEN_ADDRESS=.*$/TOKEN_ADDRESS=", vm.toString(proxy), "/' .env");

        string[] memory implCmd = new string[](4);
        implCmd[0] = "bash";
        implCmd[1] = "-c";
        implCmd[2] = string.concat(
            "sed -i '' 's/^IMPLEMENTATION_ADDRESS=.*$/IMPLEMENTATION_ADDRESS=", vm.toString(implementation), "/' .env"
        );

        try vm.ffi(proxyCmd) {
            try vm.ffi(tokenCmd) {
                try vm.ffi(implCmd) {
                    console2.log("All addresses saved to .env");
                } catch {
                    console2.log("Warning: Could not save implementation address to .env");
                }
            } catch {
                console2.log("Warning: Could not save token address to .env");
            }
        } catch {
            console2.log("Warning: Could not save proxy address to .env");
        }
    }
}
