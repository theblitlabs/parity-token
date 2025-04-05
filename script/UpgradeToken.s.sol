// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {ParityToken} from "../src/ParityToken.sol";
import {UUPSUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";

contract UpgradeToken is Script {
    function run() external {
        // Load environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        address newImplementationAddress = vm.envAddress(
            "IMPLEMENTATION_ADDRESS"
        );

        vm.startBroadcast(deployerPrivateKey);

        // Cast proxy to UUPSUpgradeable to call upgradeTo
        UUPSUpgradeable proxy = UUPSUpgradeable(proxyAddress);

        // Upgrade to new implementation
        proxy.upgradeTo(newImplementationAddress);

        vm.stopBroadcast();

        // Update .env file with new implementation address
        string memory path = ".env";
        string memory envContents = vm.readFile(path);

        // Replace or add IMPLEMENTATION_ADDRESS
        vm.writeFile(
            path,
            _replaceOrAddEnvVar(
                envContents,
                "IMPLEMENTATION_ADDRESS",
                vm.toString(newImplementationAddress)
            )
        );

        console2.log(
            "Proxy upgraded to new implementation at:",
            newImplementationAddress
        );
        console2.log(
            "Environment file updated with new implementation address"
        );
    }

    function _replaceOrAddEnvVar(
        string memory envContents,
        string memory key,
        string memory value
    ) internal pure returns (string memory) {
        bytes memory keyBytes = bytes(key);
        bytes memory envBytes = bytes(envContents);

        // Try to find the key in the current contents
        uint256 keyIndex = _indexOf(envBytes, keyBytes);

        if (keyIndex == type(uint256).max) {
            // Key not found, append new line
            return string.concat(envContents, key, "=", value, "\n");
        } else {
            // Key found, replace the value
            uint256 valueStart = keyIndex + keyBytes.length + 1; // +1 for '='
            uint256 lineEnd = _indexOf(envBytes[valueStart:], "\n");
            if (lineEnd == type(uint256).max) {
                lineEnd = envBytes.length - valueStart;
            }

            return
                string.concat(
                    string(envBytes[:valueStart]),
                    value,
                    string(envBytes[valueStart + lineEnd:])
                );
        }
    }

    function _indexOf(
        bytes memory data,
        bytes memory pattern
    ) internal pure returns (uint256) {
        if (pattern.length == 0) return 0;
        if (data.length < pattern.length) return type(uint256).max;

        for (uint256 i = 0; i <= data.length - pattern.length; i++) {
            bool found = true;
            for (uint256 j = 0; j < pattern.length; j++) {
                if (data[i + j] != pattern[j]) {
                    found = false;
                    break;
                }
            }
            if (found) return i;
        }
        return type(uint256).max;
    }
}
