// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MockCallback {
    uint256 public callCount;

    function mockFunction() external {
        callCount++;
    }
}
