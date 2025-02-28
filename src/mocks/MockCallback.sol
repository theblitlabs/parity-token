// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockCallback {
    bool public callbackReceived;

    function onTokenReceived(address, /* from */ uint256 /* amount */ ) external {
        callbackReceived = true;
    }
}
