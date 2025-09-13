// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

//import { LibLandStorage } from "../libs/LibLandStorage.sol";
//import { LibAppStorage, AppStorage } from "../libs/LibAppStorage.sol";
//import { LibDiamond } from 'lib/diamond-2-hardhat/contracts/libraries/LibDiamond.sol';
import  "../libs/LibQuestStorage.sol";
//import {AccessControl} from "../shared/AccessControl.sol";
import {AccessControl2} from "../libs/libAccessControl2.sol";


contract InitFacetTesting is AccessControl2 {

    /// @notice Internal function to access NFT Building storage
    /// @return data The LibLandBuildingStorage.Data struct
    function _sQ() internal pure returns (LibQuestStorage.Data storage data) {
        data = LibQuestStorage.data();
    }

 function questStorageUpdate() isAdmin() external   {

        _sQ().questDifficulties[QuestDifficultyLevel.EASY] = QuestDifficulty({
            difficulty: QuestDifficultyLevel.EASY,
            durationInBlocks: LibConstants.minutesToBlocks(1),//LibConstants.hoursToBlocks(3),
            cooldownInBlocks: LibConstants.minutesToBlocks(2), //LibConstants.hoursToBlocks(12),
            rewardMultiplier: 1
        });
        _sQ().questDifficulties[QuestDifficultyLevel.MEDIUM] = QuestDifficulty({
            difficulty: QuestDifficultyLevel.MEDIUM,
            durationInBlocks: LibConstants.minutesToBlocks(2),//LibConstants.hoursToBlocks(6),
            cooldownInBlocks: LibConstants.minutesToBlocks(3), //LibConstants.hoursToBlocks(18),
            rewardMultiplier: 2
        });

        _sQ().questDifficulties[QuestDifficultyLevel.HARD] = QuestDifficulty({
            difficulty: QuestDifficultyLevel.HARD,
            durationInBlocks: LibConstants.minutesToBlocks(3),//LibConstants.hoursToBlocks(12),
            cooldownInBlocks: LibConstants.minutesToBlocks(4),//LibConstants.hoursToBlocks(24),
            rewardMultiplier: 3
        });


 }



//  event InitializeDiamond(address sender);


//  /// @notice Internal function to access NFT storage
//  /// @return data The LibLandStorage.Data struct
//  function _sD() internal pure returns (LibDiamond.DiamondStorage storage data) {
//    data = LibDiamond.diamondStorage();
//  }

//  /// @notice Internal function to access NFT storage
//  /// @return data The LibLandStorage.Data struct
//  function _sN() internal pure returns (LibLandStorage.Data storage data) {
//    data = LibLandStorage.data();
//  }

//  /// @notice Internal function to access AppStorage
//  /// @return data The AppStorage struct
//  function _sA() internal pure returns (AppStorage storage data) {
//    data = LibAppStorage.diamondStorage();
//  }

//  /// @notice Modifier to ensure NFT storage is initialized only once
//  /// @dev Checks if NFT storage is uninitialized, runs the function, then sets it as initialized
//  modifier initializeAppStorage() {
//    require(!_sA().diamondInitialized, "diamond storage already initialized");
//    _;
//    _sA().diamondInitialized = true;
//    emit InitializeDiamond(msg.sender);

//  }

//  function initFacet() external initializeAppStorage {
//    LibLandStorage.initializeLandStorage();

//    _sD().supportedInterfaces[0x01ffc9a7] = true; // ERC165 interface ID for ERC165.
//    _sD().supportedInterfaces[0x80ac58cd] = true;  // ERC165 interface ID for ERC721.
//    _sD().supportedInterfaces[0x5b5e139f] = true; // ERC165 interface ID for ERC721Metadata.


//    emit InitializeDiamond(msg.sender);
//  }
}
