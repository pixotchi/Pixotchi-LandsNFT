// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

//import {LibLandStorage} from "../libs/LibLandStorage.sol";
//import {LibAppStorage, AppStorage} from "../libs/LibAppStorage.sol";
import {NFTModifiers} from "../libs/LibNFT.sol";
import {LibLand} from "../libs/LibLand.sol";
import "../shared/Structs.sol";
//import {LibVillage} from "../libs/LibVillage.sol";
import {LibPayment} from "../libs/LibPayment.sol";
import {LibXP} from "../libs/LibXP.sol";
import {LibQuest} from "../libs/LibQuest.sol";
import {LibERC721} from "../libs/LibERC721.sol";
import {AccessControl2} from "../libs/libAccessControl2.sol";

contract QuestFacet is AccessControl2 {

    event QuestStarted(uint256 indexed landId, QuestDifficultyLevel difficultyLevel, uint256 farmerSlotId);
    event QuestCommitted(uint256 indexed landId, uint256 farmerSlotId);
    event QuestFinalized(uint256 indexed landId, uint256 farmerSlotId, bool success, RewardType rewardType, uint256 rewardAmount);

    function questGetByLandId(uint256 landId) public view isMinted(landId) returns (Quest[] memory quests) {
        return LibQuest.getQuests(landId);
    }

    function questStart(uint256 landId, QuestDifficultyLevel difficultyLevel, uint256 farmerSlotId) public isApproved(landId) {
        LibQuest.startQuest(landId, difficultyLevel, farmerSlotId);
        emit QuestStarted(landId, difficultyLevel, farmerSlotId);
    }

    function questCommit(uint256 landId, uint256 farmerSlotId) public isApproved(landId) {
        LibQuest.commitQuest(landId, farmerSlotId);
        emit QuestCommitted(landId, farmerSlotId);
    }

    function questFinalize(uint256 landId, uint256 farmerSlotId) public isApproved(landId)
    returns (bool success, RewardType rewardType, uint256 rewardAmount) {
        (success, rewardType, rewardAmount) = LibQuest.finalizeQuest(landId, farmerSlotId);

        if (success && rewardAmount > 0) {
            if (rewardType == RewardType.SEED) {
                address owner = LibERC721._requireOwned(landId);
                LibPayment.rewardWithSeed(owner, rewardAmount);
            } else if (rewardType == RewardType.LEAF) {
                address owner = LibERC721._requireOwned(landId);
                LibPayment.rewardWithLeaf(owner, rewardAmount);
            } else if (rewardType == RewardType.XP) {
                LibXP.pushExperiencePoints(landId, rewardAmount);
            } else if (rewardType == RewardType.PLANT_POINTS) {
                LibLand._pushAccumulatedPlantPoints(landId, rewardAmount);
            } else if (rewardType == RewardType.PLANT_LIFE_TIME) {
                LibLand._pushAccumulatedPlantLifetime(landId, rewardAmount);
            } else {
                revert("Invalid reward type");
            }
        }

        emit QuestFinalized(landId, farmerSlotId, success, rewardType, rewardAmount);
        return (success, rewardType, rewardAmount);
    }

//     /// @notice Get all village buildings for a given land ID
//     /// @param landId The ID of the land
//     /// @return villageBuildings An array of VillageBuilding structs containing the building information
//     function villageGetVillageBuildingsByLandId(uint256 landId) public view exists(landId) returns (VillageBuilding[] memory villageBuildings) {
//         return LibVillage._villageGetBuildingsByLandId(landId);
//     }

//     /// @notice Upgrade a village building using leaves
//     /// @param landId The ID of the land
//     /// @param buildingId The ID of the building to upgrade
//     function villageUpgradeWithLeaf(uint256 landId, uint8 buildingId) public exists(landId) {
//         (uint256 upgradeCost, uint256 xp) = LibVillage._villageUpgradeWithLeaf(landId, buildingId);
//         LibXP.pushExperiencePoints(landId, xp);
//         LibPayment.paymentPayWithLeaf(msg.sender, upgradeCost);
//     }

//     /// @notice Speed up a village building upgrade using seeds
//     /// @param landId The ID of the land
//     /// @param buildingId The ID of the building to speed up
//     function villageSpeedUpWithSeed(uint256 landId, uint8 buildingId) public exists(landId) {
//         (uint256 speedUpCost, uint256 xp) = LibVillage._villageSpeedUpWithSeed(landId, buildingId);
//         LibXP.pushExperiencePoints(landId, xp);
//         LibPayment.paymentPayWithSeed(msg.sender, speedUpCost);
//     }

//     /// @notice Claim production from a village building
//     /// @param landId The ID of the land
//     /// @param buildingId The ID of the building to claim production from
//     function villageClaimProduction(uint256 landId, uint8 buildingId) public exists(landId) {
//         LibVillage._villageClaimProduction(landId, buildingId);
//         LibXP.pushExperiencePointsVillageClaimProduction(landId, buildingId);
//     }

// //    function townUpgradeWithLeaf(uint256 landId, uint8 buildingId) public exists(landId) {
// //        //TODO: implement actual logic to upgrade town building
// //    }
// //
// //    function townSpeedUpWithSeed(uint256 landId, uint8 buildingId) public exists(landId) {
// //        //TODO: implement actual logic to upgrade town building
// //    }
// //
// //    function claimVillageProduction(uint256 landId, uint8 buildingId) public exists(landId) {
// //        //TODO: implement actual logic to claim village production
// //    }


}