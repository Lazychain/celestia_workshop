// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

/**
 * @title Exchange Contract
 * @author [Your Name]
 * @notice This contract allows users to exchange rewrds for ERC20 Tokens.
 * @dev This contract assumes an ERC20 interface for Token interactions.
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStaking} from "./IStaking.sol";
import {IExchange} from "./IExchange.sol";
import {Lazy20} from "./Lazy20.sol";
import {Staking} from "./Staking.sol";

contract Exchange is IExchange {
    // State Variables
    Staking public staking; // Represents the Staking contract address
    Lazy20 public token; // Represents the ERC20 token address
    uint256 public fees; // Fees for exchanging rewards
    uint256 public staking_fees; // Fees for exchanging rewards

    // Constructor
    constructor(address _staking, address _token, uint256 _feeAmount) {}

    // Function to exchange rewards for ERC20 tokens
    function exchangeRewards(address _user, uint256 _points) public payable {
        _user;
        _points;
        // Emit success event
        emit ExchangeRewardsSuccess();
    }

    function getExchangeFees() external view returns (uint256) {
        return fees;
    }

    function getStakingFees() external view returns (uint256) {
        return staking_fees;
    }
}
