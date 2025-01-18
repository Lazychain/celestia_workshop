// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title Staking Contract
 * @author [Your Name]
 * @notice This contract allows users to stake their NFTs and earn rewards.
 * @dev This contract uses the ERC721 standard for NFTs and has a reward system based on block numbers.
 */

interface IStaking {
    // Events
    event LockNFTSuccess();
    event UnlockNFTSuccess();
    event RecoverNFTSuccess();
    event ConsumeRewardsSuccess();

    // Enum for periods (copied from the original contract for clarity)
    enum Period {
        ONE_DAY,
        SEVEN_DAYS,
        TWENTY_ONE_DAYS
    }

    // Errors
    error InvalidRewardRate();
    error MissingNftAddress();
    error NotYourNFTToken();
    error InsufficientFundsSent();

    error NotInWhitelist();
    error InsuficientRewardsPoints();

    error AlreadyLocked();
    error NFTNotLocked();
    error NFTPeriodNotReady();

    // Functions
    function lock(uint256 _tokenId, Period _period) external payable;
    function unlock(uint256 _tokenId) external payable;
    function consumeRewards(address user, uint256 _points) external payable;

    // Admin/Restricted Functions (assuming only admins can manage the whitelist)
    function addToWhitelist(address _address) external;
    function removeFromWhitelist(address _address) external;

    // View/Getter Functions (added for convenience and off-chain usage)
    function rewardRate() external view returns (uint256);
    function fees() external view returns (uint256);
    function lockHeights(Period _period) external view returns (uint256);
    function users(
        address _user,
        uint256 _tokenId
    ) external view returns (uint256 startHeight, uint256 endHeight);
    function rewards(address _user) external view returns (uint256);
    function whitelist(address _address) external view returns (bool);
    function isWhitelisted(address _address) external view returns (bool);
}
