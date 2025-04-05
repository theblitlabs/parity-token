// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {ParityToken} from "../src/ParityToken.sol";
import {ParityTokenProxy} from "../src/ParityTokenProxy.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract DeployUpgradeable is Script {
    using stdJson for string;

    // Initial supply of 100 million tokens with 18 decimals
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10 ** 18;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation
        ParityToken implementation = new ParityToken();

        // Prepare initialization data
        bytes memory initData = abi.encodeWithSelector(ParityToken.initialize.selector, INITIAL_SUPPLY);

        // Deploy proxy
        ParityTokenProxy proxy = new ParityTokenProxy(address(implementation), initData);

        vm.stopBroadcast();

        // Update .env file with new addresses
        string memory path = ".env";
        string memory envContents = vm.readFile(path);

        // Update all addresses in one read/write cycle
        envContents = _replaceOrAddEnvVar(envContents, "PROXY_ADDRESS", vm.toString(address(proxy)));
        envContents = _replaceOrAddEnvVar(envContents, "TOKEN_ADDRESS", vm.toString(address(proxy)));
        envContents = _replaceOrAddEnvVar(envContents, "IMPLEMENTATION_ADDRESS", vm.toString(address(implementation)));
        vm.writeFile(path, envContents);

        console2.log("Implementation deployed at:", address(implementation));
        console2.log("Proxy deployed at:", address(proxy));
        console2.log("Environment file updated with new addresses");
    }

    function _replaceOrAddEnvVar(string memory envContents, string memory key, string memory value)
        internal
        pure
        returns (string memory)
    {
        bytes memory keyBytes = bytes(key);
        bytes memory envBytes = bytes(envContents);

        uint256 keyIndex = _indexOf(envBytes, keyBytes);

        if (keyIndex == type(uint256).max) {
            return string.concat(envContents, key, "=", value, "\n");
        } else {
            uint256 valueStart = keyIndex + keyBytes.length + 1;

            bytes memory before = new bytes(valueStart);
            for (uint256 i = 0; i < valueStart; i++) {
                before[i] = envBytes[i];
            }

            uint256 lineEnd = 0;
            for (uint256 i = valueStart; i < envBytes.length; i++) {
                if (envBytes[i] == bytes1("\n")) {
                    lineEnd = i - valueStart;
                    break;
                }
            }
            if (lineEnd == 0) {
                lineEnd = envBytes.length - valueStart;
            }

            bytes memory remaining = new bytes(envBytes.length - (valueStart + lineEnd));
            for (uint256 i = 0; i < remaining.length; i++) {
                remaining[i] = envBytes[valueStart + lineEnd + i];
            }

            return string.concat(string(before), value, string(remaining));
        }
    }

    function _indexOf(bytes memory data, bytes memory pattern) internal pure returns (uint256) {
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
