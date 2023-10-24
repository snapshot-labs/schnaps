// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";

import { Schnaps } from "../src/Schnaps.sol";

/// @notice Script to deploy the Schnaps
contract Deployer is Script {
    address owner = address(0xc83A9e69012312513328992d454290be85e95101);

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
    
        Schnaps schnaps = new Schnaps(owner);
    
        vm.stopBroadcast();
    }
}