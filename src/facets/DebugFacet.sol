/*
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibLandStorage } from "../libs/LibLandStorage.sol";
import { LibAppStorage, AppStorage } from "../libs/LibAppStorage.sol";

contract DebugFacet {



    /// @notice Get the diamond initialization status
    /// @return Whether the diamond is initialized
    function debugGetAppDiamondInitialized() external view returns (bool) {
        return _sA().diamondInitialized;
    }

    /// @notice Get the initialization number of the NFT storage
    /// @return The initialization number
    function debugGetNftInitializationNumber() external view returns (uint256) {
        return _sN().initializationNumber;
    }

    /// @notice Set the max supply of LAND
    /// @param _maxSupply The new max supply value
    function debugSetLandMaxSupply(uint256 _maxSupply) external {
        _sN().maxSupply = _maxSupply;
    }

    /// @notice Set the boundaries for x and y coordinates
    /// @param _minX The new minimum x coordinate
    /// @param _maxX The new maximum x coordinate
    /// @param _minY The new minimum y coordinate
    /// @param _maxY The new maximum y coordinate
    function debugSetLandBoundaries(int256 _minX, int256 _maxX, int256 _minY, int256 _maxY) external {
        LibLandStorage.Data storage s = _sN();
        s.minX = _minX;
        s.maxX = _maxX;
        s.minY = _minY;
        s.maxY = _maxY;
    }

    /// @notice Set the coordinates for a specific token ID
    /// @param _tokenId The token ID to set coordinates for
    /// @param _x The x coordinate
    /// @param _y The y coordinate
    /// @param _occupied Whether the coordinates are occupied
    function debugSetLandCoordinates(uint256 _tokenId, int256 _x, int256 _y, bool _occupied) external {
        LibLandStorage.Data storage s = _sN();
        s.tokenCoordinates[_tokenId] = LibLandStorage.Coordinates(_x, _y, _occupied);
        s.coordinateToTokenId[_x][_y] = _tokenId;
    }

    /// @notice Set the mint date for a specific token ID
    /// @param _tokenId The token ID to set the mint date for
    /// @param _mintDate The mint date timestamp
    function debugSetLandMintDate(uint256 _tokenId, uint256 _mintDate) external {
        _sN().mintDate[_tokenId] = _mintDate;
    }

    /// @notice Set the name for a specific token ID
    /// @param _tokenId The token ID to set the name for
    /// @param _name The new name for the land
    function debugSetLandName(uint256 _tokenId, string calldata _name) external {
        _sN().name[_tokenId] = _name;
    }

    /// @notice Set the experience points for a specific token ID
    /// @param _tokenId The token ID to set the experience points for
    /// @param _experiencePoints The new experience points value
    function debugSetLandExperiencePoints(uint256 _tokenId, uint256 _experiencePoints) external {
        _sN().experiencePoints[_tokenId] = _experiencePoints;
    }

    /// @notice Set the accumulated plant points for a specific token ID
    /// @param _tokenId The token ID to set the accumulated plant points for
    /// @param _plantPoints The new accumulated plant points value
    function debugSetLandAccumulatedPlantPoints(uint256 _tokenId, uint256 _plantPoints) external {
        _sN().accumulatedPlantPoints[_tokenId] = _plantPoints;
    }

    /// @notice Set the accumulated plant lifetime for a specific token ID
    /// @param _tokenId The token ID to set the accumulated plant lifetime for
    /// @param _plantLifetime The new accumulated plant lifetime value
    function debugSetLandAccumulatedPlantLifetime(uint256 _tokenId, uint256 _plantLifetime) external {
        _sN().accumulatedPlantLifetime[_tokenId] = _plantLifetime;
    }

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


}*/
