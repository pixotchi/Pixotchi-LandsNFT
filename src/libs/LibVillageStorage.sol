// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "./LibConstants.sol";

/// @title LibVillageStorage
/// @notice Library for managing LAND building storage
library LibVillageStorage {
    /// @notice Block time in seconds
    /// @dev This constant represents the average block time on the network
    uint256 internal constant BLOCK_TIME = 2;

    /// @notice Storage position for the diamond storage
    /// @dev This constant is used to determine the storage slot for diamond storage
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("eth.pixotchi.land.village.storage");

    /// @notice Returns the diamond storage for LAND-related data
    /// @return ds The Data struct containing LAND storage
    function data() internal pure returns (Data storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /// @notice Initializes the village storage
    /// @dev This function should only be called once during contract initialization
    function initializeVillageStorage() internal initializer(1) {
        Data storage s = data();
        _initBuildingTypes(s);
    }



    /// @notice Initializes the village building types with their respective data
    /// @dev This function sets up the initial configuration for all building types
    /// @param s The Data storage struct to initialize
    function _initBuildingTypes(Data storage s) internal {
        // Initialize Soil Factory
        s.villageBuildingTypes[uint8(VillageBuildingNaming.SOIL_FACTORY)].maxLevel = 3;
        s.villageBuildingTypes[uint8(VillageBuildingNaming.SOIL_FACTORY)].isProducingPlantPoints = true;
        s.villageBuildingTypes[uint8(VillageBuildingNaming.SOIL_FACTORY)].isProducingPlantLifetime = false;
        s.villageBuildingTypes[uint8(VillageBuildingNaming.SOIL_FACTORY)].enabled = true;
        _initSoilFactoryLevels(s.villageBuildingTypes[uint8(VillageBuildingNaming.SOIL_FACTORY)]);

        // Initialize Solar Panel
        s.villageBuildingTypes[uint8(VillageBuildingNaming.SOLAR)].maxLevel = 3;
        s.villageBuildingTypes[uint8(VillageBuildingNaming.SOLAR)].isProducingPlantPoints = true;
        s.villageBuildingTypes[uint8(VillageBuildingNaming.SOLAR)].isProducingPlantLifetime = false;
        s.villageBuildingTypes[uint8(VillageBuildingNaming.SOLAR)].enabled = true;
        _initSolarPanelLevels(s.villageBuildingTypes[uint8(VillageBuildingNaming.SOLAR)]);

        // Initialize Bee Farm
        s.villageBuildingTypes[uint8(VillageBuildingNaming.BEE_FARM)].maxLevel = 3;
        s.villageBuildingTypes[uint8(VillageBuildingNaming.BEE_FARM)].isProducingPlantPoints = false;
        s.villageBuildingTypes[uint8(VillageBuildingNaming.BEE_FARM)].isProducingPlantLifetime = true;
        s.villageBuildingTypes[uint8(VillageBuildingNaming.BEE_FARM)].enabled = true;
        _initBeeFarmLevels(s.villageBuildingTypes[uint8(VillageBuildingNaming.BEE_FARM)]);
    }
//
//    /// @notice Calculates the production rate for plant lifetime per block
//    /// @param hoursPerDay The number of hours of lifetime produced per day
//    /// @return The production rate per block (in 1e18 precision)
//    function _calculateLifetimeProductionRate(uint256 hoursPerDay) internal pure returns (uint256) {
//        return (hoursPerDay /* * 1 hours*/ /** 1e18*/) / (24 hours / BLOCK_TIME);
//        //6 * 3600 /((24 * 3600) / 2)
//    }
//
//    /// @notice Calculates the production rate for plant points per block
//    /// @param pointsPerDay The number of points produced per day
//    /// @return The production rate per block (in PLANT_POINT_DECIMALS precision)
//    function _calculatePointsProductionRate(uint256 pointsPerDay) internal pure returns (uint256) {
//        return (pointsPerDay * (10 ** LibConstants.PLANT_POINT_DECIMALS)) / (24 hours / BLOCK_TIME);
//    }
//

    /// @notice Initializes the levels for the Soil Factory building type
    /// @param buildingType The VillageBuildingType struct to initialize
    function _initSoilFactoryLevels(VillageBuildingType storage buildingType) internal {
        buildingType.levelData[1] = LevelData({
            levelUpgradeCostLeaf: 750_000 ether,
            levelUpgradeCostSeedInstant: 200 ether,
            levelUpgradeBlockInterval: 24 hours / BLOCK_TIME,
            productionRatePlantLifetimePerDay: 0,
            productionRatePlantPointsPerDay: 70 * (10 ** LibConstants.PLANT_POINT_DECIMALS)
        });

        buildingType.levelData[2] = LevelData({
            levelUpgradeCostLeaf: 5_000_000 ether,
            levelUpgradeCostSeedInstant: 600 ether,
            levelUpgradeBlockInterval: 60 hours / BLOCK_TIME,
            productionRatePlantLifetimePerDay: 0,
            productionRatePlantPointsPerDay: 150 * (10 ** LibConstants.PLANT_POINT_DECIMALS)
        });

        buildingType.levelData[3] = LevelData({
            levelUpgradeCostLeaf: 20_00_0000 ether,
            levelUpgradeCostSeedInstant: 1_500 ether,
            levelUpgradeBlockInterval: 96 hours / BLOCK_TIME,
            productionRatePlantLifetimePerDay: 0,
            productionRatePlantPointsPerDay: 300 * (10 ** LibConstants.PLANT_POINT_DECIMALS)
        });
    }

    /// @notice Initializes the levels for the Solar Panel building type
    /// @param buildingType The VillageBuildingType struct to initialize
    function _initSolarPanelLevels(VillageBuildingType storage buildingType) internal {
        buildingType.levelData[1] = LevelData({
            levelUpgradeCostLeaf: 800_000 ether,
            levelUpgradeCostSeedInstant: 250 ether,
            levelUpgradeBlockInterval: 36 hours / BLOCK_TIME,
            productionRatePlantLifetimePerDay: 0,
            productionRatePlantPointsPerDay: 50 * (10 ** LibConstants.PLANT_POINT_DECIMALS)
        });

        buildingType.levelData[2] = LevelData({
            levelUpgradeCostLeaf: 4_500_000 ether,
            levelUpgradeCostSeedInstant: 700 ether,
            levelUpgradeBlockInterval: 48 hours / BLOCK_TIME,
            productionRatePlantLifetimePerDay: 0,
            productionRatePlantPointsPerDay: 100 * (10 ** LibConstants.PLANT_POINT_DECIMALS)
        });

        buildingType.levelData[3] = LevelData({
            levelUpgradeCostLeaf: 19_000_000 ether,
            levelUpgradeCostSeedInstant: 1_800 ether,
            levelUpgradeBlockInterval: 78 hours / BLOCK_TIME,
            productionRatePlantLifetimePerDay: 0,
            productionRatePlantPointsPerDay: 150 * (10 ** LibConstants.PLANT_POINT_DECIMALS)
        });
    }

    /// @notice Initializes the levels for the Bee Farm building type
    /// @param buildingType The VillageBuildingType struct to initialize
    function _initBeeFarmLevels(VillageBuildingType storage buildingType) internal {
        buildingType.levelData[1] = LevelData({
            levelUpgradeCostLeaf: 500_000 ether,
            levelUpgradeCostSeedInstant: 175 ether,
            levelUpgradeBlockInterval: 6 hours / BLOCK_TIME,
            productionRatePlantLifetimePerDay: 3 hours,//6 hours,
            productionRatePlantPointsPerDay: 0
        });

        buildingType.levelData[2] = LevelData({
            levelUpgradeCostLeaf: 2_500_000 ether,
            levelUpgradeCostSeedInstant: 500 ether,
            levelUpgradeBlockInterval: 18 hours / BLOCK_TIME,
            productionRatePlantLifetimePerDay: 6 hours,//12 hours,
            productionRatePlantPointsPerDay: 0
        });

        buildingType.levelData[3] = LevelData({
            levelUpgradeCostLeaf: 12_500_000 ether,
            levelUpgradeCostSeedInstant: 1_000 ether,
            levelUpgradeBlockInterval: 30 hours / BLOCK_TIME,
            productionRatePlantLifetimePerDay: 9 hours,//24 hours,
            productionRatePlantPointsPerDay: 0
        });
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
        /// @notice Mapping of village ID to its buildings
        /// @dev Key is the village ID, value is a mapping of building ID to Building struct
        mapping(uint256 => mapping(uint8 => VillageBulding)) villageBuildings;
        /// @notice Mapping of building type ID to its configuration
        mapping(uint8 => VillageBuildingType) villageBuildingTypes;
    }

    /// @notice Represents a building in a village
    struct VillageBulding {
        /// @notice Current level of the building
        uint8 level;
        /// @notice Block number when the upgrade was initiated
        uint256 blockHeightUpgradeInitiated;
        /// @notice Block number when the upgrade will be completed
        uint256 blockHeightUntilUpgradeDone;
        /// @notice Block height when the resources were claimed last
        uint256 claimedBlockHeight;
    }

    /// @notice Enum representing different types of village buildings
    enum VillageBuildingNaming {
        SOLAR, //0
        UNDEFINED_1,
        UNDEFINED_2,
        SOIL_FACTORY, //3
        UNDEFINED_4,
        BEE_FARM, //5
        UNDEFINED_6,
        UNDEFINED_7
    }

        /// @notice Returns an array of enabled village building type IDs
    /// @return An array of uint8 representing the enabled building type IDs
    function villageEnabledBuildingTypes() internal pure returns (uint8[] memory) {
        uint8[] memory types = new uint8[](villageEnabledBuildingTypesCount());
        types[0] = uint8(VillageBuildingNaming.SOLAR);
        types[1] = uint8(VillageBuildingNaming.SOIL_FACTORY);
        types[2] = uint8(VillageBuildingNaming.BEE_FARM);
        return types;
    }

    /// @notice Returns the count of enabled village building types
    /// @return The number of enabled village building types
    function villageEnabledBuildingTypesCount() internal pure returns (uint8) {
        return 3;
    }
    

    /// @notice Configuration for a village building type
    struct VillageBuildingType {
        /// @notice Maximum level this building type can reach
        uint8 maxLevel;
        /// @notice Whether this building type produces plant points
        bool isProducingPlantPoints;
        /// @notice Whether this building type produces plant lifetime
        bool isProducingPlantLifetime;
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
        /// @notice Production rate of plant lifetime per block for this level
        uint256 productionRatePlantLifetimePerDay;
        /// @notice Production rate of plant points per block for this level
        uint256 productionRatePlantPointsPerDay;
    }
}
