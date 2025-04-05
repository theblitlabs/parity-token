// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {ParityToken} from "../src/ParityToken.sol";
import {UUPSUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract UpgradeToken is Script {
    using stdJson for string;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation (uninitialized)
        ParityToken newImplementation = new ParityToken();

        // Upgrade proxy to new implementation (no initialization needed)
        UUPSUpgradeable(proxyAddress).upgradeToAndCall(address(newImplementation), "");

        vm.stopBroadcast();

        string memory path = ".env";
        string memory envContents = vm.readFile(path);

        vm.writeFile(
            path, _replaceOrAddEnvVar(envContents, "IMPLEMENTATION_ADDRESS", vm.toString(address(newImplementation)))
        );

        console2.log("New implementation deployed at:", address(newImplementation));
        console2.log("Proxy upgraded at:", proxyAddress);
        console2.log("Environment file updated with new implementation address");
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
