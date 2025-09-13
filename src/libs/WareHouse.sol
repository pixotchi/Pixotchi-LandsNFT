// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "./LibWareHouseStorage.sol";
import "../shared/Structs.sol";

library LibWareHouse {


    function _sNB() internal pure returns (LibWareHouseStorage.Data storage data) {
        data = LibWareHouseStorage.data();
    }




}
