// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Exchange} from "../src/Exchange.sol";
import {Lazy20} from "../src/Lazy20.sol";
import {Lazy721} from "../src/Lazy721.sol";
import {Staking} from "../src/Staking.sol";
import {IStaking} from "../src/IStaking.sol";
import {IExchange} from "../src/IExchange.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {console} from "forge-std/console.sol";

contract ExchangeTest is Test {
    // **Contract Instances**
    Lazy20 private token; ///< Instance of Lazy20 (ERC20 Token)
    Lazy721 private lnft; ///< Instance of Lazy721 (ERC721 NFT)
    Staking private staking; ///< Instance of Staking contract
    Exchange private exchange; ///< Instance of Exchange contract under test

    // **Test Addresses**
    address public user1 = makeAddr("user1"); ///< First test user address
    address public user2 = makeAddr("user2"); ///< Second test user address (currently unused)

    // **Constants**
    uint256 public fees = 0.01 ether; ///< Fee amount set for Staking and Exchange operations

    uint256 public rewardRate = 1;
    uint256 public tokenCap = 4;

    /**
     * @dev Setup function called before each test
     * @notice Initializes contract instances and test variables
     */
    function setUp() public {
        // **Given**: Test environment setup with users and contracts
        // **When**: Contracts are deployed for testing
        token = new Lazy20(); ///< Deploy new Lazy20 (ERC20) token contract
        lnft = new Lazy721("Lazy NFT", "LAZY", tokenCap, "ipfs://lazyhash/"); ///< Deploy new Lazy721 (ERC721) NFT contract
        staking = new Staking(address(lnft), rewardRate, fees); ///< Deploy new Staking contract with NFT, reward rate, and fees
        exchange = new Exchange(address(staking), address(token), 2 * fees); ///< Deploy new Exchange contract with Staking, Token, and fees
        // **Then**: Setup is complete, ready for individual test executions
    }

    /**
     * @dev Sanity check test to ensure test suite is operational
     * @notice Always passes if the test suite is correctly set up
     */
    function test_ImReady() public pure {
        // **Given**: Test suite is set up
        // **When**: Sanity check test is executed
        // **Then**: Test passes if the setup is correct
        assert(true); ///< Always true, ensuring test suite operability
    }

    /**
     * @dev Test successful reward exchange
     * @notice Verifies user can exchange earned points for tokens
     */
    /**
    Scenario: Successful points exchange for ERC-20 tokens
        Given I have sufficient points for exchange
        And I send enough fees for the transaction
        And the contract has sufficient ERC-20 tokens
        When I call the exchangeRewards function
        Then my points are successfully exchanged for ERC-20 tokens
        And the ExchangeRewardsSuccess event is emitted
    */
    function test_exchangeRewards_Success() public {
        // **Given**:
        // 1. User1 has a minted NFT
        // 2. NFT is staked to earn points
        // 3. User has enough points and contract has tokens for exchange
        // 4. User1 has ether to cover fees
        // **When**: User exchanges rewards
        // **Then**:
        // 1. User receives tokens
        // 2. User's points decrease
        // 3. Exchange success event is emitted
    }

    /**
     * @dev Test exchange with insufficient funds sent
     * @notice Verifies reversion when user doesn't have enough ether for fees
     */
    /**
    Scenario: Insufficient funds sent for fees
        Given I send insufficient funds for fees
        When I call the exchangeRewards function
        Then an InsuficientFundsSent error is thrown
    */
    function test_exchangeRewards_InsufficientFundsSent() public {
        // **Given**: User1 has ether to cover fees
        // **When**: User attempts to exchange rewards
        // **Then**: Transaction reverts with InsufficientFundsSent error
    }

    /**
     * @dev Test exchange with insufficient tokens to exchange
     * @notice Verifies reversion when the contract doesn't have enough tokens
     */
    /**
    Scenario: Contract has insufficient ERC-20 tokens
        Given the contract does not have enough ERC-20 tokens for exchange
        When I call the exchangeRewards function
        Then an InsuficientTokensToExchange error is thrown
    */
    function test_exchangeRewards_InsufficientTokensToExchange() public {
        // **Given**:
        // 1. Contract doesn't have enough tokens for exchange
        // 2. Ensure that the exchage contract is on whitelist
        // 3. Assuming the NFT contract is deployed and token owner is user1
        // 4. And a TokenId1
        // 5. user1 grants to staking contract to transfer
        // **When**: User exchanges rewards
        // **Then**: Transaction reverts with InsuficientTokensToExchange error
    }

    /**
     * @dev Test exchanging zero points
     * @notice Verifies behavior when user attempts to exchange 0 points
     * @notice Assuming it either reverts with InsufficientPoints or a specific handler for 0 points
     */
    function test_exchangeRewards_ZeroPoints() public {
        // **Given**: User1 attempts to exchange 0 points
        // **When**: User attempts to exchange 0 points
        // **Then**: Transaction reverts with an appropriate error
    }

    /**
     * @dev Test exchange for a non-existing user
     * @notice Verifies behavior for a user without any stakes or points
     * @notice Assuming it reverts with InsufficientPointsToExchange or another relevant error
     */
    function test_exchangeRewards_NonExistingUser() public {
        // **Given**: Non-existing user with no stakes or points
        // **When**: Non-existing user attempts to exchange rewards with sufficient fees
        // **Then**: Transaction reverts with an appropriate error
    }

    /**
     * @dev Test exchanging rewards with a non-whitelisted contract
     * @notice Verifies reversion when the exchange contract isn't whitelisted for staking rewards
     */
    function test_exchangeRewards_NonWhitelistedContract() public {
        // **Given**: Exchange contract is not whitelisted for staking
        // 1. Assuming setup for user1 with rewards (reuse setup from test_exchangeRewards_Success)
        // **When**: Attempt to exchange rewards without being whitelisted
        // **Then**: Transaction reverts with ContractNotWhitelisted error
        // 1. **Reversion Occurred**: Already verified by `vm.expectRevert`.
        // 2. **State Remains Unchanged**
    }

    /**
     * @dev Test exchanging rewards with an invalid token ID
     * @notice Verifies reversion for non-existent or invalid token IDs
     */
    /**
    Scenario: Insufficient points for exchange
        Given I do not have enough points for exchange
        When I call the exchangeRewards function
        Then an InsuficientPointsToExchange error is thrown
    */
    function test_exchangeRewards_InvalidPointsCount() public {
        // **Given**: Exchange contract is not whitelisted for staking
        // 1. whitelist exchange contract
        // **When**: Attempt to exchange rewards with an invalid token ID
        // **Then**: Transaction reverts with InsuficientPointsToExchange error
        // 1. **Reversion Occurred**: Already verified by `vm.expectRevert`.
        // 2. **State Remains Unchanged**
    }

    function test_getExchangeFees() public view {
        // **Given**: Exchange contract with predefined fees
        // **When**: Call getExchangeFees function
        // **Then**: Verify the returned fees match the expected fees
    }

    function test_getStakingFees() public view {
        // **Given**: Exchange contract with predefined staking fees (fetched from Staking contract)
        // **When**: Call getStakingFees function
        // **Then**: Verify the returned staking fees match the expected staking fees
    }

    function test_getFees_AfterConstructorUpdate() public {
        // **Given**: New fees value (different from the initial one)
        // **When**: Update the Exchange contract's fees via constructor (for testing purposes only)
        // **Then**: Verify the updated fees are reflected in getExchangeFees
        // **And**: Verify getStakingFees remains unchanged (still fetches from Staking contract)
    }
}
