// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../shared/Structs.sol";
import "./LibQuestStorage.sol";
import "./LibTown.sol";
library LibQuest {

    /// @notice Internal function to access NFT Building storage
    /// @return data The LibLandBuildingStorage.Data struct
    function _sQ() internal pure returns (LibQuestStorage.Data storage data) {
        data = LibQuestStorage.data();
    }

    // Reward ranges
    uint256 internal constant MIN_SEED_REWARD = 1 ether;
    uint256 internal constant MAX_SEED_REWARD = 10 ether; //50 ether; //100 initial

    uint256 internal constant MIN_LEAF_REWARD = 1 ether;// * 3285; //3285 = 69 billion / 21 million
    uint256 internal constant MAX_LEAF_REWARD = 50 ether * 3285; //3285 = 69 billion / 21 million // 100 initial

    uint256 internal constant MIN_PLANT_LIFE_TIME_REWARD = 1 hours;
    uint256 internal constant MAX_PLANT_LIFE_TIME_REWARD = 12 hours;

    uint256 internal constant MIN_PLANT_POINTS_REWARD = 1 * 10 ** LibConstants.PLANT_POINT_DECIMALS;
    uint256 internal constant MAX_PLANT_POINTS_REWARD = 100 * 10 ** LibConstants.PLANT_POINT_DECIMALS;

    uint256 internal constant MIN_XP_REWARD = 1 * 10 ** LibConstants.XP_DECIMALS;
    uint256 internal constant MAX_XP_REWARD = 5 * 10 ** LibConstants.XP_DECIMALS;

    event QuestStarted(
        uint256 indexed landId,
        uint256 indexed farmerSlotId,
        QuestDifficultyLevel difficulty,
        uint256 startBlock,
        uint256 endBlock
    );

    event QuestCommitted(
        uint256 indexed landId,
        uint256 indexed farmerSlotId,
        //address indexed player,
        uint256 pseudoRndBlock
    );

    event QuestFinalized(
        uint256 indexed landId,
        uint256 indexed farmerSlotId,
        address indexed player,
        RewardType rewardType,
        uint256 amount
    );

    event QuestReset(
        uint256 indexed landId,
        uint256 indexed farmerSlotId,
        address indexed player
    );

    function _getQuestHouseLevel(uint256 landId) private view returns (uint256) {
        return LibTown.getBuildingLevel(landId, LibTownStorage.TownBuildingNaming.QUEST_HOUSE);
    }




// Transaction 1: Send farmer to a quest
    function startQuest(
        uint256 landId,
        QuestDifficultyLevel difficultyLevel,
        uint256 farmerSlotId
    ) internal {
        require(farmerSlotId < _getQuestHouseLevel(landId), "Farmer slot is too high");
        Quest storage quest = _sQ().landQuests[landId][farmerSlotId];

        require(block.number >= quest.coolDownBlock, "Farmer is on cooldown");

/*        require(
            !quest.exists || quest.completed,
            "Previous quest not completed"
        );*/
        require(
            quest.startBlock == 0,
            "Quest already in progress"
        );
        //require(!quest.exists, "Previous quest not completed");
        // require(
        //     !quest.exists,
        //     "Quest already in progress"
        // );

        QuestDifficulty storage difficulty = _sQ().questDifficulties[difficultyLevel];

        quest.difficulty = difficultyLevel;
        quest.startBlock = block.number;
        quest.endBlock = block.number + difficulty.durationInBlocks;
        quest.pseudoRndBlock = 0;
        //quest.completed = false;
        //quest.exists = true;
        //quest.rewardType = RewardType.SEED; // Default value, will be set later
        //quest.rewardAmount = 0;

        emit QuestStarted(
            landId,
            farmerSlotId,
            difficultyLevel,
            quest.startBlock,
            quest.endBlock
        );
    }

    // Transaction 2: Commit quest (after quest duration has passed)
    function commitQuest(uint256 landId, uint256 farmerSlotId) internal {
        require(farmerSlotId < _getQuestHouseLevel(landId), "Farmer slot is too high");

        Quest storage quest = _sQ().landQuests[landId][farmerSlotId];

        require(quest.startBlock != 0, "No quest found");
        //require(quest.exists, "No quest found");
        require(quest.endBlock <= block.number, "Quest not yet ended");
        require(quest.pseudoRndBlock == 0, "Quest already committed");

        // Assign pseudoRndBlock as current block number + 1
        quest.pseudoRndBlock = block.number + 1;

        emit QuestCommitted(
            landId,
            farmerSlotId,
            quest.pseudoRndBlock
        );
    }

// Transaction 3: Finalize quest and assign rewards
    function finalizeQuest(uint256 landId, uint256 farmerSlotId)  internal returns (bool success, RewardType rewardType, uint256 rewardAmount) {
        require(farmerSlotId < _getQuestHouseLevel(landId), "Farmer slot is too high");
        //uint256 landId = playerLandIds[msg.sender];
        //require(landId != 0, "Player has no land assigned");
        Quest storage quest = _sQ().landQuests[landId][farmerSlotId];

        //require(quest.exists, "No quest found");
        require(quest.startBlock != 0, "No quest found");
        require(
            quest.pseudoRndBlock != 0,
            "Quest has not been committed"
        );
        require(
            block.number >= quest.pseudoRndBlock,
            "Too early to finalize"
        );

        if (block.number > quest.pseudoRndBlock + 256) {
        // Too late to finalize, reset the quest
            resetQuest(landId, farmerSlotId);
            emit QuestReset(landId, farmerSlotId, msg.sender);
            return (false, RewardType.SEED, 0);
        }

        //require(!quest.completed, "Quest already finalized");

        // Get a pseudo-random number using the block hash
        bytes32 randomHash = blockhash(quest.pseudoRndBlock);
        uint256 randomNumber = uint256(randomHash);

        // Use the random number to assign a single reward
        (RewardType rewardType, uint256 rewardAmount) = assignRewards(randomNumber, quest.difficulty);

        // Record the reward in the quest struct
        //quest.rewardType = rewardType;
        //quest.rewardAmount = rewardAmount;

        // Mark quest as completed
        //quest.completed = true;
        quest.startBlock = 0;
        quest.endBlock = 0;
        //quest.exists = false;
        //quest.rewardType = 0;
        //quest.rewardAmount = 0;
        quest.difficulty = QuestDifficultyLevel.EASY;
        quest.pseudoRndBlock = 0;
        quest.coolDownBlock = block.number + _sQ().questDifficulties[quest.difficulty].cooldownInBlocks;


    emit QuestFinalized(
            landId,
            farmerSlotId,
            msg.sender,
            rewardType,
            rewardAmount
        );




        return (true, rewardType, rewardAmount);
    }

        // Assign a single reward based on random number and difficulty
    function assignRewards(
        uint256 randomNumber,
        QuestDifficultyLevel difficultyLevel
    ) private returns (RewardType, uint256) {
        // Randomly select one reward type
        uint256 rewardIndex = randomNumber % 5; // There are 5 reward types
        RewardType rewardType = RewardType(rewardIndex);

        uint256 rewardAmount;
        uint256 minReward;
        uint256 maxReward;

        // Determine min and max reward based on reward type
        if (rewardType == RewardType.SEED) {
            minReward = MIN_SEED_REWARD;
            maxReward = MAX_SEED_REWARD;
        } else if (rewardType == RewardType.LEAF) {
            minReward = MIN_LEAF_REWARD;
            maxReward = MAX_LEAF_REWARD;
        } else if (rewardType == RewardType.PLANT_LIFE_TIME) {
            minReward = MIN_PLANT_LIFE_TIME_REWARD;
            maxReward = MAX_PLANT_LIFE_TIME_REWARD;
        } else if (rewardType == RewardType.PLANT_POINTS) {
            minReward = MIN_PLANT_POINTS_REWARD;
            maxReward = MAX_PLANT_POINTS_REWARD;
        } else if (rewardType == RewardType.XP) {
            minReward = MIN_XP_REWARD;
            maxReward = MAX_XP_REWARD;
        }

        // Calculate reward amount
        uint256 rewardRange = maxReward - minReward + 1;
        rewardAmount = (randomNumber % rewardRange) + minReward;
        rewardAmount *= _sQ().questDifficulties[difficultyLevel].rewardMultiplier;

        if (rewardType == RewardType.XP) {
            rewardAmount = ((rewardAmount / LibConstants.XP_DECIMALS) * LibConstants.XP_DECIMALS) ;
        }

    // // Assign the reward (call dummy functions)
    //     if (rewardType == RewardType.SEED) {
    //         _assignSeedReward(rewardAmount);
    //     } else if (rewardType == RewardType.LEAF) {
    //         _assignLeafReward(rewardAmount);
    //     } else if (rewardType == RewardType.PLANT_LIFE_TIME) {
    //         _assignPlantLifeTimeReward(rewardAmount);
    //     } else if (rewardType == RewardType.PLANT_POINTS) {
    //         _assignPlantPointsReward(rewardAmount);
    //     } else if (rewardType == RewardType.XP) {
    //         _assignXpReward(rewardAmount);
    //     }

        return (rewardType, rewardAmount);
    }

    // // Dummy reward assignment functions
    // function _assignSeedReward(uint256 amount) private {
    // // Implement ERC20 transfer logic or any other logic
    // }

    // function _assignLeafReward(uint256 amount) private {
    // // Implement ERC20 transfer logic or any other logic
    // }

    // function _assignPlantLifeTimeReward(uint256 amount) private {
    // // Implement logic to increase plant lifetime
    // }

    // function _assignPlantPointsReward(uint256 amount) private {
    // // Implement logic to add plant points
    // }

    // function _assignXpReward(uint256 amount) private {
    // // Implement logic to add experience points
    // }

    // Reset quest
    function resetQuest(uint256 landId, uint256 farmerSlotId) private {
        //delete _sQ().landQuests[landId][farmerSlotId];
        //_sQ().landQuests[landId][farmerSlotId].exists = false;
        //_sQ().landQuests[landId][farmerSlotId].rewardType = 0;
        _sQ().landQuests[landId][farmerSlotId].startBlock = 0;
        _sQ().landQuests[landId][farmerSlotId].coolDownBlock = 0;
        _sQ().landQuests[landId][farmerSlotId].endBlock = 0;
        _sQ().landQuests[landId][farmerSlotId].pseudoRndBlock = 0;
        _sQ().landQuests[landId][farmerSlotId].difficulty = QuestDifficultyLevel.EASY;
        //_sQ().landQuests[landId][farmerSlotId].rewardAmount = 0;
    }

    // Get quest details for a specific landId and farmerSlotId
    function getQuest(uint256 landId, uint256 farmerSlotId) internal view returns (Quest memory) {
        return _sQ().landQuests[landId][farmerSlotId];
    }

    // Get all quests for a landId
    function getQuests(uint256 landId) internal view returns (Quest[] memory) {
        uint256 questHouseLevel = _getQuestHouseLevel(landId);
        if(questHouseLevel == 0) {
            return new Quest[](0);
        }
        Quest[] memory quests = new Quest[](questHouseLevel);
        for (uint256 i = 0; i < questHouseLevel; i++) {
            quests[i] = _sQ().landQuests[landId][i];
        }
        return quests;
    }
}
