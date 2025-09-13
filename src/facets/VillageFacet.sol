// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {LibLandStorage} from "../libs/LibLandStorage.sol";
import {LibAppStorage, AppStorage} from "../libs/LibAppStorage.sol";
import {NFTModifiers} from "../libs/LibNFT.sol";
import {LibLand} from "../libs/LibLand.sol";
import "../shared/Structs.sol";
import {LibVillage} from "../libs/LibVillage.sol";
import {LibPayment} from "../libs/LibPayment.sol";
import {LibXP} from "../libs/LibXP.sol";
import {AccessControl2} from "../libs/libAccessControl2.sol";

contract VillageFacet is AccessControl2 {


    /// @notice Internal function to access NFT storage
    /// @return data The LibLandStorage.Data struct
    function _sN() internal pure returns (LibLandStorage.Data storage data) {
        data = LibLandStorage.data();
    }

    /// @notice Internal function to access AppStorage
    /// @return data The AppStorage struct
    function _sA() internal pure returns (AppStorage storage data) {
        data = LibAppStorage.diamondStorage();
    }





    /// @notice Get all village buildings for a given land ID
    /// @param landId The ID of the land
    /// @return villageBuildings An array of VillageBuilding structs containing the building information
    function villageGetVillageBuildingsByLandId(uint256 landId) public view isMinted(landId) returns (VillageBuilding[] memory villageBuildings) {
        return LibVillage._villageGetBuildingsByLandId(landId);
    }

    /// @notice Upgrade a village building using leaves
    /// @param landId The ID of the land
    /// @param buildingId The ID of the building to upgrade
    function villageUpgradeWithLeaf(uint256 landId, uint8 buildingId) public isApproved(landId) {
        (uint256 upgradeCost, uint256 xp) = LibVillage._villageUpgradeWithLeaf(landId, buildingId);
        LibXP.pushExperiencePoints(landId, xp);
        LibPayment.paymentPayWithLeaf(msg.sender, upgradeCost);
    }

    /// @notice Speed up a village building upgrade using seeds
    /// @param landId The ID of the land
    /// @param buildingId The ID of the building to speed up
    function villageSpeedUpWithSeed(uint256 landId, uint8 buildingId) public isApproved(landId) {
        (uint256 speedUpCost, uint256 xp) = LibVillage._villageSpeedUpWithSeed(landId, buildingId);
        LibXP.pushExperiencePoints(landId, xp);
        LibPayment.paymentPayWithSeed(msg.sender, speedUpCost);
    }

    /// @notice Claim production from a village building
    /// @param landId The ID of the land
    /// @param buildingId The ID of the building to claim production from
    function villageClaimProduction(uint256 landId, uint8 buildingId) public isApproved(landId) {
        LibVillage._villageClaimProduction(landId, buildingId);
        LibXP.pushExperiencePointsVillageClaimProduction(landId, buildingId);
    }

//    function townUpgradeWithLeaf(uint256 landId, uint8 buildingId) public exists(landId) {
//        //TODO: implement actual logic to upgrade town building
//    }
//
//    function townSpeedUpWithSeed(uint256 landId, uint8 buildingId) public exists(landId) {
//        //TODO: implement actual logic to upgrade town building
//    }
//
//    function claimVillageProduction(uint256 landId, uint8 buildingId) public exists(landId) {
//        //TODO: implement actual logic to claim village production
//    }

    







}