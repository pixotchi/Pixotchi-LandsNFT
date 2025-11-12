// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;
import "../shared/Structs.sol";
import "./LibConstants.sol";


library LibAccessControl2Storage {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("eth.pixotchi.land.accesscontrol2.storage");

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
    function initAccessControl2Storage() internal initializer(1) {
        Data storage s = data();

        //TODO: temporary
        s.paused = true;
        s.whitelistOnly = true;
        s.whitelistAddress[0x816795f1CD1603b0d1b172853D69b73800eC3359] = true;
        s.whitelistAddress[0x38dc5ED4FC0F64d3EecC52c2CdfD91Fc569fb926] = true;
        s.whitelistAddress[0x6583F8C38E576d81d32e48e87BE922aD88e49F38] = true;
        s.whitelistAddress[0xAbF9ffdB1CC9728fFf1B783C1322Cd71dc382aB8] = true;




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



    /// @notice Struct containing all the storage variables for LAND buildings
    struct Data {
        /// @notice The current initialization version number
        uint256 initializationNumber;

        bool paused;
        bool whitelistOnly;
        mapping(address => bool) whitelistAddress;
    }

}
