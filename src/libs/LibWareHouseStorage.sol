//// SPDX-License-Identifier: MIT
//pragma solidity >=0.8.21;
//
///// @title LibLandStorage
///// @notice Library for managing LAND storage in the Pixotchi game
///// @dev This library provides functions and structures for LAND-related data storage
//library LibWareHouseStorage {
//    bytes32 internal constant DIAMOND_STORAGE_POSITION = keccak256("eth.pixotchi.land.warehouse.storage");
//
//    /// @notice Returns the diamond storage for LAND-related data
//    /// @return ds The LANDStorage struct
//    function data() internal pure returns (Data storage ds) {
//        bytes32 position = DIAMOND_STORAGE_POSITION;
//        assembly {
//            ds.slot := position
//        }
//    }
//
//    /// @notice Initializes the LAND storage with default values
//    /// @dev This function can only be called once
//    function initializeLandStorage() internal initializer(1) {
//        //Data storage s = data();
///*        s.maxSupply = 20000;
//        s.minX = -112;
//        s.maxX = 112;
//        s.minY = -112;
//        s.maxY = 112;*/
//    }
//
//    /// @dev Error thrown when trying to initialize with a version lower than or equal to the current version
//    /// @param currentVersion The current initialization version
//    /// @param newVersion The new version attempted to initialize
//    error AlreadyInitialized(uint256 currentVersion, uint256 newVersion);
//
//    /// @notice Modifier to ensure initialization is done only once per version
//    /// @param version The version number of the initializer
//    modifier initializer(uint256 version) {
//        Data storage s = data();
//        if (s.initializationNumber >= version) {
//            revert AlreadyInitialized(s.initializationNumber, version);
//        }
//        _;
//        s.initializationNumber = version;
//    }
//
//
//    /// @notice Main data structure for LAND storage
//    struct Data {
//        /// @notice The initialization version number
//        uint256 initializationNumber;
//
//        /// @notice Mapping from token ID to its accumulated plant points
//        //mapping(uint256 => uint256) accumulatedPlantPoints;  //TODO: remove for new deployment
//
//        /// @notice Mapping from token ID to its accumulated plant lifetime
//        //mapping(uint256 => uint256) accumulatedPlantLifetime; //TODO: remove for new deployment
//    }
//}