# 1. User NFT Lock Flow

```mermaid
---
title: User NFT Lock Flow
---
flowchart LR
    A(User Logged) --> B{NFT on List? / Ownership}
    B --> |Yes| C(Select Token)
    C --> D{User is owner of the token?}
    D --> |Yes| E(Select Locking Period)
    E --> F{Is period valid?}
    F --> |Yes| G{Are funds sufficient?}
    G --> |Yes| H(Execute and Pay Fees)
    H --> I(Update NFT Ownership)

    D --> |No| X(NotYourNFTToken)
    E --> |No| Y(InvalidPeriod)
    F --> |No| Y(InvalidPeriod)
    G --> |No| Z(InsuficientFundsSent)
    B --> |No| W(InvalidTokenId)
```

## Contract

### Errors

The contract throws the following errors:

```solidity
// Custom error types
error InvalidFees(); // thrown when the fees are invalid (less than 0)
error InvalidRewardRate(); // thrown when the reward rate is invalid (less than 0)
error MissingNftAddress(); // thrown when the NFT contract address is not provided
error NFTAddressCannotBeZero(); // thrown when the NFT contract address is the zero address
error InvalidTokenId(); // thrown when the token ID does not exist
error NotYourNFTToken(); // thrown when the token does not belong to the user attempting an action
error InsuficientFundsSent(); // thrown when insufficient funds are sent for fees
error ClaimNotReady(); // thrown when (actual height - (stop height + period)) blocks is less than 0
error Unauthorized(); // thrown when has no enough access permissions
error InvalidPeriod(); // thrown when the staking period is not valid enumerate option
error AlreadyStaked(); // thrown when attempting to start staking for a token already staked
error NFTNotStaked(); // thrown when attempting to stop staking for a token not staked by the user
```

### Events

```solidity
// Define events
event LockNFTSuccess();
event UnlockNFTSuccess();
event RecoverNFTSuccess();
event ConsumeRewardsSuccess();
```

### Structs

```solidity
// Enum for periods
enum Period {
    ONE_DAY,
    SEVEN_DAYS,
    TWENTY_ONE_DAYS
}

// Struct for TokenData
struct TokenData {
    Period period; // Represents the period measured by height units that the NFT gets lock after unlocked where no Rewards are generated during this Period.
    uint256 start; // Starting height use on rewards calculation. Start when the owner stake and transfer ownership.
    uint256 end; // Ending height use on rewards calculation. Once unstake it, no more rewards will be counted.
}

// Struct for UserData
struct UserData {
    uint256 rewards; // Acumulated reward points, only updated when claim successful.
    mapping(uint256 => TokenData) tokens; // User token mapping data
}
```

### Variables

```solidity
// State Variables
address public nft; // Represents the ERC721 address
uint256 public rewardRate; // Represents how many rewards are produced by each height increase while staked
uint256 public fees; // Fees for startStaking(), stopStaking() and recover()
mapping(address => UserData) public users; // users staking and nft data
mapping(address => bool) public whitelist; // list of smart contracts that can interact with user points
```

### Functions

```solidity
/**
 * @dev Constructor function for the contract
 * @param _nftAddress Address of the NFT contract
 * @param _rewardRate Reward rate for staking
 * @param _feeAmount Fee amount for locking NFTs
 */
constructor(address _nftAddress, uint256 _rewardRate, uint256 _feeAmount) public {
  // - Store the owner.
  // - Check `rewardRate` =< 0
  //   - Throw `InvalidRewardRate`.
  // - Set `rewardRate`.
  // - Check `erc721` address == "".
  //   - Throw `MissingNftAddress`
  // - Check `erc721` address == 0.
  //   - Throw `NFTAddressCannotBeZero`
  // - Set `erc721` address.
  // - Check `rewardRate` < 0
  //   - Throw `InvalidFees`.
  // - Set `fees`.
}
```

```solidity
/**
 * @dev Locks an NFT for a specified period of time
 * @param tokenId The ID of the NFT to lock
 * @param period The period of time to lock the NFT for
 * @return bool Whether the NFT was successfully locked
 */
function lock(uint256 tokenId, uint256 period) public payable {
  // - Check if `tokenId` exist using `ERC721` `balanceOf(sender)` method.
  //   - Throw error `InvalidTokenId`
  // - Check `tokenId` ownership.
  //   - Throw error `NotYourNFTToken`
  // - Check `tokenId` has `user.get(tokenId).start > 0`.
  //   - Throw `AlreadyStaked`
  // - Check if `msg.value >= fees`
  //   - Throw error `InsuficientFundsSent`
  // - Check if correct `period` with valid enums periods.
  //   - Throw error `InvalidPeriod`
  // - Set as owner of `tokenId` using `IERC721` interface `safeTransferFrom(from, to, tokenId)`.
  // - Update `user.get(tokenId).start` and `user.get(tokenId).period`.
  // - Return event `LockNFTSuccess`
}
```

## User Scenarios

```gherkin
Feature: NFT Stake Lock Constructor
  As a contract deployer
  I want to ensure the constructor initializes the contract correctly
  So that the NFT stake lock functionality works as expected

  Scenario: Successful constructor initialization with valid parameters
    Given I provide a valid NFT address
    And I set a reward rate greater than 0
    And I set a fee amount greater than or equal to 0
    When I deploy the contract with these parameters
    Then the contract should be deployed successfully
    And the NFT address should be set correctly
    And the reward rate should be set correctly
    And the fee amount should be set correctly

  Scenario: Constructor error - Missing NFT address
    Given I do not provide an NFT address (i.e., empty string)
    When I attempt to deploy the contract
    Then an error "MissingNftAddress" should be thrown

  Scenario: Constructor error - NFT address is zero
    Given I provide an NFT address set to 0 (i.e., "0x000...000")
    When I attempt to deploy the contract
    Then an error "NFTAddressCannotBeZero" should be thrown

  Scenario: Constructor error - Invalid reward rate (less than or equal to 0)
    Given I set a reward rate less than or equal to 0
    When I attempt to deploy the contract
    Then an error "InvalidRewardRate" should be thrown

  Scenario Outline: Edge cases for reward rate and fee amount
    Given I set a reward rate to <reward_rate>
    And I set a fee amount to <fee_amount>
    When I attempt to deploy the contract
    Then the result should be <result>

    Examples:
      | reward_rate | fee_amount | result                                             |
      | 0           | 0          | Error "InvalidRewardRate" thrown                  |
      | 0           | 0          | Error "InvalidRewardRate" thrown                  |
      | 1           | 0          | Contract deployed successfully                     |
```

```gherkin
Feature: NFT Start Staking
  As a user
  I want to be able to lock my NFT for staking
  So that I can earn rewards

  Scenario: Lock NFT for staking
    Given I have an NFT
    And I am the owner of the NFT
    When I lock the NFT for staking with a valid period
    And I pay the required fees
    Then the NFT should be locked for staking
    And I should be able to view my NFT ownership

  Scenario: Lock NFT with invalid period
    Given I have an NFT
    And I am the owner of the NFT
    When I lock the NFT for staking with an invalid period
    Then an InvalidPeriod error should be thrown

  Scenario: Lock NFT that does not exist
    Given I do not have an NFT
    When I try to lock the NFT for staking
    Then an InvalidTokenId error should be thrown

  Scenario: Lock NFT that is already staked
    Given I have an NFT that is already staked
    When I try to lock the NFT for staking
    Then an AlreadyStaked error should be thrown

  Scenario: Lock NFT that I do not own
    Given I do not own the NFT
    When I try to lock the NFT for staking
    Then a NotYourNFTToken error should be thrown

  Scenario: Lock NFT with negative or zero period
    Given I have an NFT
    And I am the owner of the NFT
    When I lock the NFT for staking with a negative or zero period
    Then an InvalidPeriod error should be thrown

  Scenario: Lock NFT with insufficient fees
    Given I have an NFT
    And I am the owner of the NFT
    When I lock the NFT for staking with insufficient fees
    Then an InsuficientFundsSent error should be thrown
```

```gherkin
Feature: NFT Staking Points Calculation
  As a user
  I want the system to correctly calculate my staking points
  Based on the locked NFT's period
  So that I can accurately track my rewards

  Scenario Outline: Points calculation for valid lock periods
    Given I have an NFT locked for staking with a <period> period
    And the current block height is <current_height>
    And the NFT was locked at block height <lock_height>
    When I check my staking points
    Then my points should be calculated as <expected_points> based on the reward rate

    Examples:
      | period        | current_height | lock_height | expected_points |
      | ONE_DAY       | 100            | 90          | 10 * rewardRate |
      | SEVEN_DAYS    | 200            | 150         | 50 * rewardRate |
      | TWENTY_ONE_DAYS| 300            | 250         | 50 * rewardRate |

```

```gherkin
Feature: NFT Staking Points Calculation Error Handling
  As a user
  I want the system to handle points calculation errors correctly
  Based on the locked NFT's period and system constraints
  So that I can understand and resolve any issues

  Scenario: Points calculation for an invalid lock period
    Given I have an NFT locked with an invalid period (e.g., ZERO_DAYS)
    When I check my staking points
    Then an error "InvalidPeriodForPointsCalculation" should be displayed
```

### Acceptance Criteria

- The user can lock their NFT for staking with a valid period.
- The user can pay the required fees for locking their NFT for staking.
- The NFT is locked for staking and the user can view their NFT ownership.
- An error is displayed if the user tries to lock an NFT with an invalid period.
- An error is displayed if the user tries to lock an NFT without paying the required fees.
- An error is displayed if the user tries to lock an NFT that does not exist.
- An error is displayed if the user tries to lock an NFT that is already staked.
- An error is displayed if the user tries to lock an NFT that they do not own.
- An error is displayed if the user tries to lock an NFT with a negative or zero period.
- An error is displayed if the user tries to lock an NFT with insufficient fees.

### Test Data Requirements

- NFTs with different ownership statuses (e.g. owned by the user, not owned by the user, already staked)
- Different periods for locking NFTs (e.g. valid periods, invalid periods, negative or zero periods)
- Different fee amounts for locking NFTs (e.g. required fees, insufficient fees)
- NFT Lock Periods: Multiple NFTs locked with different valid periods (ONE_DAY, SEVEN_DAYS, TWENTY_ONE_DAYS)
- Block Height Variations: Scenarios with varying block heights to test points accumulation over time

### Definition of Done (DoD)

- The feature is fully implemented, and all scenarios have been tested.
- All acceptance criteria have been met.
- The feature has been reviewed and approved by the product owner.
- The feature has been tested and validated by the QA team.
- All bugs and issues have been resolved.
- The feature is fully documented, including user documentation and technical documentation.
- The feature has been deployed to production and is available for use by users.

## Description

### NFT Stake Lock Functionality Explanation

#### **Step 1: Constructor Initialization**

* **Purpose:** Initializes the NFT Stake Lock contract with essential parameters.
* **Parameters:**
  * `_nftAddress`: The address of the ERC721 NFT contract.
  * `_rewardRate`: The rate at which rewards are generated per block height increase while staking.
  * `_feeAmount`: The fee required for locking NFTs.
* **Validation:**
  * Ensures `_nftAddress` is not empty and not set to zero.
  * Verifies `_rewardRate` is greater than 0.
  * Checks `_feeAmount` is not negative (can be 0).

#### **Step 2: Locking an NFT for Staking**

* **Function:** `lock(uint256 tokenId, uint256 period)`
* **Purpose:** Locks a specified NFT for a defined staking period.
* **Parameters:**
  * `tokenId`: The ID of the NFT to be locked.
  * `period`: The duration for which the NFT is locked (e.g., ONE_DAY, SEVEN_DAYS, TWENTY_ONE_DAYS).
* **Validation & Actions:**

 1. **Token Existence & Ownership**: Verifies the `tokenId` exists and is owned by the user.
 2. **Staking Status**: Checks if the NFT is not already staked.
 3. **Fee Payment**: Ensures the transaction includes sufficient fees (`_feeAmount`).
 4. **Period Validity**: Validates the chosen `period` is one of the accepted durations.
 5. **Lock NFT**: Transfers NFT ownership to the contract and updates the user's staking data (start time and period).

#### **Step 3: Calculating Staking Points**

* **Trigger:** Occurs when a user checks their staking points.
* **Calculation Basis:**
  * **Reward Rate**: The contract's set `_rewardRate`.
  * **Staking Duration**: The time elapsed since the NFT was locked until the current block height.
* **Points Calculation:**
  * `points = (currentBlockHeight - lockBlockHeight) * rewardRate`

#### **Step 4: Error Handling**

* **Scenarios:**
  * Attempting to lock a non-existent, already staked, or non-owned NFT.
  * Insufficient fees or invalid period selection.
  * System errors during points calculation (e.g., invalid period for calculation).
* **Response:** Throws specific, informative errors for each scenario to guide user correction.

#### **Step 5: Deployment and Usage**

* **Pre-deployment:**
  * Full implementation and testing of the feature.
  * Review and approval by the product owner.
  * QA validation.
* **Post-deployment:**
  * The feature is live and accessible to users.
  * Comprehensive documentation (user and technical) is available.
