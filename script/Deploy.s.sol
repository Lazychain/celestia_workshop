// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Staking} from "../src/Staking.sol";
import {Script, console} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Lazy721} from "../src/Lazy721.sol";
import {Lazy20} from "../src/Lazy20.sol";
import {Staking} from "../src/Staking.sol";
import {Exchange} from "../src/Exchange.sol";

contract Deploy is Script {
    event ContractDeployed(
        address indexed contractAddress,
        string contractName
    );

    function run() external {
        uint256 fees = 0.01 ether;
        uint256 rewardRate = 1;
        uint256 tokenCap = 4;
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        Lazy20 token = new Lazy20();
        emit ContractDeployed(address(token), "Lazy20");
        Lazy721 lnft = new Lazy721(
            "Lazy NFT",
            "LAZY",
            tokenCap,
            "ipfs://lazyhash/"
        );
        emit ContractDeployed(address(lnft), "Lazy721");
        Staking staking = new Staking(address(lnft), rewardRate, fees);
        emit ContractDeployed(address(staking), "Staking");
        Exchange exchange = new Exchange(
            address(staking),
            address(token),
            2 * fees
        );
        emit ContractDeployed(address(exchange), "Exchange");
        vm.stopBroadcast();

        console.log("---------------------");
        console.logAddress(address(token));
        console.logAddress(address(lnft));
        console.logAddress(address(staking));
        console.logAddress(address(exchange));
        console.log("---------------------");
    }
}
