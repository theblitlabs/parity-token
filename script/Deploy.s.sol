// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {ParityToken} from "../src/ParityToken.sol";

contract DeployScript is Script {
    // Initial supply of 100 million tokens with 18 decimals
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10 ** 18;

    error InsufficientFunds(uint256 required, uint256 available);
    error InvalidPrivateKey();
    error EnvironmentError(string message);

    function run() public {
        console2.log("\n=== Parity Token Deployment ===");

        // Check if we're in CI environment
        bool isCI = _isCI();

        // Get and validate private key
        uint256 deployerPrivateKey = _getPrivateKey();
        address deployer = vm.addr(deployerPrivateKey);

        // Get network info
        (uint256 chainId, string memory network) = _getNetworkInfo();

        console2.log("\n=== Network Information ===");
        console2.log("Network:", network);
        console2.log("Chain ID:", chainId);
        console2.log("Block number:", block.number);

        // Get deployer info
        uint256 deployerBalance = deployer.balance;
        console2.log("\n=== Deployer Information ===");
        console2.log("Deployer address:", deployer);
        console2.log("Deployer balance:", deployerBalance / 1e18, "ETH");

        // Estimate deployment costs
        uint256 gasPrice = _getGasPrice();
        uint256 gasLimit = 3000000; // Conservative estimate
        uint256 estimatedGasCost = gasPrice * gasLimit;

        console2.log("\n=== Cost Estimation ===");
        console2.log("Gas price:", gasPrice / 1e9, "gwei");
        console2.log("Estimated gas limit:", gasLimit);
        console2.log("Estimated cost:", estimatedGasCost / 1e18, "ETH");

        // Skip balance check in CI
        if (!isCI && deployerBalance < estimatedGasCost) {
            console2.log("\n!!! INSUFFICIENT FUNDS !!!");
            console2.log("Required:", estimatedGasCost / 1e18, "ETH");
            console2.log("Available:", deployerBalance / 1e18, "ETH");
            console2.log("Shortfall:", (estimatedGasCost - deployerBalance) / 1e18, "ETH");

            if (chainId == 11155111) {
                console2.log("\nTo get Sepolia ETH, use one of these faucets:");
                console2.log("- Alchemy: https://sepoliafaucet.com/");
                console2.log("- Infura: https://www.infura.io/faucet/sepolia");
                console2.log("- PoW: https://sepolia-faucet.pk910.de/");
            }

            revert InsufficientFunds(estimatedGasCost, deployerBalance);
        }

        // Deploy token
        console2.log("\n=== Deploying Token ===");
        console2.log("Initial supply:", INITIAL_SUPPLY / 1e18, "PRTY");

        vm.startBroadcast(deployerPrivateKey);

        ParityToken token = new ParityToken(INITIAL_SUPPLY);

        vm.stopBroadcast();

        // Save token address to .env if not in CI
        if (!isCI) {
            _saveTokenAddress(address(token));
        }

        console2.log("\n=== Deployment Successful! ===");
        console2.log("Token address:", address(token));
        console2.log("Owner:", deployer);

        // Deployment verification instructions
        if (chainId == 11155111 || chainId == 1) {
            string memory etherscanKey = vm.envOr("ETHERSCAN_API_KEY", string(""));
            console2.log("\n=== Next Steps ===");
            console2.log("1. Token address saved to .env");
            console2.log("2. To verify on Etherscan, run:");

            if (bytes(etherscanKey).length > 0) {
                console2.log(
                    string.concat(
                        "   forge verify-contract ",
                        vm.toString(address(token)),
                        " ParityToken --chain ",
                        vm.toString(chainId),
                        " --api-key ",
                        etherscanKey
                    )
                );
            } else {
                console2.log(
                    string.concat(
                        "   forge verify-contract ",
                        vm.toString(address(token)),
                        " ParityToken --chain ",
                        vm.toString(chainId)
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
                return 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
            }
            revert InvalidPrivateKey();
        }
    }

    function _getNetworkInfo() internal view returns (uint256 chainId, string memory network) {
        try vm.envUint("CHAIN_ID") returns (uint256 id) {
            chainId = id;
        } catch {
            chainId = block.chainid;
        }

        if (chainId == 11155111) {
            network = "Sepolia";
        } else if (chainId == 1) {
            network = "Mainnet";
        } else {
            network = "Local/Custom";
        }
    }

    function _getGasPrice() internal view returns (uint256) {
        // Use higher gas price estimation for safety
        return (block.basefee * 12) / 10; // 120% of base fee
    }

    function _saveTokenAddress(address token) internal {
        string[] memory inputs = new string[](4);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = string.concat("sed -i '' 's/^TOKEN_ADDRESS=.*$/TOKEN_ADDRESS=", vm.toString(token), "/' .env");

        try vm.ffi(inputs) {
            console2.log("Token address saved to .env");
        } catch {
            console2.log("Warning: Could not save token address to .env");
        }
    }
}
