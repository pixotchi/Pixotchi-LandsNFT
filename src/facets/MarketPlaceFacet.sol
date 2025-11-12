// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../shared/Structs.sol";
import {NFTModifiers} from "../libs/LibNFT.sol";
import {LibMarketPlace} from "../libs/LibMarketPlace.sol";
import {LibMarketPlaceStorage} from "../libs/LibMarketPlaceStorage.sol";
import {AccessControl2} from "../libs/libAccessControl2.sol";
import {LibXP} from "../libs/LibXP.sol";

contract MarketPlaceFacet is AccessControl2 {

    function marketPlaceIsActive() external view returns (bool) {
        return LibMarketPlace._isActive();
    }
    //using LibMarketPlace for *;

    // Events
    // event OrderCreated(
    //     uint256 orderId,
    //     address seller,
    //     LibMarketPlaceStorage.TokenType sellToken,
    //     uint256 amount
    // );
    // event OrderTaken(uint256 orderId, address buyer);

    // Create order
    function marketPlaceCreateOrder(
        uint256 landId,
        uint8 sellToken,
        uint256 amount,
        uint256 amountAsk
    ) external
    isApproved(landId)
    {
        LibMarketPlaceStorage.TokenType sellTokenEnum = sellToken == 0 
            ? LibMarketPlaceStorage.TokenType.A 
            : LibMarketPlaceStorage.TokenType.B;
        LibMarketPlace.createOrder(landId, sellTokenEnum, amount, amountAsk);
    }

    // Take order
    function marketPlaceTakeOrder(uint256 landId, uint256 orderId) isApproved(landId) external {
        (uint256 xpSeller, uint256 xpBuyer, uint256 landIdSeller) = LibMarketPlace.takeOrder(landId, orderId);
        LibXP.pushExperiencePoints(landId, xpBuyer);
        LibXP.pushExperiencePoints(landIdSeller, xpSeller);
    }

    // Cancel order
    function marketPlaceCancelOrder(uint256 landId, uint256 orderId) isApproved(landId) external {
        LibMarketPlace.cancelOrder(landId, orderId);
    }

    // View all active orders
    function marketPlaceGetActiveOrders() external view returns (MarketPlaceOrderView[] memory) {
        return LibMarketPlace.getActiveOrders();
    }

    // View user's orders
    function marketPlaceGetUserOrders(address user) external view returns (MarketPlaceOrderView[] memory) {
        return LibMarketPlace.getUserOrders(user);
    }

    // Getter for all inactive orders
    function marketPlaceGetInactiveOrders() external view returns (MarketPlaceOrderView[] memory) {
        return LibMarketPlace.getInactiveOrders();
    }
}

