// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;
import "../shared/Structs.sol";
import "./LibConstants.sol";


library LibMintControlStorage {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("eth.pixotchi.land.mint.control.storage");

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
    function initMintControlStorage() internal initializer(1) {
        Data storage s = data();


        s.mintActive = false;

        s.mintPrice = 100 ether; //100 SEED TOKEN;




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

        bool mintActive;

        uint256 mintPrice;


    }

}
