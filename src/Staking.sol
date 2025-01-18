// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title Staking Contract
 * @author [Your Name]
 * @notice This contract allows users to stake their NFTs and earn rewards.
 * @dev This contract uses the ERC721 standard for NFTs and has a reward system based on block numbers.
 */

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Lazy721} from "./Lazy721.sol";
import {IStaking} from "./IStaking.sol";
import {console} from "forge-std/console.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Staking contract.
 */
contract Staking is IStaking, ERC721Holder, Ownable {
    /**
     * @notice The address of the ERC721 contract.
     */
    IERC721 private nft;
    /**
     * @notice The reward rate per block.
     */
    uint256 public rewardRate;
    /**
     * @notice The fees for staking, unstaking, and recovering NFTs.
     */
    uint256 public fees;

    // mapping of enum to corresponding block height
    mapping(Period => uint256) public lockHeights;

    /**
     * @dev Struct for token data.
     * @notice This struct stores information about a user's staked token.
     */
    struct StakeInfo {
        /**
         * @notice The starting height of the token.
         */
        uint256 startHeight;
        /**
         * @notice The ending height of the token.
         */
        uint256 endHeight;
    }

    /**
     * @notice Mapping of users to their staking data.
     */
    mapping(address => mapping(uint256 => StakeInfo)) public users;

    /**
     * @notice Mapping of users rewards.
     */
    mapping(address => uint256) public rewards;

    /**
     * @notice Mapping of addresses to their whitelist status.
     */
    mapping(address => bool) public whitelist;

    /**
     * @dev Constructor for the contract.
     * @param _nftAddress The address of the ERC721 contract.
     * @param _rewardRate The reward rate per block.
     * @param _feeAmount The fees for staking, unstaking, and recovering NFTs.
     */
    constructor(
        address _nftAddress,
        uint256 _rewardRate,
        uint256 _feeAmount
    ) Ownable(msg.sender) {}

    /**
     * @dev Function to start staking an NFT.
     * @param _tokenId The ID of the NFT to stake.
     */
    function lock(uint256 _tokenId, Period _period) public payable {}

    /**
     * @dev Function to recover an NFT.
     * @param _tokenId The ID of the NFT to recover.
     */
    function unlock(uint256 _tokenId) public payable {}

    /**
     * @dev Function to consume rewards.
     * @param _points The number of rewards points to consume.
     */
    function consumeRewards(address user, uint256 _points) public payable {
        user;
        _points;
        emit ConsumeRewardsSuccess();
    }

    /**
     * @dev Function to add an address to the whitelist.
     * @param _address The address to add to the whitelist.
     */
    function addToWhitelist(address _address) public onlyOwner {
        whitelist[_address] = true;
    }

    /**
     * @dev Function to remove an address from the whitelist.
     * @param _address The address to remove from the whitelist.
     */
    function removeFromWhitelist(address _address) public onlyOwner {
        whitelist[_address] = false;
    }

    function isWhitelisted(address _address) external view returns (bool) {
        return whitelist[_address];
    }
}
