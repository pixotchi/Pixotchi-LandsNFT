// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "../shared/Structs.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Burnable} from "../interfaces/IERC20Burnable.sol";

import "./LibConstants.sol";

/// @title LibPayment
/// @notice A library for managing payment-related operations in the Pixotchi game
library LibPayment {

    // Custom errors
    error AmountMustBeGreaterThanZero();
    error InsufficientBalance();
    error InsufficientAllowance();

    /// @notice Pays with Seed token
    /// @param from The address to transfer the tokens from
    /// @param amount The amount of tokens to transfer
    function paymentPayWithSeed(address from, uint256 amount) internal {
        address tokenAddress = LibConstants.paymentGetSeedToken();
        address receiveAddress = LibConstants.paymentGetSeedReceiveAddress();

        _paymentExecute(from, amount, tokenAddress, receiveAddress);
    }

    /// @notice Pays with Leaf token
    /// @param from The address to transfer the tokens from
    /// @param amount The amount of tokens to transfer
    function paymentPayWithLeaf(address from, uint256 amount) internal {
        address tokenAddress = LibConstants.paymentGetLeafToken();
        address receiveAddress = LibConstants.paymentGetLeafReceiveAddress();

        _paymentExecute(from, amount, tokenAddress, receiveAddress);
    }

    /// @notice Executes the payment
    /// @param from The address to transfer the tokens from
    /// @param amount The amount of tokens to transfer
    /// @param tokenAddress The address of the token to use for payment
    /// @param receiveAddress The address to receive the payment
    function _paymentExecute(address from, uint256 amount, address tokenAddress, address receiveAddress) private {
        // Checks
        if (amount <= 0) revert AmountMustBeGreaterThanZero();
        if (IERC20(tokenAddress).balanceOf(from) < amount) revert InsufficientBalance();
        if (IERC20(tokenAddress).allowance(from, address(this)) < amount) revert InsufficientAllowance();

        // Effects
        // No state variables to update in this case

        // Interactions
        if(receiveAddress == address(0)) {
            IERC20Burnable(tokenAddress).burnFrom(from, amount);
            //SafeERC20.safeTransferFrom(IERC20(tokenAddress), from, address(this), amount);
            //IERC20Burnable(tokenAddress).burn(amount);
        } else {
            SafeERC20.safeTransferFrom(IERC20(tokenAddress), from, receiveAddress, amount);
        }
    }

    /// @notice Rewards with Leaf token
    /// @param to The address to receive the tokens
    /// @param amount The amount of tokens to transfer
    function rewardWithLeaf(address to, uint256 amount) internal {
        address tokenAddress = LibConstants.paymentGetLeafToken();
        address fromAddress = LibConstants.rewardGetLeafToken();

        _rewardExecute(fromAddress, to, amount, tokenAddress);
    }

    /// @notice Rewards with Seed token
    /// @param to The address to receive the tokens
    /// @param amount The amount of tokens to transfer
    function rewardWithSeed(address to, uint256 amount) internal {
        address tokenAddress = LibConstants.paymentGetSeedToken();
        address fromAddress = LibConstants.rewardGetSeedToken();

        _rewardExecute(fromAddress, to, amount, tokenAddress);
    }

    /// @notice Executes the reward transfer
    /// @param from The address to transfer the tokens from
    /// @param to The address to receive the tokens
    /// @param amount The amount of tokens to transfer
    /// @param tokenAddress The address of the token to use for the reward
    function _rewardExecute(address from, address to, uint256 amount, address tokenAddress) private {
        // Checks
        if (amount <= 0) revert AmountMustBeGreaterThanZero();
        if (IERC20(tokenAddress).balanceOf(from) < amount) revert InsufficientBalance();

        // Effects
        // No state variables to update in this case

        // Interactions
        SafeERC20.safeTransferFrom(IERC20(tokenAddress), from, to, amount);
    }
}
