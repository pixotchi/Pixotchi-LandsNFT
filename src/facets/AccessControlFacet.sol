// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {LibLandStorage} from "../libs/LibLandStorage.sol";
import {LibAppStorage, AppStorage} from "../libs/LibAppStorage.sol";
import {NFTModifiers} from "../libs/LibNFT.sol";
import {LibLand} from "../libs/LibLand.sol";
import "../shared/Structs.sol";
import {AccessControl2, LibAccessControl2} from "../libs/libAccessControl2.sol";
import {LibMintControlStorage} from "../libs/LibMintControlStorage.sol";
import {LibVillageStorage} from "../libs/LibVillageStorage.sol";
import {LibQuestStorage} from "../libs/LibQuestStorage.sol";
import {QuestDifficulty} from "../shared/Structs.sol";
import {LibConstants} from "../libs/LibConstants.sol";

contract AccessControlFacet is AccessControl2 {

    struct VillageLevelConfigData {
        uint8 level;
        uint256 leafCost;
        uint256 seedInstantCost;
        uint256 blockInterval;
        uint256 lifetimePerDay;
        uint256 pointsPerDay;
    }

    struct VillageBuildingConfigData {
        uint8 id;
        bool enabled;
        bool isProducingPlantPoints;
        bool isProducingPlantLifetime;
        uint8 maxLevel;
        VillageLevelConfigData[] levels;
    }

    function accessControlStatus(address _address) external view returns (bool _paused, bool _whitelistOnly, bool _isWhitelisted) {
        return (LibAccessControl2.getPaused(), LibAccessControl2.getWhitelistOnly(), LibAccessControl2.getWhitelistAddress(_address));
    }

    function accessControlSetPaused(bool _paused) external isAdmin {
        LibAccessControl2.setPaused(_paused);
    }

    function accessControlGetPaused() external view returns (bool) {
        return LibAccessControl2.getPaused();
    }

    function accessControlSetWhitelistOnly(bool _whitelistOnly) external isAdmin {
        LibAccessControl2.setWhitelistOnly(_whitelistOnly);
    }

    function accessControlGetWhitelistOnly() external view returns (bool) {
        return LibAccessControl2.getWhitelistOnly();
    }

    function accessControlSetWhitelistAddress(address _address, bool _isWhitelisted) external isAdmin {
        LibAccessControl2.setWhitelistAddress(_address, _isWhitelisted);
    }

    function accessControlGetWhitelistAddress(address _address) external view returns (bool) {
        return LibAccessControl2.getWhitelistAddress(_address);
    }

    function accessControlBatchSetWhitelistAddresses(address[] memory _addresses, bool _isWhitelisted) external isAdmin {
        LibAccessControl2.batchSetWhitelistAddresses(_addresses, _isWhitelisted);
    }



    function _sMC() internal pure returns (LibMintControlStorage.Data storage data) {
        data = LibMintControlStorage.data();
    }

    function _sV() internal pure returns (LibVillageStorage.Data storage data) {
        data = LibVillageStorage.data();
    }

    function _sQ() internal pure returns (LibQuestStorage.Data storage data) {
        data = LibQuestStorage.data();
    }


    function mintControl(bool enabled) external isAdmin {
        _sMC().mintActive = enabled;
    }

    event MintPriceUpdated(uint256 oldPrice, uint256 newPrice);

    function mintControlSetPrice(uint256 newPrice) external isAdmin {
        require(newPrice > 0, "mint price must be > 0");
        LibMintControlStorage.Data storage s = _sMC();
        uint256 oldPrice = s.mintPrice;
        s.mintPrice = newPrice;
        emit MintPriceUpdated(oldPrice, newPrice);
    }

    event VillageLevelConfigUpdated(
        uint8 indexed buildingId,
        uint8 indexed level,
        uint256 leafCost,
        uint256 seedInstantCost,
        uint256 blockInterval,
        uint256 lifetimePerDay,
        uint256 pointsPerDay
    );

    event VillageLevelAdded(
        uint8 indexed buildingId,
        uint8 indexed level,
        uint256 leafCost,
        uint256 seedInstantCost,
        uint256 blockInterval,
        uint256 lifetimePerDay,
        uint256 pointsPerDay
    );

    event VillageLevelForced(
        uint256 indexed landId,
        uint8 indexed buildingId,
        uint8 previousLevel,
        uint8 newLevel
    );

    event VillageConfigBatchUpdated(uint8 indexed buildingId);

    event QuestDifficultyUpdated(
        QuestDifficultyLevel indexed difficulty,
        uint256 durationInBlocks,
        uint256 cooldownInBlocks,
        uint256 rewardMultiplier
    );

    function villageSetLevelConfig(
        uint8 buildingId,
        uint8 level,
        uint256 leafCost,
        uint256 seedInstantCost,
        uint256 blockInterval,
        uint256 lifetimePerDay,
        uint256 pointsPerDay
    ) external isAdmin {
        require(level > 0, "invalid level");

        LibVillageStorage.VillageBuildingType storage building = _sV().villageBuildingTypes[buildingId];
        require(building.enabled, "building disabled");
        require(level <= building.maxLevel, "level exceeds max");

        LibVillageStorage.LevelData storage levelData = building.levelData[level];

        levelData.levelUpgradeCostLeaf = leafCost;
        levelData.levelUpgradeCostSeedInstant = seedInstantCost;
        levelData.levelUpgradeBlockInterval = blockInterval;
        levelData.productionRatePlantLifetimePerDay = lifetimePerDay;
        levelData.productionRatePlantPointsPerDay = pointsPerDay;

        emit VillageLevelConfigUpdated(
            buildingId,
            level,
            leafCost,
            seedInstantCost,
            blockInterval,
            lifetimePerDay,
            pointsPerDay
        );
    }

    function villageAddLevel(
        uint8 buildingId,
        uint256 leafCost,
        uint256 seedInstantCost,
        uint256 blockInterval,
        uint256 lifetimePerDay,
        uint256 pointsPerDay
    ) external isAdmin {
        LibVillageStorage.VillageBuildingType storage building = _sV().villageBuildingTypes[buildingId];
        require(building.enabled, "building disabled");

        uint8 newLevel = building.maxLevel + 1;
        building.maxLevel = newLevel;

        LibVillageStorage.LevelData storage levelData = building.levelData[newLevel];

        levelData.levelUpgradeCostLeaf = leafCost;
        levelData.levelUpgradeCostSeedInstant = seedInstantCost;
        levelData.levelUpgradeBlockInterval = blockInterval;
        levelData.productionRatePlantLifetimePerDay = lifetimePerDay;
        levelData.productionRatePlantPointsPerDay = pointsPerDay;

        emit VillageLevelAdded(
            buildingId,
            newLevel,
            leafCost,
            seedInstantCost,
            blockInterval,
            lifetimePerDay,
            pointsPerDay
        );
    }

    function villageGetLevelConfig(
        uint8 buildingId,
        uint8 level
    )
        external
        view
        returns (
            bool enabled,
            uint8 maxLevel,
            uint256 leafCost,
            uint256 seedInstantCost,
            uint256 blockInterval,
            uint256 lifetimePerDay,
            uint256 pointsPerDay
        )
    {
        LibVillageStorage.VillageBuildingType storage building = _sV().villageBuildingTypes[buildingId];
        enabled = building.enabled;
        maxLevel = building.maxLevel;
        require(level > 0 && level <= maxLevel, "invalid level");

        LibVillageStorage.LevelData storage levelData = building.levelData[level];

        leafCost = levelData.levelUpgradeCostLeaf;
        seedInstantCost = levelData.levelUpgradeCostSeedInstant;
        blockInterval = levelData.levelUpgradeBlockInterval;
        lifetimePerDay = levelData.productionRatePlantLifetimePerDay;
        pointsPerDay = levelData.productionRatePlantPointsPerDay;
    }

    function villageForceSetLevel(
        uint256 landId,
        uint8 buildingId,
        uint8 newLevel
    ) external isAdmin {
        require(newLevel > 0, "invalid level");
        LibVillageStorage.Data storage s = _sV();
        LibVillageStorage.VillageBuildingType storage buildingType = s.villageBuildingTypes[buildingId];
        require(buildingType.enabled, "building disabled");
        require(newLevel <= buildingType.maxLevel, "level exceeds max");

        LibVillageStorage.VillageBulding storage building = s.villageBuildings[landId][buildingId];
        uint8 previousLevel = building.level;

        building.level = newLevel;
        building.blockHeightUpgradeInitiated = block.number;
        building.blockHeightUntilUpgradeDone = block.number;
        building.claimedBlockHeight = block.number;

        emit VillageLevelForced(landId, buildingId, previousLevel, newLevel);
    }

    function villageGetAllConfigs() external view returns (VillageBuildingConfigData[] memory configs) {
        uint8 count = LibVillageStorage.villageEnabledBuildingTypesCount();
        uint8[] memory buildingIds = LibVillageStorage.villageEnabledBuildingTypes();
        LibVillageStorage.Data storage s = _sV();

        configs = new VillageBuildingConfigData[](count);
        for (uint256 i = 0; i < count; i++) {
            uint8 buildingId = buildingIds[i];
            LibVillageStorage.VillageBuildingType storage buildingType = s.villageBuildingTypes[buildingId];

            VillageBuildingConfigData memory config;
            config.id = buildingId;
            config.enabled = buildingType.enabled;
            config.isProducingPlantPoints = buildingType.isProducingPlantPoints;
            config.isProducingPlantLifetime = buildingType.isProducingPlantLifetime;
            config.maxLevel = buildingType.maxLevel;

            uint8 maxLevel = buildingType.maxLevel;
            if (maxLevel > 0) {
                config.levels = new VillageLevelConfigData[](maxLevel);
                for (uint8 level = 1; level <= maxLevel; level++) {
                    LibVillageStorage.LevelData storage levelData = buildingType.levelData[level];
                    config.levels[level - 1] = VillageLevelConfigData({
                        level: level,
                        leafCost: levelData.levelUpgradeCostLeaf,
                        seedInstantCost: levelData.levelUpgradeCostSeedInstant,
                        blockInterval: levelData.levelUpgradeBlockInterval,
                        lifetimePerDay: levelData.productionRatePlantLifetimePerDay,
                        pointsPerDay: levelData.productionRatePlantPointsPerDay
                    });
                }
            }

            configs[i] = config;
        }
    }

    function villageSetAllConfigs(VillageBuildingConfigData[] calldata configs) external isAdmin {
        LibVillageStorage.Data storage s = _sV();

        for (uint256 i = 0; i < configs.length; i++) {
            VillageBuildingConfigData calldata config = configs[i];
            LibVillageStorage.VillageBuildingType storage buildingType = s.villageBuildingTypes[config.id];

            buildingType.enabled = config.enabled;
            buildingType.isProducingPlantPoints = config.isProducingPlantPoints;
            buildingType.isProducingPlantLifetime = config.isProducingPlantLifetime;
            buildingType.maxLevel = config.maxLevel;

            require(config.levels.length == config.maxLevel, "levels length mismatch");

            for (uint256 j = 0; j < config.levels.length; j++) {
                VillageLevelConfigData calldata levelConfig = config.levels[j];
                require(levelConfig.level >= 1, "invalid level id");
                require(levelConfig.level <= config.maxLevel, "level exceeds max");

                LibVillageStorage.LevelData storage levelData = buildingType.levelData[levelConfig.level];
                levelData.levelUpgradeCostLeaf = levelConfig.leafCost;
                levelData.levelUpgradeCostSeedInstant = levelConfig.seedInstantCost;
                levelData.levelUpgradeBlockInterval = levelConfig.blockInterval;
                levelData.productionRatePlantLifetimePerDay = levelConfig.lifetimePerDay;
                levelData.productionRatePlantPointsPerDay = levelConfig.pointsPerDay;
            }

            emit VillageConfigBatchUpdated(config.id);
        }
    }

    function questSetDifficultyConfig(
        QuestDifficultyLevel difficulty,
        uint256 durationInBlocks,
        uint256 cooldownInBlocks,
        uint256 rewardMultiplier
    ) external isAdmin {
        require(durationInBlocks > 0, "duration=0");
        require(cooldownInBlocks > 0, "cooldown=0");
        require(rewardMultiplier > 0, "multiplier=0");

        QuestDifficulty storage config = _sQ().questDifficulties[difficulty];
        config.difficulty = difficulty;
        config.durationInBlocks = durationInBlocks;
        config.cooldownInBlocks = cooldownInBlocks;
        config.rewardMultiplier = rewardMultiplier;

        emit QuestDifficultyUpdated(difficulty, durationInBlocks, cooldownInBlocks, rewardMultiplier);
    }

    function questGetDifficultyConfig(
        QuestDifficultyLevel difficulty
    )
        external
        view
        returns (
            uint256 durationInBlocks,
            uint256 cooldownInBlocks,
            uint256 rewardMultiplier
        )
    {
        QuestDifficulty storage config = _sQ().questDifficulties[difficulty];
        return (config.durationInBlocks, config.cooldownInBlocks, config.rewardMultiplier);
    }

    // Reward Range Configuration Events
    event QuestRewardRangeUpdated(
        string rewardType,
        uint256 oldMin,
        uint256 newMin,
        uint256 oldMax,
        uint256 newMax
    );
    event QuestRewardRangesInitialized();

    // Migration function to initialize reward ranges if they're zero (for existing deployments)
    function questInitializeRewardRanges() external isAdmin {
        LibQuestStorage.Data storage s = _sQ();
        
        // Only initialize if values are zero (not yet initialized)
        if (s.minSeedReward == 0) {
            s.minSeedReward = 1 ether;
            s.maxSeedReward = 10 ether;
            
            s.minLeafReward = 1 ether;
            s.maxLeafReward = 50 ether * 3285; // 3285 = 69 billion / 21 million
            
            s.minPlantLifetimeReward = 1 hours;
            s.maxPlantLifetimeReward = 12 hours;
            
            s.minPlantPointsReward = 1 * 10 ** LibConstants.PLANT_POINT_DECIMALS;
            s.maxPlantPointsReward = 100 * 10 ** LibConstants.PLANT_POINT_DECIMALS;
            
            s.minXpReward = 1 * 10 ** LibConstants.XP_DECIMALS;
            s.maxXpReward = 5 * 10 ** LibConstants.XP_DECIMALS;
            
            emit QuestRewardRangesInitialized();
        }
    }

    // SEED Reward Range
    function questSetSeedRewardRange(uint256 minReward, uint256 maxReward) external isAdmin {
        require(minReward > 0, "min reward must be > 0");
        require(maxReward >= minReward, "max must be >= min");
        LibQuestStorage.Data storage s = _sQ();
        uint256 oldMin = s.minSeedReward;
        uint256 oldMax = s.maxSeedReward;
        s.minSeedReward = minReward;
        s.maxSeedReward = maxReward;
        emit QuestRewardRangeUpdated("SEED", oldMin, minReward, oldMax, maxReward);
    }

    function questGetSeedRewardRange() external view returns (uint256 minReward, uint256 maxReward) {
        LibQuestStorage.Data storage s = _sQ();
        return (s.minSeedReward, s.maxSeedReward);
    }

    // LEAF Reward Range
    function questSetLeafRewardRange(uint256 minReward, uint256 maxReward) external isAdmin {
        require(minReward > 0, "min reward must be > 0");
        require(maxReward >= minReward, "max must be >= min");
        LibQuestStorage.Data storage s = _sQ();
        uint256 oldMin = s.minLeafReward;
        uint256 oldMax = s.maxLeafReward;
        s.minLeafReward = minReward;
        s.maxLeafReward = maxReward;
        emit QuestRewardRangeUpdated("LEAF", oldMin, minReward, oldMax, maxReward);
    }

    function questGetLeafRewardRange() external view returns (uint256 minReward, uint256 maxReward) {
        LibQuestStorage.Data storage s = _sQ();
        return (s.minLeafReward, s.maxLeafReward);
    }

    // PLANT_LIFETIME Reward Range
    function questSetPlantLifetimeRewardRange(uint256 minReward, uint256 maxReward) external isAdmin {
        require(minReward > 0, "min reward must be > 0");
        require(maxReward >= minReward, "max must be >= min");
        LibQuestStorage.Data storage s = _sQ();
        uint256 oldMin = s.minPlantLifetimeReward;
        uint256 oldMax = s.maxPlantLifetimeReward;
        s.minPlantLifetimeReward = minReward;
        s.maxPlantLifetimeReward = maxReward;
        emit QuestRewardRangeUpdated("PLANT_LIFETIME", oldMin, minReward, oldMax, maxReward);
    }

    function questGetPlantLifetimeRewardRange() external view returns (uint256 minReward, uint256 maxReward) {
        LibQuestStorage.Data storage s = _sQ();
        return (s.minPlantLifetimeReward, s.maxPlantLifetimeReward);
    }

    // PLANT_POINTS Reward Range
    function questSetPlantPointsRewardRange(uint256 minReward, uint256 maxReward) external isAdmin {
        require(minReward > 0, "min reward must be > 0");
        require(maxReward >= minReward, "max must be >= min");
        LibQuestStorage.Data storage s = _sQ();
        uint256 oldMin = s.minPlantPointsReward;
        uint256 oldMax = s.maxPlantPointsReward;
        s.minPlantPointsReward = minReward;
        s.maxPlantPointsReward = maxReward;
        emit QuestRewardRangeUpdated("PLANT_POINTS", oldMin, minReward, oldMax, maxReward);
    }

    function questGetPlantPointsRewardRange() external view returns (uint256 minReward, uint256 maxReward) {
        LibQuestStorage.Data storage s = _sQ();
        return (s.minPlantPointsReward, s.maxPlantPointsReward);
    }

    // XP Reward Range
    function questSetXpRewardRange(uint256 minReward, uint256 maxReward) external isAdmin {
        require(minReward > 0, "min reward must be > 0");
        require(maxReward >= minReward, "max must be >= min");
        LibQuestStorage.Data storage s = _sQ();
        uint256 oldMin = s.minXpReward;
        uint256 oldMax = s.maxXpReward;
        s.minXpReward = minReward;
        s.maxXpReward = maxReward;
        emit QuestRewardRangeUpdated("XP", oldMin, minReward, oldMax, maxReward);
    }

    function questGetXpRewardRange() external view returns (uint256 minReward, uint256 maxReward) {
        LibQuestStorage.Data storage s = _sQ();
        return (s.minXpReward, s.maxXpReward);
    }

    // Batch get all reward ranges
    struct QuestRewardRanges {
        uint256 minSeedReward;
        uint256 maxSeedReward;
        uint256 minLeafReward;
        uint256 maxLeafReward;
        uint256 minPlantLifetimeReward;
        uint256 maxPlantLifetimeReward;
        uint256 minPlantPointsReward;
        uint256 maxPlantPointsReward;
        uint256 minXpReward;
        uint256 maxXpReward;
    }

    function questGetAllRewardRanges() external view returns (QuestRewardRanges memory ranges) {
        LibQuestStorage.Data storage s = _sQ();
        return QuestRewardRanges({
            minSeedReward: s.minSeedReward,
            maxSeedReward: s.maxSeedReward,
            minLeafReward: s.minLeafReward,
            maxLeafReward: s.maxLeafReward,
            minPlantLifetimeReward: s.minPlantLifetimeReward,
            maxPlantLifetimeReward: s.maxPlantLifetimeReward,
            minPlantPointsReward: s.minPlantPointsReward,
            maxPlantPointsReward: s.maxPlantPointsReward,
            minXpReward: s.minXpReward,
            maxXpReward: s.maxXpReward
        });
    }
}