// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

//import { LibLandStorage } from "../libs/LibLandStorage.sol";
//import  "../libs/LibAppStorage.sol";
//import   "../shared/Structs.sol";
import "./LibVillageStorage.sol";
import "../shared/Structs.sol";
import "./LibLand.sol";
import "./LibXP.sol";

/// @title LibLand
/// @notice A library for managing land-related operations in the Pixotchi game
library LibVillage {



    /// @notice Upgrades or builds a village building using leaves
    /// @param landId The ID of the land
    /// @param buildingId The ID of the building to upgrade or build
    /// @return upgradeCost The cost of the upgrade in leaves
    /// @return xp The amount of XP awarded for the upgrade
    function _villageUpgradeWithLeaf(uint256 landId, uint8 buildingId) internal returns (uint256 upgradeCost, uint256 xp) {
        LibVillageStorage.Data storage s = _sNB();
        
        // Check if the building type is enabled
        require(s.villageBuildingTypes[buildingId].enabled, "Building type is not enabled");

        // Check if the building is not currently upgrading
        require(!_villageIsUpgrading(landId, buildingId), "Building is already upgrading");

        uint8 currentLevel = s.villageBuildings[landId][buildingId].level;
        uint8 nextLevel = currentLevel + 1;

        // Check if the building can be upgraded
        require(nextLevel <= s.villageBuildingTypes[buildingId].maxLevel, "Building already at max level");

        upgradeCost = s.villageBuildingTypes[buildingId].levelData[nextLevel].levelUpgradeCostLeaf;
        uint256 upgradeBlockInterval = s.villageBuildingTypes[buildingId].levelData[nextLevel].levelUpgradeBlockInterval;

        if (currentLevel > 0) {
            _villageClaimProduction(landId, buildingId);
        }

        // Set upgrade details
        uint256 upgradeCompletionBlock = block.number + upgradeBlockInterval;
        s.villageBuildings[landId][buildingId].blockHeightUpgradeInitiated = block.number;
        s.villageBuildings[landId][buildingId].blockHeightUntilUpgradeDone = upgradeCompletionBlock;
        s.villageBuildings[landId][buildingId].claimedBlockHeight = upgradeCompletionBlock;
        s.villageBuildings[landId][buildingId].level = nextLevel;

        // Calculate XP
        xp = LibXP.calculateLeafUpgradeXP(nextLevel);

        // Add XP to the land
        //LibXP._pushExperiencePoints(landId, xp);

        // TODO: Emit an event for the upgrade initiation
        // emit VillageUpgradeInitiated(landId, buildingId, nextLevel, block.number, upgradeCompletionBlock);

        return (upgradeCost, xp);
    }



    /// @notice Speeds up a village building upgrade using a seed
    /// @param landId The ID of the land
    /// @param buildingId The ID of the building to speed up
    /// @return speedUpCost The cost of speeding up in seeds
    /// @return xp The amount of XP awarded for speeding up
    function _villageSpeedUpWithSeed(uint256 landId, uint8 buildingId) internal returns (uint256 speedUpCost, uint256 xp) {
        LibVillageStorage.Data storage s = _sNB();
        
        // Check if the building is currently upgrading
        require(_villageIsUpgrading(landId, buildingId), "Building is not upgrading");
        
        uint8 currentLevel = s.villageBuildings[landId][buildingId].level;
        speedUpCost = s.villageBuildingTypes[buildingId].levelData[currentLevel].levelUpgradeCostSeedInstant;
        
        s.villageBuildings[landId][buildingId].blockHeightUntilUpgradeDone = block.number;
        s.villageBuildings[landId][buildingId].claimedBlockHeight = block.number;
        
        // Calculate XP
        xp = LibXP.calculateSeedSpeedUpXP(currentLevel);

        // Add XP to the land
        //LibXP._pushExperiencePoints(landId, xp);

        // TODO: Update production rates or other relevant data

        return (speedUpCost, xp);
    }

    /// @notice Claims production from a village building
    /// @param landId The ID of the land
    /// @param buildingId The ID of the building to claim production from
    function _villageClaimProduction(uint256 landId, uint8 buildingId) internal {
        LibVillageStorage.Data storage s = _sNB();
        
        // Check if the building exists and is not upgrading
        require(s.villageBuildingTypes[buildingId].enabled, "Building type is not enabled");
        require(!_villageIsUpgrading(landId, buildingId), "Building is currently upgrading");
        
        // Check if the building produces plant lifetime
        if (s.villageBuildingTypes[buildingId].isProducingPlantLifetime) {
            uint256 accumulatedLifetime = _villageCalculateAccumulatedLifetime(landId, buildingId);
            if (accumulatedLifetime > 0) {
                LibLand._pushAccumulatedPlantLifetime(landId, accumulatedLifetime);
            }
        }
        
        // Check if the building produces plant points
        if (s.villageBuildingTypes[buildingId].isProducingPlantPoints) {
            uint256 accumulatedPoints = _villageCalculateAccumulatedPoints(landId, buildingId);
            if (accumulatedPoints > 0) {
                LibLand._pushAccumulatedPlantPoints(landId, accumulatedPoints);
            }
        }

        // Update last claim time
        s.villageBuildings[landId][buildingId].claimedBlockHeight = block.number;
        
        // TODO: Emit an event for the production claim
        // emit ProductionClaimed(landId, buildingId, accumulatedLifetime, accumulatedPoints);
    }

    /// @notice Checks if a village building is currently in the process of upgrading
    /// @dev This function performs two checks:
    ///      1. If the upgrade end block is in the future (upgrade not finished)
    ///      2. If the upgrade start block is in the past (upgrade has started)
    /// @param landId The ID of the land where the building is located
    /// @param buildingId The ID of the building to check
    /// @return isUpgrading True if the building is currently upgrading, false otherwise
    function _villageIsUpgrading(uint256 landId, uint8 buildingId) internal view returns (bool isUpgrading) {
        LibVillageStorage.Data storage s = _sNB();
        
        // Check if the building exists
        if (s.villageBuildings[landId][buildingId].level == 0) {
            return false;
        }
        
        // Check if the building is currently upgrading
        // Step 1: Check if the upgrade end block is in the future
        bool upgradeNotFinished = s.villageBuildings[landId][buildingId].blockHeightUntilUpgradeDone >= block.number;
        
        // Step 2: Check if the upgrade start block is in the past
        bool upgradeStarted = s.villageBuildings[landId][buildingId].blockHeightUpgradeInitiated <= block.number;
        
        // Step 3: Combine both conditions to determine if the building is currently upgrading
        isUpgrading = upgradeNotFinished && upgradeStarted;

        return isUpgrading;
    }

    /// @notice Retrieves all village buildings for a given land ID
    /// @param landId The ID of the land
    /// @return buildings An array of VillageBuilding structs for the given land ID
    function _villageGetBuildingsByLandId(uint256 landId) internal view returns (VillageBuilding[] memory buildings) {
        //LibVillageStorage.Data storage s = _sNB();
        
        buildings = new VillageBuilding[](LibVillageStorage.villageEnabledBuildingTypesCount());
        uint8[] memory enabledBuildingTypes = LibVillageStorage.villageEnabledBuildingTypes();
        
        for (uint8 i = 0; i < LibVillageStorage.villageEnabledBuildingTypesCount(); i++) {
            uint8 buildingId = enabledBuildingTypes[i];
            buildings[i] = _getVillageBuildingInfo(landId, buildingId);
        }
        
        return buildings;
    }

    function _getVillageBuildingInfo(uint256 landId, uint8 buildingId) internal view returns (VillageBuilding memory) {
        LibVillageStorage.Data storage s = _sNB();
        LibVillageStorage.VillageBulding storage storedBuilding = s.villageBuildings[landId][buildingId];
        LibVillageStorage.VillageBuildingType storage buildingType = s.villageBuildingTypes[buildingId];
        
        uint8 currentLevel = storedBuilding.level;
        LibVillageStorage.LevelData storage levelData = buildingType.levelData[currentLevel];
        LibVillageStorage.LevelData storage levelDataNext = buildingType.levelData[currentLevel + 1];

        bool isUpgrading = _villageIsUpgrading(landId, buildingId);

        (uint256 levelUpgradeCostLeaf, uint256 levelUpgradeCostSeedInstant, uint256 levelUpgradeBlockInterval) = 
            isUpgrading ? 
            (levelData.levelUpgradeCostLeaf, levelData.levelUpgradeCostSeedInstant, levelData.levelUpgradeBlockInterval) :
            (levelDataNext.levelUpgradeCostLeaf, levelDataNext.levelUpgradeCostSeedInstant, levelDataNext.levelUpgradeBlockInterval);

        return VillageBuilding({
            id: buildingId,
            level: currentLevel,
            maxLevel: buildingType.maxLevel,
            blockHeightUpgradeInitiated: storedBuilding.blockHeightUpgradeInitiated,
            blockHeightUntilUpgradeDone: storedBuilding.blockHeightUntilUpgradeDone,
            accumulatedPoints: _villageCalculateAccumulatedPoints(landId, buildingId),
            accumulatedLifetime: _villageCalculateAccumulatedLifetime(landId, buildingId),
            isUpgrading: isUpgrading,
            levelUpgradeCostLeaf: levelUpgradeCostLeaf,
            levelUpgradeCostSeedInstant: levelUpgradeCostSeedInstant,
            levelUpgradeBlockInterval: levelUpgradeBlockInterval,
            productionRatePlantLifetimePerDay: levelData.productionRatePlantLifetimePerDay,
            productionRatePlantPointsPerDay: levelData.productionRatePlantPointsPerDay,
            claimedBlockHeight: storedBuilding.claimedBlockHeight
        });
    }

    /// @notice Internal function to access NFT Building storage
    /// @return data The LibLandBuildingStorage.Data struct
    function _sNB() internal pure returns (LibVillageStorage.Data storage data) {
        data = LibVillageStorage.data();
    }

    /// @notice Calculates the accumulated plant points for a village building
    /// @param landId The ID of the land
    /// @param buildingId The ID of the building
    /// @return accumulatedPoints The accumulated plant points
    function _villageCalculateAccumulatedPoints(uint256 landId, uint8 buildingId) internal view returns (uint256 accumulatedPoints) {
        LibVillageStorage.Data storage s = _sNB();
        LibVillageStorage.VillageBulding storage building = s.villageBuildings[landId][buildingId];
        LibVillageStorage.VillageBuildingType storage buildingType = s.villageBuildingTypes[buildingId];

        if (!buildingType.isProducingPlantPoints || building.level == 0 || _villageIsUpgrading(landId, buildingId)) {
            return 0;
        }
        uint256 lastClaimBlock = building.claimedBlockHeight;
        uint256 currentBlock = block.number;

        uint256 blocksPassed = currentBlock - lastClaimBlock;
        uint256 productionRate = buildingType.levelData[building.level].productionRatePlantPointsPerDay;

        accumulatedPoints = _calculateAccumulatedPoints(blocksPassed, productionRate);
    }

    /// @notice Calculate the accumulated plant points for a village building
    /// @dev This function calculates the plant points accumulated over a period of time.
    ///      The calculation is done in the following steps:
    ///      1. Convert blocks to seconds: blocksPassed * BLOCK_TIME
    ///      2. Calculate the fraction of a day that has passed: (blocksPassed * BLOCK_TIME) / 1 days
    ///      3. Multiply by the daily production rate: ... * productionRatePlantPointsPerDay
    ///      4. Scale the result for precision: ... * PLANT_POINT_DECIMALS
    ///      All multiplications are performed before division to maintain precision.
    /// @param blocksPassed The number of blocks that have passed since the last update
    /// @param productionRatePlantPointsPerDay The daily production rate of plant points for the building
    /// @return The accumulated plant points, scaled by PLANT_POINT_DECIMALS (1e12)
    function _calculateAccumulatedPoints(uint256 blocksPassed, uint256 productionRatePlantPointsPerDay) private pure returns (uint256) {
        return (blocksPassed * LibConstants.BLOCK_TIME * productionRatePlantPointsPerDay * LibConstants.PLANT_POINT_DECIMALS) / (1 days * 10);
    }

    /// @notice Calculates the accumulated plant lifetime for a village building
    /// @param landId The ID of the land
    /// @param buildingId The ID of the building
    /// @return accumulatedLifetime The accumulated plant lifetime in seconds
    function _villageCalculateAccumulatedLifetime(uint256 landId, uint8 buildingId) internal view returns (uint256 accumulatedLifetime) {
        LibVillageStorage.Data storage s = _sNB();
        LibVillageStorage.VillageBulding storage building = s.villageBuildings[landId][buildingId];
        LibVillageStorage.VillageBuildingType storage buildingType = s.villageBuildingTypes[buildingId];

        if (!buildingType.isProducingPlantLifetime || building.level == 0  || _villageIsUpgrading(landId, buildingId)) {
            return 0;
        }

        uint256 lastClaimBlock = building.claimedBlockHeight;
        uint256 currentBlock = block.number;

        uint256 blocksPassed = currentBlock - lastClaimBlock;
        uint256 productionRate = buildingType.levelData[building.level].productionRatePlantLifetimePerDay;

        accumulatedLifetime = _calculateAccumulatedLifetime(blocksPassed, productionRate);

        //accumulatedLifetime = (blocksPassed * productionRate * LibVillageStorage.BLOCK_TIME) /*/ 1e18*/; // Convert to seconds and adjust for precision
    }

    /// @notice Calculate the accumulated plant lifetime for a village
    /// @dev This function performs the following steps:
    ///      1. Convert blocks to seconds: blocksPassed * BLOCK_TIME
    ///      2. Calculate the fraction of a day that has passed: (blocksPassed * BLOCK_TIME) / 1 days
    ///      3. Multiply by the daily production rate: ... * productionRatePlantLifetimePerDay
    ///      The operations are ordered to maximize precision before division.
    /// @param blocksPassed The number of blocks that have passed since the last update
    /// @param productionRatePlantLifetimePerDay The amount of plant lifetime produced per day
    /// @return The accumulated plant lifetime
    function _calculateAccumulatedLifetime(uint256 blocksPassed, uint256 productionRatePlantLifetimePerDay) private pure returns (uint256) {
        // Perform multiplications before division to maintain precision
        // (blocksPassed * BLOCK_TIME) converts blocks to seconds
        // (... * productionRatePlantLifetimePerDay) calculates total lifetime for the time period
        // Finally, divide by (1 days) to get the fraction of daily production
        return (blocksPassed * LibConstants.BLOCK_TIME * productionRatePlantLifetimePerDay) / (1 days );
    }

//    /// @notice Internal function to access AppStorage
//    /// @return data The AppStorage struct
//    function _sA() internal pure returns (AppStorage storage data) {
//        data = LibAppStorage.diamondStorage();
//    }


}
