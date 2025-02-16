// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {ParityToken} from "../src/ParityToken.sol";

contract DeployScript is Script {
    // Initial supply of 100 million tokens with 18 decimals
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10 ** 18;

    function run() public {
        uint256 deployerPrivateKey;
        try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
            deployerPrivateKey = key;
        } catch {
            // Default to first Anvil private key if no environment variable is set
            deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        }

        vm.startBroadcast(deployerPrivateKey);

        ParityToken token = new ParityToken(INITIAL_SUPPLY);

        console2.log("ParityToken deployed to:", address(token));
        console2.log("Initial supply:", INITIAL_SUPPLY);

        vm.stopBroadcast();
    }
}
