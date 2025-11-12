// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

/// @notice Defines the main data structures used in the game

// Add this line at the beginning of the file, after the pragma statement
error InvalidLevel();

/// @notice Stores context for meta-transactions
/// @dev Used for storing trusted forwarder address in EIP-2771 context
struct MetaTxContextStorage {
  /// @notice Address of the trusted forwarder for meta-transactions
  address trustedForwarder;
}

/// @notice Represents a land parcel in the game
/// @dev This struct contains all the essential information about a land
struct Land {
  /// @notice Unique identifier for the land
  uint256 tokenId;
  /// @notice URI for the land's metadata
  string tokenUri;
  /// @notice Timestamp of when the land was minted
  uint256 mintDate;
  /// @notice Address of the land owner
  address owner;
  /// @notice Custom name given to the land
  string name;
  /// @notice X-coordinate of the land on the game map
  int256 coordinateX;
  /// @notice Y-coordinate of the land on the game map
  int256 coordinateY;
  /// @notice Total experience points accumulated on this land
  uint256 experiencePoints;
  /// @notice Cumulative points earned from plants on this land
  uint256 accumulatedPlantPoints;
  /// @notice Total lifetime of all plants grown on this land
  uint256 accumulatedPlantLifetime;
  /// @notice Farmer Avatar id
  uint8 farmerAvatar;
}

/// @notice Represents a building in the game
/// @dev Contains information about a building's state and progress
struct VillageBuilding {
  /// @notice Unique identifier for the building type
  uint8 id;
  /// @notice Current level of the building
  uint8 level;
  /// @notice Maximum level this building type can reach
  uint8 maxLevel;
  /// @notice Block number when the upgrade was initiated
  uint256 blockHeightUpgradeInitiated;
  /// @notice Block number when the upgrade will be completed
  uint256 blockHeightUntilUpgradeDone;
  /// @notice Total points accumulated by this building
  uint256 accumulatedPoints;
  /// @notice Total lifetime of the building
  uint256 accumulatedLifetime;
  /// @notice Whether the building is currently upgrading
  bool isUpgrading;
  /// @notice Leaf cost for upgrading to current level
  uint256 levelUpgradeCostLeaf;
  /// @notice Seed cost for instant upgrade to current level
  uint256 levelUpgradeCostSeedInstant;
  /// @notice Block interval required for upgrading to current level
  uint256 levelUpgradeBlockInterval;
  /// @notice Production rate of plant lifetime per day for current level
  uint256 productionRatePlantLifetimePerDay;
  /// @notice Production rate of plant points per day for current level
  uint256 productionRatePlantPointsPerDay;
  /// @notice Block height when the resources were claimed last.
  uint256 claimedBlockHeight;

  //extend the struct to include the building type.
  //but only what is needed for the building type at the for the next building level upgrade.
  //levelUpgradeCostLeaf, levelUpgradeCostSeedInstant, levelUpgradeBlockInterval
  //productionRatePlantLifetimePerBlock
  //productionRatePlantPointsPerBlock
}

/// @notice Represents a building in the town area of the game
/// @dev Contains information about a town building's state and upgrade progress
struct TownBuilding {
    /// @notice Unique identifier for the building type
    uint8 id;
    /// @notice Current level of the building
    uint8 level;
    /// @notice Maximum level this building type can reach
    uint8 maxLevel;
    /// @notice Block number when the upgrade was initiated
    uint256 blockHeightUpgradeInitiated;
    /// @notice Block number when the upgrade will be completed
    uint256 blockHeightUntilUpgradeDone;
    /// @notice Whether the building is currently upgrading
    bool isUpgrading;
    /// @notice Leaf cost for upgrading to the next level
    uint256 levelUpgradeCostLeaf;
    /// @notice Seed cost for instant upgrade to the next level
    uint256 levelUpgradeCostSeedInstant;
    /// @notice Block interval required for upgrading to the next level
    uint256 levelUpgradeBlockInterval;
    /// @notice Seed cost for upgrading to the next level
    uint256 levelUpgradeCostSeed;
}

//two seperate getter. for farmer house and for market place.
//quest system. farmer house.
//market place

/// @notice Struct to hold basic land information for overview
struct LandOverview {
  uint256 tokenId;
  int256 coordinateX;
  int256 coordinateY;
  string name;
}

// Enums
enum QuestDifficultyLevel {
  EASY,
  MEDIUM,
  HARD
}
enum RewardType {
  SEED,
  LEAF,
  PLANT_LIFE_TIME,
  PLANT_POINTS,
  XP
}

// Structs
struct QuestDifficulty {
  QuestDifficultyLevel difficulty;
  uint256 durationInBlocks;
  uint256 cooldownInBlocks;
  uint256 rewardMultiplier;
}

struct Quest {
  QuestDifficultyLevel difficulty;
  uint256 startBlock;
  uint256 endBlock;
  uint256 pseudoRndBlock;
  uint256 coolDownBlock;
}

struct Leaderboard {
  uint256 landId;
  uint256 experiencePoints;
  //address owner;
  string name;
}

//TODO: discuss with wu potential question structs and edge cases, specially daiyl quests / threashold. edge quest daily quest consume -> user upgrade building
//TODO: prevent user from upgrading quest buliding if he is questing.

///// @notice Defines the properties of a building type
///// @dev Contains static information about a building type and its upgrade costs
///// producing buildings
//struct BuildingVillageType {
//    /// @notice Unique identifier for the building type
//    uint8 id;
//    /// @notice Name of the building type
//    string name;
//    /// @notice Maximum level this building type can reach
//    uint8 maxLevel;
//    /// @notice Whether this building type can be upgraded
//    bool upgradable;
//    /// @notice Whether this building type comes pre-built
//    //bool preBuilt;
//    /// @notice Leaf cost for upgrading to each level
//    uint256[] levelUpgradeCostLeaf;
//    /// @notice Seed cost for instant upgrade to each level
//    uint256[] levelUpgradeCostSeedInstant;
//    /// @notice Block interval required for upgrading to each level
//    uint256[] levelUpgradeBlockInterval;
//    /// @notice Whether this building type produces plant points
//    bool isProducingPlantPoints;
//    /// @notice Whether this building type produces plant lifetime
//    bool isProducingPlantLifetime;
//    /// @notice Production rate of plant lifetime per block for each level
//    uint256[] productionRatePlantLifetimePerBlock;
//    /// @notice Production rate of plant points per block for each level
//    uint256[] productionRatePlantPointsPerBlock;
//}
//
//
///// @notice Defines the properties of a building type
///// @dev Contains static information about a building type and its upgrade costs
//// ressource managment.
//    struct BuildingTownType {
//        /// @notice Unique identifier for the building type
//        uint8 id;
//        /// @notice Name of the building type
//        string name;
//        /// @notice Maximum level this building type can reach
//        uint8 maxLevel;
//        /// @notice Whether this building type can be upgraded
//        bool upgradable;
//        /// @notice Whether this building type comes pre-built
//        bool preBuilt;
//        /// @notice Leaf cost for upgrading to each level
//        uint256[] levelUpgradeCostLeaf;
//        /// @notice Seed cost for instant upgrade to each level
//        uint256[] levelUpgradeCostSeedInstant;
//        /// @notice Block interval required for upgrading to each level
//        uint256[] levelUpgradeBlockInterval;
//        /// @notice Whether this building type produces plant points
//    }

  struct MarketPlaceOrderView {
    uint256 id;
    address seller;
    uint8 sellToken;
    uint256 amount;
    bool isActive;
    uint256 amountAsk;
  }