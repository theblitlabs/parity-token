// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {ParityToken} from "../src/ParityToken.sol";
import {ParityTokenProxy} from "../src/ParityTokenProxy.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract DeployUpgradeable is Script {
    using stdJson for string;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation
        ParityToken implementation = new ParityToken();

        // Prepare initialization data
        bytes memory initData = abi.encodeWithSelector(
            ParityToken.initialize.selector,
            1_000_000 * 10 ** 18 // Initial supply of 1M tokens
        );

        // Deploy proxy
        ParityTokenProxy proxy = new ParityTokenProxy(
            address(implementation),
            initData
        );

        vm.stopBroadcast();

        // Update .env file with new addresses
        string memory path = ".env";
        string memory envContents = vm.readFile(path);

        // Replace or add PROXY_ADDRESS
        vm.writeFile(
            path,
            _replaceOrAddEnvVar(
                envContents,
                "PROXY_ADDRESS",
                vm.toString(address(proxy))
            )
        );

        // Replace or add TOKEN_ADDRESS (same as PROXY_ADDRESS for convenience)
        vm.writeFile(
            path,
            _replaceOrAddEnvVar(
                vm.readFile(path),
                "TOKEN_ADDRESS",
                vm.toString(address(proxy))
            )
        );

        // Replace or add IMPLEMENTATION_ADDRESS
        vm.writeFile(
            path,
            _replaceOrAddEnvVar(
                vm.readFile(path),
                "IMPLEMENTATION_ADDRESS",
                vm.toString(address(implementation))
            )
        );

        console2.log("Implementation deployed at:", address(implementation));
        console2.log("Proxy deployed at:", address(proxy));
        console2.log("Environment file updated with new addresses");
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
