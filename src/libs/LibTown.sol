// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "./LibTownStorage.sol";
import "../shared/Structs.sol";
import "./LibXP.sol";

/// @title LibTown
/// @notice A library for managing town-related operations in the Pixotchi game
library LibTown {
    /// @notice Get all town buildings for a given land ID
    /// @param landId The ID of the land
    /// @return townBuildings An array of TownBuilding structs containing the building information
    function _getBuildingsByLandId(uint256 landId) internal view returns (TownBuilding[] memory townBuildings) {
        LibTownStorage.Data storage s = LibTownStorage.data();
        
        townBuildings = new TownBuilding[](LibTownStorage.townEnabledBuildingTypesCount());
        uint8[] memory enabledBuildingTypes = LibTownStorage.townEnabledBuildingTypes();
        
        for (uint8 i = 0; i < LibTownStorage.townEnabledBuildingTypesCount(); i++) {
            uint8 buildingId = enabledBuildingTypes[i];
            townBuildings[i] = _getTownBuildingInfo(s, landId, buildingId);
        }
        
        return townBuildings;
    }

    function _getTownBuildingInfo(LibTownStorage.Data storage s, uint256 landId, uint8 buildingId) internal view returns (TownBuilding memory) {
        LibTownStorage.TownBuilding storage storedBuilding = s.townBuildings[landId][buildingId];
        LibTownStorage.TownBuildingType storage buildingType = s.townBuildingTypes[buildingId];
        
        uint8 currentLevel = storedBuilding.level;
        LibTownStorage.LevelData storage levelData = buildingType.levelData[currentLevel];
        LibTownStorage.LevelData storage levelDataNext = buildingType.levelData[currentLevel + 1];

        bool isUpgrading = _townIsUpgrading(landId, buildingId);

        return TownBuilding({
            id: buildingId,
            level: currentLevel,
            maxLevel: buildingType.maxLevel,
            blockHeightUpgradeInitiated: storedBuilding.blockHeightUpgradeInitiated,
            blockHeightUntilUpgradeDone: storedBuilding.blockHeightUntilUpgradeDone,
            isUpgrading: isUpgrading,
            levelUpgradeCostLeaf: isUpgrading ? levelData.levelUpgradeCostLeaf : levelDataNext.levelUpgradeCostLeaf,
            levelUpgradeCostSeedInstant: isUpgrading ? levelData.levelUpgradeCostSeedInstant : levelDataNext.levelUpgradeCostSeedInstant,
            levelUpgradeBlockInterval: isUpgrading ? levelData.levelUpgradeBlockInterval : levelDataNext.levelUpgradeBlockInterval,
            levelUpgradeCostSeed: isUpgrading ? levelData.levelUpgradeCostSeed : levelDataNext.levelUpgradeCostSeed
        });
    }

    /// @notice Upgrade a town building using leaves
    /// @param landId The ID of the land
    /// @param buildingId The ID of the building to upgrade
    /// @return upgradeCost The cost of the upgrade in leaves
    /// @return xp The amount of XP awarded for the upgrade
    function _upgradeWithLeaf(uint256 landId, uint8 buildingId) internal returns (uint256 upgradeCost, uint256 xp) {
        LibTownStorage.Data storage s = LibTownStorage.data();
        
        // Check if the building type is enabled
        require(s.townBuildingTypes[buildingId].enabled, "Building type is not enabled");

        // Check if the building is not currently upgrading
        require(!_townIsUpgrading(landId, buildingId), "Building is already upgrading");

        uint8 currentLevel = s.townBuildings[landId][buildingId].level;
        uint8 nextLevel = currentLevel + 1;

        // Check if the building can be upgraded
        require(nextLevel <= s.townBuildingTypes[buildingId].maxLevel, "Building already at max level");

        upgradeCost = s.townBuildingTypes[buildingId].levelData[nextLevel].levelUpgradeCostLeaf;
        uint256 upgradeBlockInterval = s.townBuildingTypes[buildingId].levelData[nextLevel].levelUpgradeBlockInterval;

        // Calculate XP
        xp = LibXP.calculateLeafUpgradeXP(nextLevel);

        // Add XP to the land
        // LibXP._pushExperiencePoints(landId, xp);

        // Check if the user has enough leaves
        // require(_sA().resources[msg.sender].leaves >= upgradeCost, "Not enough leaves");

        // TODO: Implement safe transfer of leaves
        // _safeTransferLeaves(msg.sender, address(this), upgradeCost);

        // Set upgrade details
        uint256 upgradeCompletionBlock = block.number + upgradeBlockInterval;
        s.townBuildings[landId][buildingId].blockHeightUpgradeInitiated = block.number;
        s.townBuildings[landId][buildingId].blockHeightUntilUpgradeDone = upgradeCompletionBlock;
        s.townBuildings[landId][buildingId].level = nextLevel;

        // TODO: Emit an event for the upgrade initiation
        // emit TownUpgradeInitiated(landId, buildingId, nextLevel, block.number, upgradeCompletionBlock);

        return (upgradeCost, xp);
    }

    /// @notice Speed up a town building upgrade using seeds
    /// @param landId The ID of the land
    /// @param buildingId The ID of the building to speed up
    /// @return speedUpCost The cost of speeding up the upgrade in seeds
    /// @return xp The amount of XP awarded for speeding up
    function _speedUpWithSeed(uint256 landId, uint8 buildingId) internal returns (uint256 speedUpCost, uint256 xp) {
        LibTownStorage.Data storage s = LibTownStorage.data();
        
        // Check if the building is currently upgrading
        require(_townIsUpgrading(landId, buildingId), "Building is not upgrading");
        
        uint8 currentLevel = s.townBuildings[landId][buildingId].level;
        speedUpCost = s.townBuildingTypes[buildingId].levelData[currentLevel].levelUpgradeCostSeedInstant;
        
        // Calculate XP
        xp = LibXP.calculateSeedSpeedUpXP(currentLevel);

        // Add XP to the land
        // LibXP._pushExperiencePoints(landId, xp);

        // Check if the user has enough seeds
        // require(_sA().resources[msg.sender].seeds >= speedUpCost, "Not enough seeds");
        
        // Deduct seeds and complete the upgrade instantly
        // _sA().resources[msg.sender].seeds -= speedUpCost;
        // s.townBuildings[landId][buildingId].blockHeightUpgradeInitiated = 0;
        s.townBuildings[landId][buildingId].blockHeightUntilUpgradeDone = block.number;
        // s.townBuildings[landId][buildingId].level++;
        
        // TODO: Update production rates or other relevant data
        // TODO: Emit an event for the speed-up

        return (speedUpCost, xp);
    }

    /// @notice Checks if a town building is currently in the process of upgrading
    /// @dev This function performs two checks:
    ///      1. If the upgrade end block is in the future (upgrade not finished)
    ///      2. If the upgrade start block is in the past (upgrade has started)
    /// @param landId The ID of the land where the building is located
    /// @param buildingId The ID of the building to check
    /// @return isUpgrading True if the building is currently upgrading, false otherwise
    function _townIsUpgrading(uint256 landId, uint8 buildingId) internal view returns (bool isUpgrading) {
        LibTownStorage.Data storage s = LibTownStorage.data();
        
        // Check if the building exists
        if (s.townBuildings[landId][buildingId].level == 0) {
            return false;
        }
        
        // Check if the building is currently upgrading
        // Step 1: Check if the upgrade end block is in the future
        bool upgradeNotFinished = s.townBuildings[landId][buildingId].blockHeightUntilUpgradeDone >= block.number;
        
        // Step 2: Check if the upgrade start block is in the past
        bool upgradeStarted = s.townBuildings[landId][buildingId].blockHeightUpgradeInitiated <= block.number;
        
        // Step 3: Combine both conditions to determine if the building is currently upgrading
        isUpgrading = upgradeNotFinished && upgradeStarted;

        return isUpgrading;
    }

    /// @notice Gets the current level of a specific building in a town
    /// @param landId The ID of the land where the building is located
    /// @param buildingId The ID of the building to check
    /// @return level The current level of the building
    function getBuildingLevel(uint256 landId, LibTownStorage.TownBuildingNaming buildingId) internal view returns (uint8 level) {
        LibTownStorage.Data storage s = LibTownStorage.data();
        
        // Check if the building exists and return its level
        level = s.townBuildings[landId][uint8(buildingId)].level;
        
        return level;
    }

    function _upgradeWithSeed(uint256 landId, uint8 buildingId) internal  returns(uint256 upgradeCost, uint256 xp) {
        LibTownStorage.Data storage s = LibTownStorage.data();

        // Check if the building type is enabled
        require(s.townBuildingTypes[buildingId].enabled, "Building type is not enabled");

        // Check if the building is not currently upgrading
        require(!_townIsUpgrading(landId, buildingId), "Building is already upgrading");

        uint8 currentLevel = s.townBuildings[landId][buildingId].level;
        uint8 nextLevel = currentLevel + 1;

        // Check if the building can be upgraded
        require(nextLevel <= s.townBuildingTypes[buildingId].maxLevel, "Building already at max level");

        upgradeCost = s.townBuildingTypes[buildingId].levelData[nextLevel].levelUpgradeCostSeed;
        uint256 upgradeBlockInterval = s.townBuildingTypes[buildingId].levelData[nextLevel].levelUpgradeBlockInterval;

        // Calculate XP
        xp = LibXP.calculateLeafUpgradeXP(nextLevel);

        // Add XP to the land
        // LibXP._pushExperiencePoints(landId, xp);

        // Check if the user has enough leaves
        // require(_sA().resources[msg.sender].leaves >= upgradeCost, "Not enough leaves");

        // TODO: Implement safe transfer of leaves
        // _safeTransferLeaves(msg.sender, address(this), upgradeCost);

        // Set upgrade details
        uint256 upgradeCompletionBlock = block.number + upgradeBlockInterval;
        s.townBuildings[landId][buildingId].blockHeightUpgradeInitiated = block.number;
        s.townBuildings[landId][buildingId].blockHeightUntilUpgradeDone = upgradeCompletionBlock;
        s.townBuildings[landId][buildingId].level = nextLevel;

        // TODO: Emit an event for the upgrade initiation
        // emit TownUpgradeInitiated(landId, buildingId, nextLevel, block.number, upgradeCompletionBlock);

        return (upgradeCost, xp);
    }
}
