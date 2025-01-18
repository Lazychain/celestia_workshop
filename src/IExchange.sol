// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title Exchange Contract Interface
 * @author [Your Name]
 * @notice This contract allows users to exchange rewards for ERC20 Tokens.
 * @dev This contract assumes an ERC20 interface for Token interactions.
 */

interface IExchange {
    // Events
    event ExchangeRewardsSuccess();

    // Errors
    error InvalidFees();
    error TokenAddressCannotBeZero();
    error StakeAddressCannotBeZero();
    error InsuficientFundsSent();
    error InsuficientPointsToExchange();
    error InsuficientTokensToExchange();
    error NotInWhitelist();

    // Function Signatures
    function exchangeRewards(address _user, uint256 _points) external payable;

    // Getter Functions
    function getExchangeFees() external view returns (uint256);
    function getStakingFees() external view returns (uint256);
}