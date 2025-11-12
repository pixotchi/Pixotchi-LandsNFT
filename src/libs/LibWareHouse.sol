// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibLand } from "../libs/LibLand.sol";
import "./LibWareHouseStorage.sol";
import "../shared/Structs.sol";
import {ILandToPlant} from "../shared/ILandToPlant.sol";

library LibWareHouse {

    ILandToPlant internal constant landToPlant_testnet = ILandToPlant(0x1723a3F01895c207954d09F633a819c210d758c4);
    ILandToPlant internal constant landToPlant = ILandToPlant(0xeb4e16c804AE9275a655AbBc20cD0658A91F9235); //mainnet

    event WareHousePlantPointsAssigned(uint256 indexed landId, uint256 indexed plantId, uint256 addedPoints, uint256 newPlantPoints);
    event WareHouseLifetimeAssigned(uint256 indexed landId, uint256 indexed plantId, uint256 lifetime, uint256 newLifetime);

    function landToPlantAssignPlantPoints(uint256 _landId, uint256 _plantId, uint256 _addedPoints) internal returns (uint256 _newPlantPoints) {
        LibLand._decreaseAccumulatedPlantPoints(_landId, _addedPoints);

        _newPlantPoints = landToPlant.landToPlantAssignPlantPoints(_plantId, _addedPoints);

        return _newPlantPoints;
    }

    function landToPlantAssignLifeTime(uint256 _landId, uint256 _plantId, uint256 _lifetime) internal returns (uint256 _newLifetime){
        LibLand._decreaseAccumulatedPlantLifetime(_landId, _lifetime);

        _newLifetime = landToPlant.landToPlantAssignLifeTime(_plantId, _lifetime);

        return _newLifetime;
    }


}
