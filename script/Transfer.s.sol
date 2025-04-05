// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {ParityToken} from "../src/ParityToken.sol";

contract TransferScript is Script {
    error InsufficientFunds(uint256 required, uint256 available);
    error InsufficientTokenBalance(uint256 required, uint256 available);
    error InvalidPrivateKey();
    error InvalidAddress();
    error InvalidAmount();
    error TransferFailed();
    error SelfTransfer();

    function run() public {
        console2.log("\n=== Parity Token Transfer ===");

        // Check if we're in CI environment
        bool isCI;
        try vm.envBool("CI") returns (bool ci) {
            isCI = ci;
        } catch {
            isCI = false;
        }

        // Get and validate private key
        uint256 deployerPrivateKey = _getPrivateKey();
        address sender = vm.addr(deployerPrivateKey);

        // Get and validate token address
        address tokenAddress = _getTokenAddress();
        ParityToken token = ParityToken(tokenAddress);

        // Get and validate recipient address
        address recipient = _getRecipientAddress();
        if (recipient == address(0)) revert InvalidAddress();

        // Prevent sending to self
        if (recipient == sender) {
            console2.log("\n!!! ERROR: Cannot send tokens to yourself !!!");
            console2.log("Sender address:", sender);
            console2.log("Recipient address:", recipient);
            revert SelfTransfer();
        }

        // Get and validate amount
        uint256 amount = _getAmount();
        if (amount == 0) revert InvalidAmount();
        uint256 amountInWei = amount * 10 ** 18;

        // Get network info
        uint256 chainId = block.chainid;
        string memory network = _getNetworkName(chainId);

        console2.log("\n=== Network Information ===");
        console2.log("Network:", network);
        console2.log("Chain ID:", chainId);

        // Check balances
        uint256 senderEthBalance = sender.balance;
        uint256 senderTokenBalance = token.balanceOf(sender);
        uint256 recipientTokenBalance = token.balanceOf(recipient);

        console2.log("\n=== Pre-Transfer Balances ===");
        console2.log("Sender ETH balance:", senderEthBalance / 1e18, "ETH");
        console2.log(
            "Sender token balance:",
            senderTokenBalance / 1e18,
            "PRTY"
        );
        console2.log(
            "Recipient token balance:",
            recipientTokenBalance / 1e18,
            "PRTY"
        );

        // Skip balance checks in CI
        if (!isCI) {
            // Validate token balance
            if (senderTokenBalance < amountInWei) {
                console2.log("\n!!! INSUFFICIENT TOKEN BALANCE !!!");
                console2.log("Required:", amount, "PRTY");
                console2.log("Available:", senderTokenBalance / 1e18, "PRTY");
                revert InsufficientTokenBalance(
                    amountInWei,
                    senderTokenBalance
                );
            }

            // Estimate gas costs
            uint256 gasPrice = _getGasPrice();
            uint256 gasLimit = 100000; // Conservative estimate for ERC20 transfer
            uint256 estimatedGasCost = gasPrice * gasLimit;

            console2.log("\n=== Cost Estimation ===");
            console2.log("Gas price:", gasPrice / 1e9, "gwei");
            console2.log("Estimated gas:", gasLimit);
            console2.log("Estimated cost:", estimatedGasCost / 1e18, "ETH");

            // Validate ETH balance
            if (senderEthBalance < estimatedGasCost) {
                console2.log("\n!!! INSUFFICIENT ETH FOR GAS !!!");
                console2.log("Required:", estimatedGasCost / 1e18, "ETH");
                console2.log("Available:", senderEthBalance / 1e18, "ETH");
                console2.log(
                    "Shortfall:",
                    (estimatedGasCost - senderEthBalance) / 1e18,
                    "ETH"
                );

                if (chainId == 11155111) {
                    console2.log(
                        "\nTo get Sepolia ETH, use one of these faucets:"
                    );
                    console2.log("- Alchemy: https://sepoliafaucet.com/");
                    console2.log(
                        "- Infura: https://www.infura.io/faucet/sepolia"
                    );
                    console2.log("- PoW: https://sepolia-faucet.pk910.de/");
                }

                revert InsufficientFunds(estimatedGasCost, senderEthBalance);
            }
        }

        // Execute transfer
        console2.log("\n=== Executing Transfer ===");
        console2.log("From:", sender);
        console2.log("To:", recipient);
        console2.log("Amount:", amount, "PRTY");

        vm.startBroadcast(deployerPrivateKey);

        bool success = token.transfer(recipient, amountInWei);
        if (!success) revert TransferFailed();

        vm.stopBroadcast();

        // Get final balances
        uint256 finalSenderBalance = token.balanceOf(sender);
        uint256 finalRecipientBalance = token.balanceOf(recipient);

        console2.log("\n=== Transfer Successful! ===");
        console2.log("New sender balance:", finalSenderBalance / 1e18, "PRTY");
        console2.log(
            "New recipient balance:",
            finalRecipientBalance / 1e18,
            "PRTY"
        );
        console2.log(
            "Transaction cost:",
            (senderEthBalance - sender.balance) / 1e18,
            "ETH"
        );
    }

    function _getPrivateKey() internal view returns (uint256) {
        // Check if we're in CI environment
        bool isCI;
        try vm.envBool("CI") returns (bool ci) {
            isCI = ci;
        } catch {
            isCI = false;
        }

        try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
            if (key == 0) revert InvalidPrivateKey();
            return key;
        } catch {
            // Use default key for local testing or CI
            if (block.chainid == 31337 || isCI) {
                return
                    0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
            }
            revert InvalidPrivateKey();
        }
    }

    function _getTokenAddress() internal view returns (address) {
        try vm.envAddress("TOKEN_ADDRESS") returns (address addr) {
            if (addr == address(0)) revert InvalidAddress();
            return addr;
        } catch {
            revert InvalidAddress();
        }
    }

    function _getRecipientAddress() internal view returns (address) {
        try vm.envString("ADDRESS") returns (string memory addrStr) {
            // If address doesn't start with 0x, add it
            if (
                bytes(addrStr).length >= 2 &&
                !(bytes(addrStr)[0] == "0" && bytes(addrStr)[1] == "x")
            ) {
                addrStr = string.concat("0x", addrStr);
            }
            return vm.parseAddress(addrStr);
        } catch {
            revert InvalidAddress();
        }
    }

    function _getAmount() internal view returns (uint256) {
        try vm.envUint("AMOUNT") returns (uint256 amount) {
            return amount;
        } catch {
            revert InvalidAmount();
        }
    }

    function _getGasPrice() internal view returns (uint256) {
        // Use higher gas price estimation for safety
        return (block.basefee * 12) / 10; // 120% of base fee
    }

    function _getNetworkName(
        uint256 chainId
    ) internal pure returns (string memory) {
        if (chainId == 11155111) {
            return "Sepolia";
        } else if (chainId == 1) {
            return "Mainnet";
        } else {
            return "Local/Custom";
        }
    }
}
