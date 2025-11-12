// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "./LibConstants.sol";

/// @title LibTownStorage
/// @notice Library for managing LAND building storage
library LibTownStorage {
    /// @notice Block time in seconds
    /// @dev This constant represents the average block time on the network
    uint256 internal constant BLOCK_TIME = LibConstants.BLOCK_TIME;

    /// @notice Storage position for the diamond storage
    /// @dev This constant is used to determine the storage slot for diamond storage
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("eth.pixotchi.land.town.storage");

    /// @notice Returns the diamond storage for LAND-related data
    /// @return ds The Data struct containing LAND storage
    function data() internal pure returns (Data storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /// @notice Initializes the Town storage
    /// @dev This function should only be called once during contract initialization
    function initializeTownStorage() internal initializer(1) {
        Data storage s = data();
        _initBuildingTypes(s);
    }

    /// @notice Error thrown when trying to initialize with a version lower than or equal to the current one
    /// @param currentVersion The current initialization version
    /// @param newVersion The new version attempting to be initialized
    error AlreadyInitialized(uint256 currentVersion, uint256 newVersion);

    /// @notice Modifier to ensure initialization is done only once per version
    /// @param version The version number of the initializer
    modifier initializer(uint256 version) {
        Data storage s = data();
        if (s.initializationNumber >= version) {
            revert AlreadyInitialized(s.initializationNumber, version);
        }
        _;
        s.initializationNumber = version;
    }

    /// @notice Struct containing all the storage variables for LAND buildings
    struct Data {
        /// @notice The current initialization version number
        uint256 initializationNumber;
        /// @notice Mapping of town ID to its buildings
        /// @dev Key is the town ID, value is a mapping of building ID to Building struct
        mapping(uint256 => mapping(uint8 => TownBuilding)) townBuildings;
        /// @notice Mapping of building type ID to its configuration
        mapping(uint8 => TownBuildingType) townBuildingTypes;
    }

    /// @notice Represents a building in a town
    struct TownBuilding {
        /// @notice Current level of the building
        uint8 level;
        /// @notice Block number when the upgrade was initiated
        uint256 blockHeightUpgradeInitiated;
        /// @notice Block number when the upgrade will be completed
        uint256 blockHeightUntilUpgradeDone;
        /// @notice Block height when the resources were claimed last
        uint256 claimedBlockHeight;
    }

    /// @notice Enum representing different types of town buildings
    enum TownBuildingNaming {
        UNDEFINED_0,
        UNDEFINED_1, //STAKE_HOUSE
        UNDEFINED_2,
        UNDEFINED_3, //WARE_HOUSE
        UNDEFINED_4,
        MARKET_PLACE, //5 MARKET PLACE
        UNDEFINED_6,
        QUEST_HOUSE //7 FARMER HOUSE / QUEST HOUSE
    }

    /// @notice Returns an array of enabled town building type IDs
    /// @return An array of uint8 representing the enabled building type IDs
    function townEnabledBuildingTypes() internal pure returns (uint8[] memory) {
        uint8[] memory types = new uint8[](townEnabledBuildingTypesCount());
        types[0] = uint8(TownBuildingNaming.MARKET_PLACE);
        types[1] = uint8(TownBuildingNaming.QUEST_HOUSE);
        return types;
    }

    /// @notice Returns the count of enabled town building types
    /// @return The number of enabled town building types
    function townEnabledBuildingTypesCount() internal pure returns (uint8) {
        return 2;
    }

    /// @notice Configuration for a town building type
    struct TownBuildingType {
        /// @notice Maximum level this building type can reach
        uint8 maxLevel;
        /// @notice Whether this building type is enabled
        bool enabled;
        /// @notice Mapping of level to level-specific data
        mapping(uint8 => LevelData) levelData;
    }

    /// @notice Data specific to each level of a building type
    struct LevelData {
        /// @notice Leaf cost for upgrading to this level
        uint256 levelUpgradeCostLeaf;
        /// @notice Seed cost for instant upgrade to this level
        uint256 levelUpgradeCostSeedInstant;
        /// @notice Block interval required for upgrading to this level
        uint256 levelUpgradeBlockInterval;
        /// @notice Seed cost for upgrading to this level
        uint256 levelUpgradeCostSeed;
    }

    function _initBuildingTypes(Data storage s) internal {
        // Initialize Market Place
        s.townBuildingTypes[uint8(TownBuildingNaming.MARKET_PLACE)].maxLevel = 1;
        s.townBuildingTypes[uint8(TownBuildingNaming.MARKET_PLACE)].enabled = true;
        _initMarketPlaceLevels(s.townBuildingTypes[uint8(TownBuildingNaming.MARKET_PLACE)]);

        // Initialize Quest House
        s.townBuildingTypes[uint8(TownBuildingNaming.QUEST_HOUSE)].maxLevel = 3;
        s.townBuildingTypes[uint8(TownBuildingNaming.QUEST_HOUSE)].enabled = true;
        _initQuestHouseLevels(s.townBuildingTypes[uint8(TownBuildingNaming.QUEST_HOUSE)]);
    }

    function _initMarketPlaceLevels(TownBuildingType storage buildingType) internal {
        buildingType.levelData[1] = LevelData({
            levelUpgradeCostLeaf: 400_000 ether,
            levelUpgradeCostSeedInstant: 230 ether,
            levelUpgradeBlockInterval: 24 hours / BLOCK_TIME,
        levelUpgradeCostSeed: 200 ether
        });
    }

    function _initQuestHouseLevels(TownBuildingType storage buildingType) internal {
        buildingType.levelData[1] = LevelData({
            levelUpgradeCostLeaf: 550_000 ether,
            levelUpgradeCostSeedInstant: 250 ether,
            levelUpgradeBlockInterval: 24 hours / BLOCK_TIME,
        levelUpgradeCostSeed: 0
        });

        buildingType.levelData[2] = LevelData({
            levelUpgradeCostLeaf: 12_000_000 ether,
            levelUpgradeCostSeedInstant: 625 ether,
            levelUpgradeBlockInterval: 50 hours / BLOCK_TIME,
            levelUpgradeCostSeed: 0
        });

        buildingType.levelData[3] = LevelData({
            levelUpgradeCostLeaf: 18_000_000 ether,
            levelUpgradeCostSeedInstant: 1_450 ether,
            levelUpgradeBlockInterval: 90 hours / BLOCK_TIME,
            levelUpgradeCostSeed: 0
        });
    }
}
