// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library LibConstants {

    uint256 internal constant BLOCK_TIME = 2; //2 seconds

    // Constants for token addresses
    address internal constant TESTNET_SEED_TOKEN = address(0xc64F740D216B6ec49e435a8a08132529788e8DD0);
    address internal constant TESTNET_LEAF_TOKEN = address(0x33feeD5a3eD803dc03BBF4B6041bB2b86FACD6C4);
    address internal constant MAINNET_SEED_TOKEN = address(0x546D239032b24eCEEE0cb05c92FC39090846adc7);
    address internal constant MAINNET_LEAF_TOKEN = address(0xE78ee52349D7b031E2A6633E07c037C3147DB116);

    // Constants for receive addresses
    address internal constant TESTNET_SEED_RECEIVE_ADDRESS = address(0x1b6742E960d77F416D1b14F1f837523103CAccB4);
    //address internal constant TESTNET_LEAF_RECEIVE_ADDRESS = address(0x1b6742E960d77F416D1b14F1f837523103CAccB4);
    address internal constant TESTNET_LEAF_RECEIVE_ADDRESS = address(0x0000000000000000000000000000000000000000);

    address internal constant MAINNET_SEED_RECEIVE_ADDRESS = address(0x2673b40F0ff6428BBEA795782603E823DF9E1c57);
    //address internal constant MAINNET_LEAF_RECEIVE_ADDRESS = address(0x2673b40F0ff6428BBEA795782603E823DF9E1c57);
    address internal constant MAINNET_LEAF_RECEIVE_ADDRESS = address(0x0000000000000000000000000000000000000000);

    // Constants for receive addresses
    address internal constant TESTNET_SEED_SEND_ADDRESS = address(0x1b6742E960d77F416D1b14F1f837523103CAccB4);
    address internal constant TESTNET_LEAF_SEND_ADDRESS = address(0x1b6742E960d77F416D1b14F1f837523103CAccB4);
    address internal constant MAINNET_SEED_SEND_ADDRESS = address(0xd528071FB9dC9715ea8da44e2c4433EAc017d1DB);
    address internal constant MAINNET_LEAF_SEND_ADDRESS = address(0xd528071FB9dC9715ea8da44e2c4433EAc017d1DB);

    // Constants for marketplace exchange addresses
    address internal constant TESTNET_MARKETPLACE_EXCHANGE_ADDRESS = address(0xB9447202432ae9a4511cC33a14453A5A4968e0FC); // TODO: Update with actual address
    //address internal constant TESTNET_MARKETPLACE_LEAF_EXCHANGE_ADDRESS = address(0x0000000000000000000000000000000000000000); // TODO: Update with actual address
    address internal constant MAINNET_MARKETPLACE_EXCHANGE_ADDRESS = address(0xB9447202432ae9a4511cC33a14453A5A4968e0FC); // TODO: Update with actual address
    //address internal constant MAINNET_MARKETPLACE_LEAF_EXCHANGE_ADDRESS = address(0x0000000000000000000000000000000000000000); // TODO: Update with actual address


    // Constants for chain IDs
    uint256 internal constant TESTNET_CHAIN_ID = 84532;
    uint256 internal constant MAINNET_CHAIN_ID = 8453;

    // New constant for plant point decimals
    uint256 internal constant PLANT_POINT_DECIMALS = 12;

    uint256 internal constant XP_DECIMALS = 18; // 1 ether; // 1e18

    // error UnsupportedNetwork(); // Commented out

    /// @notice Get the seed token address based on the network
    /// @return The address of the seed token for the current network
    function paymentGetSeedToken() internal view returns (address) {
        if (block.chainid == MAINNET_CHAIN_ID) { // Mainnet chain ID
            return MAINNET_SEED_TOKEN;
        } else {
            return TESTNET_SEED_TOKEN; // Use testnet for all other chain IDs
        }
        // else {
        //     revert UnsupportedNetwork();
        // }
    }

    /// @notice Get the leaf token address based on the network
    /// @return The address of the leaf token for the current network
    function paymentGetLeafToken() internal view returns (address) {
        if (block.chainid == MAINNET_CHAIN_ID) { // Mainnet chain ID
            return MAINNET_LEAF_TOKEN;
        } else {
            return TESTNET_LEAF_TOKEN; // Use testnet for all other chain IDs
        }
        // else {
        //     revert UnsupportedNetwork();
        // }
    }

    /// @notice Get the seed receive address based on the network
    /// @return The seed receive address for the current network
    function paymentGetSeedReceiveAddress() internal view returns (address) {
        if (block.chainid == MAINNET_CHAIN_ID) { // Mainnet chain ID
            return MAINNET_SEED_RECEIVE_ADDRESS;
        } else {
            return TESTNET_SEED_RECEIVE_ADDRESS; // Use testnet for all other chain IDs
        }
        // else {
        //     revert UnsupportedNetwork();
        // }
    }

    /// @notice Get the leaf receive address based on the network
    /// @return The leaf receive address for the current network
    function paymentGetLeafReceiveAddress() internal view returns (address) {
        if (block.chainid == MAINNET_CHAIN_ID) { // Mainnet chain ID
            return MAINNET_LEAF_RECEIVE_ADDRESS;
        } else {
            return TESTNET_LEAF_RECEIVE_ADDRESS; // Use testnet for all other chain IDs
        }
        // else {
        //     revert UnsupportedNetwork();
        // }
    }

    /// @notice Get the seed token address for rewards based on the network
    /// @return The address of the seed token for rewards on the current network
    function rewardGetSeedToken() internal view returns (address) {
        if (block.chainid == MAINNET_CHAIN_ID) {
            return MAINNET_SEED_SEND_ADDRESS;
        } else {
            return TESTNET_SEED_SEND_ADDRESS; // Use testnet for all other chain IDs
        }
    }

    /// @notice Get the leaf token address for rewards based on the network
    /// @return The address of the leaf token for rewards on the current network
    function rewardGetLeafToken() internal view returns (address) {
        if (block.chainid == MAINNET_CHAIN_ID) {
            return MAINNET_LEAF_SEND_ADDRESS;
        } else {
            return TESTNET_LEAF_SEND_ADDRESS; // Use testnet for all other chain IDs
        }
    }


    /// @notice Get the marketplace exchange address based on the network
    /// @return The marketplace exchange address for the current network
    function getMarketplaceExchangeAddress() internal view returns (address) {
        if (block.chainid == MAINNET_CHAIN_ID) {
            return MAINNET_MARKETPLACE_EXCHANGE_ADDRESS;
        } else {
            return TESTNET_MARKETPLACE_EXCHANGE_ADDRESS; // Use testnet for all other chain IDs
        }
    }

/*    /// @notice Get the marketplace leaf exchange address based on the network
    /// @return The marketplace leaf exchange address for the current network
    function getMarketplaceLeafExchangeAddress() internal view returns (address) {
        if (block.chainid == MAINNET_CHAIN_ID) {
            return MAINNET_MARKETPLACE_LEAF_EXCHANGE_ADDRESS;
        } else {
            return TESTNET_MARKETPLACE_LEAF_EXCHANGE_ADDRESS; // Use testnet for all other chain IDs
        }
    }*/

  function hoursToBlocks(uint256 _hours) internal pure returns (uint256) {
    return (_hours * 3600) / BLOCK_TIME;
  }

    function minutesToBlocks(uint256 _minutes) internal pure returns (uint256) {
        return (_minutes * 60) / BLOCK_TIME;
    }
}
