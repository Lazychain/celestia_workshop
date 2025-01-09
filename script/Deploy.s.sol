// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Staking} from "../src/Staking.sol";
import {Script, console} from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

contract StakingScript is Script {

    Staking public staking;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Start NFT Staking Deploy Script");
        console.log("---------------------");
        // parameters list
        console.log("---------------------");
        vm.startBroadcast(deployer);

        staking = new Staking();

        vm.stopBroadcast();

        console.log("---------------------");
        console.logString(string.concat("Staking addr[",vm.toString(address(staking)),"]"));
        console.log("---------------------");
    }

}
