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

    // TDD Challenges
    // Constructor: 
    // What parameters needs the constructor according to the specifications documents.
    // What need are the `sannity` checks that I must consider?

    // function stake:
    // What parameters needs the `stake` function according to the specifications documents.
    // What need are the `sannity` checks that I must consider?
    // How will I calculate the rewards earning?

    // function unstake:
    // What parameters needs the `unstake` function according to the specifications documents.
    // What need are the `sannity` checks that I must consider?
    // How do I calculate the `rewards` earned?
}
