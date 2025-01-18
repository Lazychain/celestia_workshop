# Design Specifications

## NFT Locking and Reward System

- The `NFT Locking` contract is the responsible for:
  - Ownership the `ERC721` on `lockNFT` until users `unlockNFT` and `recoverNFT` them.
  - Keep track of `rewards` according to the `lockNFT` block height and `unlockNFT` block height.
  - Define the `rewardRate` earn by emitted block.
- The `Exchange` contract is the responsible for:
  - Allow users to exchange `rewards` points for `ERC20` tokens contract according to a ratio.

```mermaid
---
title: Contracts
---
graph LR
    C(User)
    A(contract)
    E(contract)
    D(Points)
    F(contract)
    G(contract)

    subgraph ERC20
        F
    end

    subgraph ERC721
        G
    end

    subgraph Exchange
        E
    end

    subgraph Staking
        A
        D

        A -- Store Points --> D
    end

    C -- ownership --> G
    G <-- change --> A 
    C -- Lock ERC721 --> A
    C -- unlock ERC721 --> A

    C -- exchange ERC-20 --> E
    E -- consume --> D
    E -- TransferTo --> F
    F -- Transfer ERC-20 --> C
```

### Class Diagram

```mermaid
---
title: Staking Contract
---
%%{init: {'theme': 'base', 'themeVariables': { 'primaryBorderColor': 'green', 'background': 'yellow'}}}%%
classDiagram
    class StakingContract {
        - address nft
        - number rewardRate
        - number fees
        - Map~address => Map~number => StakeInfo~~ users
        - Map~address => number~ rewards
        - Map~address => bool~ whitelist
        - Map~Period => number~ lockHeights
        
        + constructor(nftAddress: address, rewardRate: number, feeAmount: number)
        + startStaking(tokenId: number, period: Period) 
        + stopStaking(tokenId: number) 
        + recoverNFT(tokenId: number)
        + consumeRewards(points: number) 
        + addToWhitelist(address: address)
        + removeFromWhitelist(address: address)
    }
    
    class StakeInfo {
        - number startHeight
        - number endHeight
    }
    
    class Period{
      <<enumeration>>
        ONE_DAY
        SEVEN_DAYS
        TWENTY_ONE_DAYS
    }

    class IERC721 {
      <<interface>>
      + number tokenId
      + safeTransferFrom(from: address, to: address, tokenId: number)
      + balanceOf(user: address)
      + ownerOf(tokenId: number)
    }

    class Errors{
      <<enumeration>>
      InvalidRewardRate
      MissingNftAddress
      AlreadyLocked
      NotYourNFTToken
      InsufficientFundsSent
      NFTNotLocked
      NFTPeriodNotReady
      NotInWhitelist
      InsuficientRewardsPoints
    }
    
    StakingContract *-- IERC721 : "nft"
    StakingContract *--* StakeInfo : "users"
    StakingContract *-- Errors : "errors"
    StakeInfo *-- Period : "locked period"
    Period *-- lockHeights : "cache"
```
