// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console2} from "forge-std/Script.sol";
import {ParityToken} from "../src/ParityToken.sol";

contract TransferScript is Script {
    function run() public {
        // Get token address from environment
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        // Get recipient address from command line argument
        address recipient = vm.envAddress("RECIPIENT");
        // Get amount from command line argument (in whole tokens)
        uint256 amount = vm.envUint("AMOUNT");
        // Convert to wei (18 decimals)
        uint256 amountInWei = amount * 10 ** 18;

        // Get deployer's private key
        uint256 deployerPrivateKey;
        try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
            deployerPrivateKey = key;
        } catch {
            // Default to first Anvil private key if no environment variable is set
            deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        }

        vm.startBroadcast(deployerPrivateKey);

        ParityToken token = ParityToken(tokenAddress);

        // Get initial balances
        uint256 initialSenderBalance = token.balanceOf(vm.addr(deployerPrivateKey));
        uint256 initialRecipientBalance = token.balanceOf(recipient);

        console2.log("Transferring tokens:");
        console2.log("Token address:", tokenAddress);
        console2.log("From:", vm.addr(deployerPrivateKey));
        console2.log("To:", recipient);
        console2.log("Amount:", amount, "PRTY");
        console2.log("Initial sender balance:", initialSenderBalance / 10 ** 18, "PRTY");
        console2.log("Initial recipient balance:", initialRecipientBalance / 10 ** 18, "PRTY");

        require(token.transfer(recipient, amountInWei), "Transfer failed");

        // Get final balances
        uint256 finalSenderBalance = token.balanceOf(vm.addr(deployerPrivateKey));
        uint256 finalRecipientBalance = token.balanceOf(recipient);

        console2.log("Transfer successful!");
        console2.log("Final sender balance:", finalSenderBalance / 10 ** 18, "PRTY");
        console2.log("Final recipient balance:", finalRecipientBalance / 10 ** 18, "PRTY");

        vm.stopBroadcast();
    }
}
