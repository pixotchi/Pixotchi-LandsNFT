// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;
import "../shared/Structs.sol";
import "./LibConstants.sol";


library LibQuestStorage {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("eth.pixotchi.land.quest.storage");

    /// @notice Returns the diamond storage for LAND-related data
    /// @return ds The Data struct containing LAND storage
    function data() internal pure returns (Data storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }




    /// @notice Initializes the LAND storage with default values
    /// @dev This function can only be called once
    function initializeQuestStorage() internal initializer(1) {
        Data storage s = data();

        s.questDifficulties[QuestDifficultyLevel.EASY] = QuestDifficulty({
            difficulty: QuestDifficultyLevel.EASY,
            durationInBlocks: LibConstants.hoursToBlocks(3),
            cooldownInBlocks: LibConstants.hoursToBlocks(12),
            rewardMultiplier: 1
        });
        s.questDifficulties[QuestDifficultyLevel.MEDIUM] = QuestDifficulty({
            difficulty: QuestDifficultyLevel.MEDIUM,
            durationInBlocks: LibConstants.hoursToBlocks(6),
            cooldownInBlocks: LibConstants.hoursToBlocks(18),
            rewardMultiplier: 2
        });
        s.questDifficulties[QuestDifficultyLevel.HARD] = QuestDifficulty({
            difficulty: QuestDifficultyLevel.HARD,
            durationInBlocks: LibConstants.hoursToBlocks(12),
            cooldownInBlocks: LibConstants.hoursToBlocks(24),
            rewardMultiplier: 3
        });


    }

    /// @dev Error thrown when trying to initialize with a version lower than or equal to the current version
    /// @param currentVersion The current initialization version
    /// @param newVersion The new version attempted to initialize
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

    /*
            // Initialize quest difficulties
        questDifficulties[QuestDifficultyLevel.EASY] = QuestDifficulty({
            difficulty: QuestDifficultyLevel.EASY,
            durationInBlocks: hoursToBlocks(3),
            cooldownInBlocks: hoursToBlocks(12),
            rewardMultiplier: 1
        });

        questDifficulties[QuestDifficultyLevel.MEDIUM] = QuestDifficulty({
            difficulty: QuestDifficultyLevel.MEDIUM,
            durationInBlocks: hoursToBlocks(6),
            cooldownInBlocks: hoursToBlocks(18),
            rewardMultiplier: 2
        });

        questDifficulties[QuestDifficultyLevel.HARD] = QuestDifficulty({
            difficulty: QuestDifficultyLevel.HARD,
            durationInBlocks: hoursToBlocks(12),
            cooldownInBlocks: hoursToBlocks(24),
            rewardMultiplier: 3
        });
    */


    /// @notice Struct containing all the storage variables for LAND buildings
    struct Data {
        /// @notice The current initialization version number
        uint256 initializationNumber;
        //mapping(uint256 => mapping(uint256 => uint256)) landVillageBuildingXPClaimCoolDown;

        mapping(QuestDifficultyLevel => QuestDifficulty) questDifficulties;
        mapping(uint256 => mapping(uint256 => Quest)) landQuests; // landId => farmerSlotId => Quest
    }

}
