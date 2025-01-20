// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "../src/Staking.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {IStaking} from "../src/IStaking.sol";
import {Lazy721} from "../src/Lazy721.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {console} from "forge-std/console.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract StakingTest is Test {
    Lazy721 private lnft;
    Staking private staking;
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public exchangeApp = makeAddr("exchange");
    uint256 public fees = 0.01 ether;
    uint256 public rewardRate = 1;
    uint256 public tokenCap = 4;

    function setUp() public {
        lnft = new Lazy721("Lazy NFT", "LAZY", tokenCap, "ipfs://lazyhash/");
        staking = new Staking(address(lnft), rewardRate, fees);
    }

    function test_ImReady() public pure {
        assert(true);
    }

    // TDD Challenges
    // Step 1: Constructor Tests
    // Step 2: lock Function Tests
    // Step 3: Additional Tests for Acceptance Criteria and Edge Cases
    // Step 4: Additional Security Measures Tests
    // Step 5: Unlock Functionality

    // ======================
    // Step 1: Constructor Tests
    //      What parameters needs the constructor according to the specifications documents?
    //      What need are the `sannity` checks that I must consider?

    // Test 1.1: Sanity Checks - Zero Address
    // Assertion: Verify the constructor reverts with a zero address for 0001-nft-start-locking.md.
    /**
    Scenario: Constructor error - Missing NFT address
        Given I do not provide an NFT address (i.e., empty string)
        When I attempt to deploy the contract
        Then an error "MissingNftAddress" should be thrown    
     */

    /**
    Scenario: Constructor error - NFT address is zero
        Given I provide an NFT address set to 0 (i.e., "0x000...000")
        When I attempt to deploy the contract
        Then an error "NFTAddressCannotBeZero" should be thrown    
     */
    function test_Constructor_ZeroAddressSanity() public {
        // Given I provide an NFT address set to 0
        address lnftAddr = address(0);
        // Then an error "NFTAddressCannotBeZero" should be thrown
        // When I attempt to deploy the contract
        vm.expectRevert(IStaking.MissingNftAddress.selector);
        staking = new Staking(lnftAddr, 1, 0.01 ether);
    }

    // Test 1.2: Sanity Checks - Invalid Reward Rate
    // Assertion: Verify the constructor reverts with an invalid (e.g., negative) rewardRate.
    /**
    Scenario: Constructor error - Invalid reward rate (less than or equal to 0)
        Given I set a reward rate less than or equal to 0
        When I attempt to deploy the contract
        Then an error "InvalidRewardRate" should be thrown    
     */
    function test_Constructor_InvalidRewardRateSanity() public {
        lnft = new Lazy721("Lazy NFT", "LAZY", 4, "ipfs://lazyhash/");
        // Given I set a reward rate less than or equal to 0
        // When I attempt to deploy the contract
        // Then an error "InvalidRewardRate" should be thrown
        vm.expectRevert(IStaking.InvalidRewardRate.selector);
        staking = new Staking(address(lnft), 0, 0.01 ether);
    }

    // Test 1.3: Constructor Parameters
    /**
    Scenario: Successful constructor initialization with valid parameters
        Given I provide a valid NFT address
        And I set a reward rate greater than 0
        And I set a fee amount greater than or equal to 0
        When I deploy the contract with these parameters
        Then the contract should be deployed successfully
        And the NFT address should be set correctly
        And the reward rate should be set correctly
        And the fee amount should be set correctly
     */
    function test_ConstructorSuccess() public {
        // Given I provide a valid NFT address
        Lazy721 nft = new Lazy721("Lazy NFT", "LAZY", 4, "ipfs://lazyhash/");
        // And I set a reward rate greater than 0
        uint256 newRewardRate = 1;
        // And I set a fee amount greater than or equal to 0
        uint256 newFees = 0.01 ether;

        // When I deploy the contract with these parameters
        Staking newStaking = new Staking(address(nft), newRewardRate, newFees);

        // Then the contract should be deployed successfully
        // And the NFT address should be set correctly
        assert(address(newStaking) != address(0));
        // And the reward rate should be set correctly
        assert(newStaking.rewardRate() > 0);
        // And the fee amount should be set correctly
        assert(newStaking.fees() > 0);
    }

    // ======================
    // Step 2: lock Function Tests
    //      What parameters needs the `Lock` function according to the specifications documents.
    //      What need are the `sannity` checks that I must consider?
    //      How will I calculate the rewards earning?

    // Test 2.1: Token Ownership
    // Assertion: Verify only the token owner can start locking.
    /**
    Scenario: Lock NFT that I do not own
        Given I do not own the NFT
        When I try to lock the NFT for staking
        Then a NotYourNFTToken error should be thrown
     */
    function test_Lock_TokenOwnership() public {
        // Given I do not own the NFT
        lnft.safeMint(user1);
        assertEq(lnft.balanceOf(user1), 1);
        deal(user1, fees);
        deal(user2, fees);

        vm.prank(user1);
        lnft.approve(address(staking), 0);
        assert(lnft.getApproved(0) == address(staking));
        // When I try to lock the NFT for staking
        // Then a NotYourNFTToken error should be thrown
        vm.prank(user2);
        vm.expectRevert(IStaking.NotYourNFTToken.selector);
        staking.lock{value: fees}(0, IStaking.Period.ONE_DAY);
    }

    // Test 2.2: Fee Payment
    // Assertion: Verify sufficient funds are required for the transaction.
    /**  
    Scenario: Lock NFT with insufficient fees
        Given I have an NFT
        And I am the owner of the NFT
        And I have granted the staking contract my NFT allowance
        When I lock the NFT for staking with insufficient fees
        Then an InsuficientFundsSent error should be thrown
    */
    function test_Lock_FeePayment() public {
        // Given I have an NFT
        lnft.safeMint(user1);
        assertEq(lnft.balanceOf(user1), 1);

        // And I am the owner of the NFT
        assertEq(lnft.ownerOf(0), user1);

        // And I have granted the staking contract my NFT allowance
        vm.prank(user1);
        lnft.approve(address(staking), 0);
        assert(lnft.getApproved(0) == address(staking));
        // When I lock the NFT for staking with insufficient fees
        // Then an InsufficientFundsSent error should be thrown
        vm.prank(user1);
        vm.expectRevert(IStaking.InsufficientFundsSent.selector);
        staking.lock(0, IStaking.Period.ONE_DAY);
    }

    // Test 2.3: NFT Not Found
    // Assertion: Verify the contract reverts when attempting to Lock a non-existent NFT.
    /** 
    Scenario: Lock NFT that does not exist
        Given I do not have an NFT
        When I try to lock the NFT for staking
        Then an InvalidTokenId error should be thrown
     */
    function test_NFTNotFound() public {
        deal(user1, fees);
        // Given I do not have an NFT
        //When I try to lock the NFT for staking
        //Then an InvalidTokenId error should be thrown
        vm.prank(user1);
        vm.expectRevert();
        staking.lock{value: fees}(0, IStaking.Period.ONE_DAY);
    }

    // Test 2.4: Successful locking
    // Assertion: Verify locking is successfully initiated.
    /**
    Scenario: Lock NFT for staking
        Given I have an NFT
        And I am the owner of the NFT
        And I have granted the staking contract my NFT allowance
        When I lock the NFT for staking with a valid period
        And I pay the required fees
        Then the NFT should be locked for staking
        And I should be able to view my NFT ownership to staking contract   
     */
    function test_Lock_Success() public {
        // Given I have an NFT
        lnft.safeMint(user1);
        assertEq(lnft.balanceOf(user1), 1);
        // Ensure user1 balance can pay fees
        deal(user1, fees);
        // And I am the owner of the NFT
        assertEq(lnft.ownerOf(0), user1);

        // And I have granted the staking contract my NFT allowance
        vm.prank(user1);
        lnft.approve(address(staking), 0);
        assert(lnft.getApproved(0) == address(staking));

        // When I lock the NFT for staking with a valid period
        // And I pay the required fees
        vm.prank(user1);
        staking.lock{value: fees}(0, IStaking.Period.ONE_DAY);
        // Then the NFT should be locked for staking
        (uint256 startHeight, ) = staking.users(user1, 0);
        assert(startHeight == block.number);
        // And I should be able to view my NFT ownership to staking contract
        assertEq(lnft.ownerOf(0), address(staking));
    }

    // Test 2.6: Edge Case - locking Already Started
    // Assertion: Verify the contract reverts when attempting to restart locking for an already locking NFT.
    // Preconditions:
    //   - An NFT with already started locking is used for testing.
    // Verify the contract reverts with the expected error message ("lockingAlreadyStarted").
    /**
    Scenario: Lock NFT that is already staked
        Given I have an NFT that is already staked
        When I try to lock the NFT for staking
        Then an NotYourNFTToken error should be thrown    
     */
    function test_LockingAlreadyStarted() public {
        // Given I have an NFT that is already staked
        lnft.safeMint(user1);
        assertEq(lnft.balanceOf(user1), 1);
        // Ensure user1 balance can pay fees
        deal(user1, fees);
        assertEq(lnft.ownerOf(0), user1);
        vm.prank(user1);
        lnft.approve(address(staking), 0);
        assert(lnft.getApproved(0) == address(staking));
        vm.prank(user1);
        staking.lock{value: fees}(0, IStaking.Period.ONE_DAY);
        // Then the NFT should be locked for staking
        (uint256 startHeight, ) = staking.users(user1, 0);
        assert(startHeight == block.number);
        // And I should be able to view my NFT ownership to staking contract
        assertEq(lnft.ownerOf(0), address(staking));
        // When I try to lock the NFT for staking
        // Then a NotYourNFTToken error should be thrown
        vm.expectRevert(IStaking.NotYourNFTToken.selector);
        staking.lock{value: fees}(0, IStaking.Period.ONE_DAY);
    }

    // Test 2.7: Lock - Different Periods
    // Assertion: Verify locking with different periods updates correctly.
    /** Scenario: Lock NFT with invalid period
        Given I have an NFT
        And I am the owner of the NFT
        When I lock the NFT for staking with an invalid period
        Then an InvalidPeriod error should be thrown
     */
    /**
    Scenario: Lock NFT with negative or zero period
        Given I have an NFT
        And I am the owner of the NFT
        When I lock the NFT for staking with a negative or zero period
        Then an InvalidPeriod error should be thrown
     */
    function test_LockDifferentPeriods() public {
        // this cant be done since `Period` is force as a type input with only 3 values.
    }

    // Test 2.8: Lock - Reward Calculation Correctness
    /**
    Scenario Outline: Points calculation for valid lock periods
        Given I have an NFT locked for staking with a <period> period
        And the NFT was locked for Period.ONE_DAY
        When I check my staking points
        Then my points should be calculated as <expected_points> based on the reward rate    
     */
    function test_RewardCalculationValidPeriod() public {
        // Given I have an NFT
        lnft.safeMint(user1);
        assertEq(lnft.balanceOf(user1), 1);
        // Ensure user1 balance can pay fees
        deal(user1, fees);
        // And I am the owner of the NFT
        assertEq(lnft.ownerOf(0), user1);

        // And I have granted the staking contract my NFT allowance
        vm.prank(user1);
        lnft.approve(address(staking), 0);
        assert(lnft.getApproved(0) == address(staking));

        // When I lock the NFT for staking with a valid period
        // And I pay the required fees
        vm.prank(user1);
        staking.lock{value: fees}(0, IStaking.Period.ONE_DAY);
        // Then the NFT should be locked for staking
        (uint256 startHeight, uint256 endHeight) = staking.users(user1, 0);
        assert(startHeight == block.number);
        // And I should be able to view my NFT ownership to staking contract
        assertEq(lnft.ownerOf(0), address(staking));
        // Check reward amount transferred
        uint256 expectedReward = (endHeight - startHeight) *
            staking.rewardRate();

        assert(staking.rewards(user1) == expectedReward);
    }

    // ======================
    // Step 3: Unlock Functionality
    //  - What parameters needs the `Unlock` function according to the specifications documents.
    //  - What need are the `sannity` checks that I must consider?
    //  - How do I calculate the `rewards` earned?

    /**
    Scenario: Unlock NFT that does not exist
        Given I am a user with a non-existent NFT
        When I call the unlockNFT function with the non-existent NFT's tokenId
        Then an error is thrown with the message "InvalidTokenId"
     */

    /**
    Scenario: Unlock NFT that I do not own
        Given I am a user with an NFT that is owned by another user
        When I call the unlockNFT function with the NFT's tokenId
        Then an error is thrown with the message "NotYourNFTToken"
     */

    /**
    Scenario: Unlock NFT that is not staked
        Given I am a user with an NFT that is not staked
        When I call the unlockNFT function with the NFT's tokenId
        Then an error is thrown with the message "NFTNotStaked"
    */
    function test_Unlock_NFT_not_locked() public {
        // Ensure user1 balance can pay fees
        deal(user1, 2 * fees);

        // Then assert unstakingunlock is successful
        vm.prank(user1);
        vm.expectRevert(IStaking.NFTNotLocked.selector);
        staking.unlock{value: fees}(0);

    }

    // Test 3.2: Unlock - NFT Period hasnt pass to Unlock
    /** Scenario: Unlock NFT with invalid Time
    Given I am a user with an NFT that is staked
    And the staking period is not valid
    When I call the unlockNFT function with my NFT's tokenId
    Then an error is thrown with the message "NFTPeriodNotReady"
    */
    function test_Unlock_PeriodNotReady() public {
        // Lazy721 mint an NFT tokenId == 0 and trnasfer to user1
        lnft.safeMint(user1);
        assertEq(lnft.balanceOf(user1), 1);
        // Ensure user1 balance can pay fees
        deal(user1, 2 * fees);

        // user1 grants to staking contract to transfer
        vm.prank(user1);
        lnft.approve(address(staking), 0);
        assert(lnft.getApproved(0) == address(staking));

        // Given an Staking initialized contract with 1 staking
        vm.prank(user1);
        staking.lock{value: fees}(0, IStaking.Period.ONE_DAY);

        // Assert staking initiated correctly
        (uint256 startHeight, uint256 endHeight) = staking.users(user1, 0);
        uint256 expectedEnd = vm.getBlockNumber() +
            staking.lockHeights(IStaking.Period.ONE_DAY);
        uint256 expectedReward = staking.lockHeights(IStaking.Period.ONE_DAY) *
            staking.rewardRate();

        assert(staking.rewards(user1) == expectedReward);
        assert(startHeight == block.number);
        assert(endHeight == expectedEnd);

        // That the new onwer is the Staking contract
        assert(lnft.ownerOf(0) == address(staking));
        assert(lnft.balanceOf(user1) == 0);

        // jump to future to the unlock time + 1
        vm.roll(1);

        // Then assert unstakingunlock is successful
        vm.prank(user1);
        vm.expectRevert(IStaking.NFTPeriodNotReady.selector);
        staking.unlock{value: fees}(0);

    }
    // Test 3.2: Unlock - Insufficient Funds for Fees
    // Assertion: Verify the contract reverts when attempting to Unlock without sufficient funds for fees.
    // Preconditions:
    //  - An NFT with ongoing locking and insufficient user balance for fees is used.
    // Expect Revert "InsufficientFundsSent".
    /**
    Scenario: Unlock NFT without sufficient funds
        Given I am a user with an NFT that is staked
        And I have insufficient funds to pay the fees
        When I call the unlockNFT function with my NFT's tokenId
        Then an error is thrown with the message "InsuficientFundsSent"    
     */
    function test_Unlock_InsufficientFunds() public {
        // Lazy721 mint an NFT tokenId == 0 and trnasfer to user1
        lnft.safeMint(user1);
        assertEq(lnft.balanceOf(user1), 1);
        // Ensure user1 balance can pay fees
        deal(user1, 2 * fees);

        // user1 grants to staking contract to transfer
        vm.prank(user1);
        lnft.approve(address(staking), 0);
        assert(lnft.getApproved(0) == address(staking));

        // Given an Staking initialized contract with 1 staking
        vm.prank(user1);
        staking.lock{value: fees}(0, IStaking.Period.ONE_DAY);

        // Assert staking initiated correctly
        (uint256 startHeight, uint256 endHeight) = staking.users(user1, 0);
        uint256 expectedEnd = vm.getBlockNumber() +
            staking.lockHeights(IStaking.Period.ONE_DAY);
        uint256 expectedReward = staking.lockHeights(IStaking.Period.ONE_DAY) *
            staking.rewardRate();

        assert(staking.rewards(user1) == expectedReward);
        assert(startHeight == block.number);
        assert(endHeight == expectedEnd);

        // That the new onwer is the Staking contract
        assert(lnft.ownerOf(0) == address(staking));
        assert(lnft.balanceOf(user1) == 0);

        // jump to future to the unlock time + 1
        vm.roll(endHeight + 1);

        // When I call the unlockNFT function with my NFT's tokenId
        // Then an error is thrown with the message "InsuficientFundsSent"    
        vm.prank(user1);
        vm.expectRevert(IStaking.InsufficientFundsSent.selector);
        staking.unlock(0);
    }

    // Test 3.1: Unlock - Successful Unlocking
    // Assertion: Verify unlocking is successfully initiated for an NFT that is currently locking.
    // Preconditions:
    //  - An NFT with ongoing locking is used for testing.
    /**
    Scenario: Unlock NFT successfully
        Given I am a user with an NFT that is staked
        And I have sufficient funds to pay the fees
        When I call the unlockNFT function with my NFT's tokenId
        Then the NFT is unlocked
        And the transaction is successful
     */
    function test_Unlock_Success() public {
        // Lazy721 mint an NFT tokenId == 0 and trnasfer to user1
        lnft.safeMint(user1);
        assertEq(lnft.balanceOf(user1), 1);
        // Ensure user1 balance can pay fees
        deal(user1, 2 * fees);

        // user1 grants to staking contract to transfer
        vm.prank(user1);
        lnft.approve(address(staking), 0);
        assert(lnft.getApproved(0) == address(staking));

        // Given an Staking initialized contract with 1 staking
        vm.prank(user1);
        staking.lock{value: fees}(0, IStaking.Period.ONE_DAY);

        // Assert staking initiated correctly
        (uint256 startHeight, uint256 endHeight) = staking.users(user1, 0);
        uint256 expectedEnd = vm.getBlockNumber() +
            staking.lockHeights(IStaking.Period.ONE_DAY);
        uint256 expectedReward = staking.lockHeights(IStaking.Period.ONE_DAY) *
            staking.rewardRate();

        assert(staking.rewards(user1) == expectedReward);
        assert(startHeight == block.number);
        assert(endHeight == expectedEnd);

        // That the new onwer is the Staking contract
        assert(lnft.ownerOf(0) == address(staking));
        assert(lnft.balanceOf(user1) == 0);

        // jump to future to the unlock time + 1
        vm.roll(endHeight + 1);

        // Then assert unstakingunlock is successful
        vm.prank(user1);
        staking.unlock{value: fees}(0);

        (startHeight, endHeight) = staking.users(user1, 0);
        assert(staking.rewards(user1) == expectedReward);
        assert(startHeight == 0);
        // That the new onwer is the user1
        assert(lnft.ownerOf(0) == address(user1));
        assert(lnft.balanceOf(user1) == 1);
    }

    // ======================
    // Step 4: Whitelisting Tests

    // Test 4.1: Add to Whitelist - Success
    // Assertion: Verify an admin can successfully add an address to the whitelist.
    /**
    Scenario: Add account to whitelist successfully
        Given I am the owner
        And the account is valid
        And the account is not already in the whitelist
        When I add the account to the whitelist
        Then the account is added to the whitelist
        And I receive a success message
    */
    function test_AddToWhitelist_Success() public {}

    // Test 4.2: Add to Whitelist - Non-Admin Revert
    // Assertion: Verify a non-admin cannot add an address to the whitelist.
    /**
    Scenario: Fail to add account to whitelist - unauthorized
        Given I am not the owner
        And the account is valid
        When I add the account to the whitelist
        Then I receive an Unauthorized error
    */
    function test_AddToWhitelist_NonAdminRevert() public {}

    // Test 4.5: Whitelist Status - Edge Case (Zero Address)
    // Assertion: Verify the contract behaves as expected when querying the zero address.
    /**
    Scenario: Fail to add account to whitelist - invalid account
        Given I am the owner
        And the account is invalid
        When I add the account to the whitelist
        Then I receive an InvalidAccount error
    */
    function test_WhitelistStatus_ZeroAddress() public view {}

    /**
    Scenario: Fail to add account to whitelist - account already in whitelist
        Given I am the owner
        And the account is valid
        And the account is already in the whitelist
        When I add the account to the whitelist
        Then I receive an AccountAlreadyInWhitelist error
    */
    function test_AddToWhitelist_Twice() public {}

    // Test 4.3: Remove from Whitelist - Success
    // Assertion: Verify an admin can successfully remove an address from the whitelist.
    /**
    Scenario: Remove account from whitelist successfully
        Given I am the owner
        And the account is valid
        And the account is in the whitelist
        When I remove the account from the whitelist
        Then the account is removed from the whitelist
        And I receive a success message
    */
    function test_RemoveFromWhitelist_Success() public {}

    // Test 4.4: Remove from Whitelist - Non-Admin Revert
    // Assertion: Verify a non-admin cannot remove an address from the whitelist.
    /**
    Scenario: Fail to remove account from whitelist - unauthorized
        Given I am not the owner
        And the account is valid
        When I remove the account from the whitelist
        Then I receive an Unauthorized error
    */
    function test_RemoveFromWhitelist_NonAdminRevert() public {}

    /**
    Scenario: Fail to remove account from whitelist - invalid account
        Given I am the owner
        And the account is invalid
        When I remove the account from the whitelist
        Then I receive an InvalidAccount error
    */
    function test_RemoveFromWhitelist_InvalidAccount() public {}

    /**
    Scenario: Fail to remove account from whitelist - account not in whitelist
        Given I am the owner
        And the account is valid
        And the account is not in the whitelist
        When I remove the account from the whitelist
        Then I receive an AccountNotInWhitelist error
    */
    function test_RemoveFromWhitelist_NonExistanceAccount() public {}
}
