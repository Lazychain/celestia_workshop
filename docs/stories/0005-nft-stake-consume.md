# 5. User NFT Recover Flow

```mermaid
---
title: Contract NFT Consume Rewards Flow
---
graph LR
A[Contract initiates action] --> B[Is sender contract in whitelist?]
B -- |no| --> C[Throw NotInWhitelist error]
B -- |yes| --> E[Are funds sent sufficient?]
E -- |no| --> F[Throw InsuficientFundsSent error]

E -- |yes| --> L[Does user exist?]
L -- |no| --> M[Throw UserDoesNotExist error]
L -- |yes| --> N[Get rewards balance]
N -- |yes| --> G[Does user have sufficient rewards balance?]
G -- |no| --> H[Throw InsuficientRewardsPoints error]
G -- |yes| --> I[Subtract points from user rewards]
I -- |emits ConsumeRewardsSuccess event| --> J[Consume rewards successful]
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
error ClaimNotReady(); // thrown when (block.number - (stop + period)) blocks is less than 0
error Unauthorized(); // thrown when has no enough access permissions
error InvalidPeriod(); // thrown when the staking period is not valid enumerate option
error AlreadyStaked(); // thrown when attempting to start staking for a token already staked
error NFTNotStaked(); // thrown when attempting to stop staking for a token not staked by the user
error UserDoesNotExist(); // thrown when the user is not in `users` Map.
error NotInWhitelist(); // thrown when `address` not in the array.
error InsuficientRewardsPoints(); // thrown when insufficient rewards points to be consumed.
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
// --- Execute: consumeRewards ---
/**
 * @dev Consume rewards
 * @param points Number of points to consume
 */
function consumeRewards(uint256 points) public payable {
    // - Check if `msg.value >= fees`
    //   - Throw error `InsuficientFundsSent`
    // Check if `msg.sender` is on whitelist
    //   - Throw error `NotInWhitelist`
    // Check if user has sufficient rewards balance
    //   - Throw error InsuficientRewardsPoints
    // Subtract points from user rewards
    // emit event ConsumeRewardsSuccess
}
```

```solidity
// --- Query: rewardsBalance ---
/**
 * @dev Get rewards balance
 * @param user User address
 * @return Rewards balance
 */
function rewardsBalance(address user) public view returns (uint256) {
    // Check if `user` exist
    //  - Throw UserDoesNotExist
    // Return `user.rewards`
}
```

## User scenarios

```gherkin
Feature: Consume Rewards
  Scenario: User consumes rewards
    Given the user has a rewards balance
    And the user is on the whitelist
    When the user consumes their rewards
    Then the user's rewards balance is updated
    And the ConsumeRewardsSuccess event is emitted
  Scenario: User attempts to consume rewards with insufficient balance
    Given the user does not have a sufficient rewards balance
    When the user attempts to consume their rewards
    Then an InsuficientRewardsPoints error is thrown
  Scenario: User attempts to consume rewards when not on the whitelist
    Given the user is not on the whitelist
    When the user attempts to consume their rewards
    Then a NotInWhitelist error is thrown
  Scenario: User attempts to consume rewards with insufficient funds sent
    Given the user does not send sufficient funds
    When the user attempts to consume their rewards
    Then an InsuficientFundsSent error is thrown
```

### Acceptance Criteria

* The user can consume their rewards when they have a sufficient balance and are on the whitelist.
* The user is prevented from consuming rewards when they don't have a sufficient balance.
* The user is prevented from consuming rewards when they're not on the whitelist.
* The user is prevented from consuming rewards when they don't send enough funds.

### Test Data Requirements

* User with a rewards balance
* User not on the whitelist
* User with insufficient rewards balance
* User sending insufficient funds

### Definition of Done (DoD)

* The ConsumeRewardsSuccess event is emitted when the user consumes their rewards.
* An InsuficientRewardsPoints error is thrown when the user attempts to consume rewards with insufficient balance.
* A NotInWhitelist error is thrown when the user attempts to consume rewards when not on the whitelist.
* An InsuficientFundsSent error is thrown when the user attempts to consume rewards with insufficient funds sent.
