// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {LibLandStorage} from "../libs/LibLandStorage.sol";
import {LibAppStorage, AppStorage} from "../libs/LibAppStorage.sol";
import {NFTModifiers} from "../libs/LibNFT.sol";
import {LibLand} from "../libs/LibLand.sol";
import "../shared/Structs.sol";
import {LibTown} from "../libs/LibTown.sol";
import {LibPayment} from "../libs/LibPayment.sol";
import {LibXP} from "../libs/LibXP.sol";
import {AccessControl2} from "../libs/libAccessControl2.sol";
import {LibTownStorage} from  "../libs/LibTownStorage.sol";


contract TownFacet is AccessControl2 {


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


//
//
//
//    /// @notice Get all Town buildings for a given land ID
//    /// @param landId The ID of the land
//    /// @return TownBuildings An array of TownBuilding structs containing the building information
//    function TownGetTownBuildingsByLandId(uint256 landId) public view exists(landId) returns (TownBuilding[] memory TownBuildings) {
//        return LibTown._TownGetBuildingsByLandId(landId);
//    }
//
//    /// @notice Upgrade a Town building using leaves
//    /// @param landId The ID of the land
//    /// @param buildingId The ID of the building to upgrade
//    function TownUpgradeWithLeaf(uint256 landId, uint8 buildingId) public exists(landId) {
//        uint256 upgradeCost = LibTown._TownUpgradeWithLeaf(landId, buildingId);
//        LibPayment.paymentPayWithLeaf(msg.sender, upgradeCost);
//    }
//
//    /// @notice Speed up a Town building upgrade using seeds
//    /// @param landId The ID of the land
//    /// @param buildingId The ID of the building to speed up
//    function TownSpeedUpWithSeed(uint256 landId, uint8 buildingId) public exists(landId) {
//        uint256 speedUpCost = LibTown._TownSpeedUpWithSeed(landId, buildingId);
//        LibPayment.paymentPayWithSeed(msg.sender, speedUpCost);
//    }
//
//    /// @notice Claim production from a Town building
//    /// @param landId The ID of the land
//    /// @param buildingId The ID of the building to claim production from
//    function TownClaimProduction(uint256 landId, uint8 buildingId) public exists(landId) {
//        LibTown._TownClaimProduction(landId, buildingId);
//    }


    /// @notice Get all town buildings for a given land ID
    /// @param landId The ID of the land
    /// @return townBuildings An array of TownBuilding structs containing the building information
    function townGetBuildingsByLandId(uint256 landId) public view isMinted(landId) returns (TownBuilding[] memory townBuildings) {
        return LibTown._getBuildingsByLandId(landId);
    }

    //todo: create own facet for , getter and setter QuestHouse

    //todo: create own facet for , getter and setter MarketPlace
    //get swap ratio. return 2 swap ratios. SEED to LEAF and LEAF to SEED.
    //write fn: swapSeedToLeaf(uint256 amount)
    //write fn: swapLeafToSeed(uint256 amount)

    event TownUpgradedWithLeaf(uint256 indexed landId, uint8 indexed buildingId, uint256 upgradeCost, uint256 xp);
    event TownSpeedUpWithSeed(uint256 indexed landId, uint8 indexed buildingId, uint256 speedUpCost, uint256 xp);
    event TownUpgradedWithSeed(uint256 indexed landId, uint8 indexed buildingId, uint256 upgradeCost, uint256 xp);

    function townUpgradeWithLeaf(uint256 landId, uint8 buildingId) public isApproved(landId) {
        (uint256 upgradeCost, uint256 xp) = LibTown._upgradeWithLeaf(landId, buildingId);
        LibXP.pushExperiencePoints(landId, xp);
        LibPayment.paymentPayWithLeaf(msg.sender, upgradeCost);
        emit TownUpgradedWithLeaf(landId, buildingId, upgradeCost, xp);
    }

    function townSpeedUpWithSeed(uint256 landId, uint8 buildingId) public isApproved(landId) {
        (uint256 speedUpCost, uint256 xp) = LibTown._speedUpWithSeed(landId, buildingId);
        LibXP.pushExperiencePoints(landId, xp);
        LibPayment.paymentPayWithSeed(msg.sender, speedUpCost);
        emit TownSpeedUpWithSeed(landId, buildingId, speedUpCost, xp);
    }

    function townBuildMarketPlace(uint256 landId) external isApproved(landId) {
        uint8 buildingId = uint8(LibTownStorage.TownBuildingNaming.MARKET_PLACE);
        (uint256 upgradeCost, uint256 xp) = LibTown._upgradeWithSeed(landId, buildingId);
        LibXP.pushExperiencePoints(landId, xp);
        LibPayment.paymentPayWithSeed(msg.sender, upgradeCost);
        emit TownUpgradedWithSeed(landId, buildingId, upgradeCost, xp);
    }
    
//    function claimTownProduction(uint256 landId, uint8 buildingId) public exists(landId) {
//        //TODO: implement actual logic to claim Town production
//    }

    







}