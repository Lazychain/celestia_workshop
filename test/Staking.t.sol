// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Staking} from "../src/Staking.sol";
import {Test, console} from "forge-std/Test.sol";

contract StakingTest is Test {

    Staking public staking;

    function setUp() public {
        staking = new Staking();
    }

    function test_ImReady() public pure {
        assert(true);
    }

}
