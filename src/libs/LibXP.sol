// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibLandStorage } from "../libs/LibLandStorage.sol";
//import  "../libs/LibAppStorage.sol";
//import  "../shared/Structs.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
//import {LibLandStorage} from "./LibLandStorage.sol";
import {LibERC721} from "./LibERC721.sol";
import {LibXPStorage} from "./LibXPStorage.sol";

library LibXP {

    // Constant for decimal precision in XP system
    uint256 private constant XP_DECIMALS = 1 ether; // 1e18

    /// @notice Converts raw XP to decimal representation
    /// @param rawXP The raw XP value
    /// @return The XP value with decimal precision
    function _toDecimalXP(uint256 rawXP) internal pure returns (uint256) {
        return rawXP * XP_DECIMALS;
    }

    /// @notice Converts decimal XP to raw representation
    /// @param decimalXP The XP value with decimal precision
    /// @return The raw XP value
    function _fromDecimalXP(uint256 decimalXP) internal pure returns (uint256) {
        return decimalXP / XP_DECIMALS;
    }

    /// @notice Internal function to access NFT storage
    /// @return data The LibLandStorage.Data struct
    function _sN() internal pure returns (LibLandStorage.Data storage data) {
        data = LibLandStorage.data();
    }

    function _sXP() internal pure returns (LibXPStorage.Data storage data) {
        data = LibXPStorage.data();
    }


    // /// @notice Internal function to access AppStorage
    // /// @return data The AppStorage struct
    // function _sA() internal pure returns (AppStorage storage data) {
    //     data = LibAppStorage.diamondStorage();
    // }


    /// @notice Adds experience points to a land
    /// @param tokenId The ID of the token to add experience points to
    /// @param points The amount of experience points to add
    function pushExperiencePoints(uint256 tokenId, uint256 points) internal {
        require(LibERC721._exists(tokenId), "NFT: Token does not exist");
        require(points > 0, "LibLand: Experience points must be greater than zero");

        // Effects
        LibLandStorage.Data storage s = _sN();
        s.experiencePoints[tokenId] += points;

    }

    // Constants for XP calculations
    uint256 private constant ETHER = 1e18;

    function getLeafUpgradeXP(uint8 level) internal pure returns (uint256) {
        if (level == 1) return 10 * ETHER;
        if (level == 2) return 20 * ETHER;
        if (level == 3) return 30 * ETHER;
        revert("LibXP: Invalid level");
    }

    function getSeedSpeedUpXP(uint8 level) internal pure returns (uint256) {
        if (level == 1) return 20 * ETHER;
        if (level == 2) return 40 * ETHER;
        if (level == 3) return 60 * ETHER;
        revert("LibXP: Invalid level");
    }

    /// @notice Calculates XP for leaf upgrades
    /// @param currentLevel The current level of the building
    /// @return xp The amount of XP to be awarded
    function calculateLeafUpgradeXP(uint8 currentLevel) internal pure returns (uint256 xp) {
        //require(currentLevel < 3, "LibXP: Invalid level for XP calculation");
        return getLeafUpgradeXP(currentLevel);
    }

    /// @notice Calculates XP for seed speed-ups
    /// @param currentLevel The current level of the building
    /// @return xp The amount of XP to be awarded
    function calculateSeedSpeedUpXP(uint8 currentLevel) internal pure returns (uint256 xp) {
        //require(currentLevel < 3, "LibXP: Invalid level for XP calculation");
        return getSeedSpeedUpXP(currentLevel);
    }

    // Constant for cooldown period (24 hours)
    uint256 private constant CLAIM_COOLDOWN_PERIOD = 24 hours;

    // Constant for claim reward
    uint256 private constant CLAIM_REWARD = 1 ether;

    // Event for XP claim
    event VillageProductionXPClaimed(uint256 indexed landId, uint256 indexed buildingId, uint256 claimTime, uint256 xpAwarded);

    // Add this new event declaration
    event VillageProductionXPClaimCooldownActive(uint256 indexed landId, uint256 indexed buildingId, uint256 currentTime, uint256 cooldownEndTime);

    /// @notice Pushes experience points for village production claim and manages cooldown
    /// @param landId The ID of the land
    /// @param buildingId The ID of the building
    /// @return cooldownActive Boolean indicating if the cooldown is still active
    /// @return xpAwarded Amount of XP awarded
    function pushExperiencePointsVillageClaimProduction(uint256 landId, uint256 buildingId) internal returns (bool cooldownActive, uint256 xpAwarded) {
        LibXPStorage.Data storage s = _sXP();
        uint256 currentTime = block.timestamp;
        uint256 lastClaimTime = s.landVillageBuildingXPClaimCoolDown[landId][buildingId];

        if (currentTime - lastClaimTime < CLAIM_COOLDOWN_PERIOD) {
            // Emit an event to indicate that the cooldown is still active
            emit VillageProductionXPClaimCooldownActive(landId, buildingId, currentTime, lastClaimTime + CLAIM_COOLDOWN_PERIOD);
            return (true, 0); // Cooldown is still active, no XP awarded
        }

        // Update the last claim time
        s.landVillageBuildingXPClaimCoolDown[landId][buildingId] = currentTime;

        // Award XP
        xpAwarded = CLAIM_REWARD;
        pushExperiencePoints(landId, xpAwarded);

        // Emit the event
        emit VillageProductionXPClaimed(landId, buildingId, currentTime, xpAwarded);

        return (false, xpAwarded); // Cooldown is not active, XP awarded
    }

}

