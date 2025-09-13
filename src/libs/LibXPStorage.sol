// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;


library LibXPStorage {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("eth.pixotchi.land.xp.storage");

    /// @notice Returns the diamond storage for LAND-related data
    /// @return ds The Data struct containing LAND storage
    function data() internal pure returns (Data storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }


    /// @notice Struct containing all the storage variables for LAND buildings
    struct Data {
        /// @notice The current initialization version number
        uint256 initializationNumber;
        mapping(uint256 => mapping(uint256 => uint256)) landVillageBuildingXPClaimCoolDown;
    }

}
