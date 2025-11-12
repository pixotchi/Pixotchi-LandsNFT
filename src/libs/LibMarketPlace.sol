// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../shared/Structs.sol";
import "./LibMarketPlaceStorage.sol";
import "./LibTown.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./LibTown.sol";
import {LibConstants} from "./LibConstants.sol";


library LibMarketPlace {

    function _getMarketPlaceLevel(uint256 landId) private view returns (uint256) {
        return LibTown.getBuildingLevel(landId, LibTownStorage.TownBuildingNaming.MARKET_PLACE);
    }

    function _sM() internal pure returns (LibMarketPlaceStorage.Data storage data) {
        data = LibMarketPlaceStorage.data();
    }

    // Modifiers
    modifier marketPlaceExists(uint256 landId) {
        require(_getMarketPlaceLevel(landId) >= 1,"market place doesnt exist");
        _;
    }


    modifier isActive() {
        require(_isActive(), "marketplace is not active");
        _;
    }

    // Modifiers
    modifier orderExists(uint256 orderId) {
        require(_sM().orders[orderId].amount >= 0, "Order amount must be greater than 0");
        _;
    }

    modifier orderActive(uint256 orderId) {
        require(_sM().orders[orderId].isActive, "Order is not active");
        _;
    }

    modifier sufficientBalance(LibMarketPlaceStorage.TokenType tokenType, uint256 amount) {
        IERC20 token = tokenType == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;
        require(token.balanceOf(msg.sender) >= amount, "Insufficient balance");
        _;
    }

    modifier sufficientAllowance(LibMarketPlaceStorage.TokenType tokenType, uint256 amount) {
        IERC20 token = tokenType == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;
        require(token.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
        _;
    }
    modifier sufficientAmount(/*LibMarketPlaceStorage.TokenType tokenType, */uint256 amount) {
        //IERC20 token = tokenType == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;
        require(amount >= 0, "Insufficient amount");
        _;
    }



    //IERC20 public constant TOKEN_A_TESTNET = IERC20(0xc64F740D216B6ec49e435a8a08132529788e8DD0);
    //IERC20 public constant TOKEN_B_TESTNET = IERC20(0x33feeD5a3eD803dc03BBF4B6041bB2b86FACD6C4);
    IERC20 public constant TOKEN_A = IERC20(0x546D239032b24eCEEE0cb05c92FC39090846adc7); //SEED
    IERC20 public constant TOKEN_B = IERC20(0xE78ee52349D7b031E2A6633E07c037C3147DB116); //LEAF

    using SafeERC20 for IERC20;

    //using LibMarketPlaceStorage for LibMarketPlaceStorage.Storage;

    // Events
    event OrderCreated(
        uint256 orderId,
        address seller,
        LibMarketPlaceStorage.TokenType sellToken,
        uint256 amount,
        uint256 amountAsk
    );
    event OrderTaken(uint256 orderId, address buyer);
    event OrderCancelled(uint256 orderId, address seller); // New event

    // Create order
    function createOrder(
        uint256 landId,
        LibMarketPlaceStorage.TokenType sellToken,
        uint256 amount,
        uint256 amountAsk
    ) internal
    sufficientBalance(sellToken, amount)
    sufficientAllowance(sellToken, amount)
    //sufficientAmount(/*sellToken, */amount)
    marketPlaceExists(landId)
    isActive
    {
        require(amount >= 0, "Insufficient amount");
        require(amountAsk >= 0, "Insufficient amount");

        uint256 orderId = _saveOrder(sellToken, amount, amountAsk, landId);
        _transferTokensToContract(sellToken, amount);

        emit OrderCreated(
            orderId,
            msg.sender,
            sellToken,
            amount,
            amountAsk
        );
    }

    function _transferTokensToContract(LibMarketPlaceStorage.TokenType sellToken, uint256 amount) private {
        IERC20 token = sellToken == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;
        //require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        address from = LibConstants.getMarketplaceExchangeAddress();
        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, from, amount);
    }

    function _saveOrder(LibMarketPlaceStorage.TokenType sellToken, uint256 amount, uint256 amountAsk, uint256 landId) private returns (uint256) {
        uint256 orderId = _sM().nextOrderId;
        _sM().orders[orderId] = LibMarketPlaceStorage.Order({
            seller: msg.sender,
            sellToken: sellToken,
            amount: amount,
            amountAsk: amountAsk,
            isActive: true,
            sellerLandId: landId
        });

        _sM().nextOrderId += 1;
        _sM().userOrders[msg.sender].push(orderId);

        return orderId;
    }

    // Take order
    function takeOrder(uint256 landId, uint256 orderId)
    internal
    orderExists(orderId)
    orderActive(orderId)
    marketPlaceExists(landId)
    //TODO: add check for amountAsk
    isActive
    returns (uint256 xpSeller, uint256 xpBuyer, uint256 landIdSeller)
    {

        LibMarketPlaceStorage.Order storage order = _sM().orders[orderId];

        require(msg.sender != order.seller, "msg.sender cant be same as order.seller");


        LibMarketPlaceStorage.TokenType sellTokenType = order.sellToken;
        LibMarketPlaceStorage.TokenType buyTokenType = sellTokenType ==
        LibMarketPlaceStorage.TokenType.A
            ? LibMarketPlaceStorage.TokenType.B
            : LibMarketPlaceStorage.TokenType.A;

        IERC20 buyToken = buyTokenType == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;
        IERC20 sellToken = sellTokenType == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;
        //IERC20 buyToken =  sellTokenType == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;
        //IERC20 sellToken = buyTokenType == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;

        uint256 amount = order.amount;
        uint amountAsk = order.amountAsk;


        require(
            buyToken.balanceOf(msg.sender) >= amountAsk,
            "Insufficient balance to buy"
        );

        require(
            buyToken.allowance(msg.sender, address(this)) >= amountAsk,
            "Insufficient allowance to buy"
        );

        // Mark order as inactive
        order.isActive = false;

        xpSeller = 1 ether; //TODO calculate dynamic
        xpBuyer = 1 ether; //TODO calculate dynamic
        landIdSeller = order.sellerLandId;

        address exchangeAddress = LibConstants.getMarketplaceExchangeAddress();


//        // Transfer buyToken from buyer to seller
//        require(
//            buyToken.transferFrom(
//                msg.sender,
//                order.seller,
//                amountAsk
//            ),
//            "Transfer failed"
//        );
        // Transfer buyToken from buyer to exchangeAddress
        require(
            buyToken.transferFrom(
                msg.sender,
                exchangeAddress,
                amountAsk
            ),
            "TX buyToken from buyer to exchangeAddress failed"
        );
        // Transfer buyToken from exchangeAddress to seller
        require(
            buyToken.transferFrom(
                exchangeAddress,
                order.seller,
                amountAsk
            ),
            "TX buyToken from exchangeAddress to seller failed"
        );


        // Transfer sellToken from contract to buyer
        require(
            sellToken.transferFrom(exchangeAddress, msg.sender, amount),
            "TX sellToken from contract to buyer failed"
        );



        // Emit event
        emit OrderTaken(orderId, msg.sender);



        return (xpSeller, xpBuyer, landIdSeller);
    }

    // Cancel order
    function cancelOrder(uint256 landId, uint256 orderId) internal
    orderExists(orderId)
    orderActive(orderId)
    marketPlaceExists(landId)
    isActive
    {
        LibMarketPlaceStorage.Order storage order = _sM().orders[orderId];
        require(order.seller == msg.sender, "Only the seller can cancel the order");

        // Mark order as inactive
        order.isActive = false;

        // Determine the token to refund
        IERC20 token = order.sellToken == LibMarketPlaceStorage.TokenType.A ? TOKEN_A : TOKEN_B;

        // Transfer tokens back to the seller
        //require(token.transfer(msg.sender, order.amount), "Refund transfer failed");
        address from = LibConstants.getMarketplaceExchangeAddress();
        require(token.transferFrom(from, msg.sender, order.amount), "Refund transfer failed");

        // Emit event
        emit OrderCancelled(orderId, msg.sender);
    }

    // View all active orders
    function getActiveOrders() internal view returns (MarketPlaceOrderView[] memory) {
        uint256 totalOrders = _sM().nextOrderId;
        uint256 activeCount = 0;
        uint256[] memory activeOrderIds = new uint256[](totalOrders);

        // First pass: count active orders and store their IDs
        for (uint256 i = 0; i < totalOrders; i++) {
            if (_sM().orders[i].isActive) {
                activeOrderIds[activeCount] = i;
                activeCount++;
            }
        }

        // Create an array of active orders with the exact size needed
        MarketPlaceOrderView[] memory activeOrders = new MarketPlaceOrderView[](activeCount);

        // Second pass: populate the activeOrders array
        for (uint256 i = 0; i < activeCount; i++) {
            uint256 orderId = activeOrderIds[i];
            LibMarketPlaceStorage.Order storage order = _sM().orders[orderId];
            activeOrders[i] = MarketPlaceOrderView({
                id: orderId,
                seller: order.seller,
                sellToken: uint8(order.sellToken),
                amount: order.amount,
                isActive: order.isActive,
                amountAsk: order.amountAsk
            });
        }

        return activeOrders;
    }

    // View user's orders
    function getUserOrders(
        address user
    ) internal view returns (MarketPlaceOrderView[] memory) {
        uint256[] storage userOrderIds = _sM().userOrders[user];
        uint256 totalOrders = userOrderIds.length;
        MarketPlaceOrderView[] memory userOrderList = new MarketPlaceOrderView[](totalOrders);

        for (uint256 i = 0; i < totalOrders; i++) {
            uint256 orderId = userOrderIds[i];
            LibMarketPlaceStorage.Order storage order = _sM().orders[orderId];
            userOrderList[i] = MarketPlaceOrderView({
                id: orderId,
                seller: order.seller,
                sellToken: uint8(order.sellToken),
                amount: order.amount,
                isActive: order.isActive,
                amountAsk: order.amountAsk
            });
        }

        return userOrderList;
    }



    // Getter for all inactive orders
    function getInactiveOrders() internal view returns (MarketPlaceOrderView[] memory) {
        uint256 totalOrders = _sM().nextOrderId;
        uint256 inactiveCount = 0;

        // Determine the number of inactive orders
        for (uint256 i = 0; i < totalOrders; i++) {
            if (!_sM().orders[i].isActive) {
                inactiveCount += 1;
            }
        }

        // Create an array of inactive orders
        MarketPlaceOrderView[] memory inactiveOrders = new MarketPlaceOrderView[](inactiveCount);
        uint256 index = 0;
        for (uint256 i = 0; i < totalOrders; i++) {
            if (!_sM().orders[i].isActive) {
                LibMarketPlaceStorage.Order storage order = _sM().orders[i];
                inactiveOrders[index] = MarketPlaceOrderView({
                    id: i,
                    seller: order.seller,
                    sellToken: uint8(order.sellToken),
                    amount: order.amount,
                    isActive: order.isActive,
                    amountAsk: order.amountAsk
                });
                index += 1;
            }
        }

        return inactiveOrders;
    }

    function _isActive() internal view returns (bool) {
        return _sM().enabled;
    }
}
