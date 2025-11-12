// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;
import "../shared/Structs.sol";
import "./LibConstants.sol";


library LibMarketPlaceStorage {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("eth.pixotchi.land.marketplace.storage");

    /// @notice Returns the diamond storage for LAND-related data
    /// @return ds The Data struct containing LAND storage
    function data() internal pure returns (Data storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function initializeMarketplace() internal initializer(1) {
        Data storage s = data();
        s.enabled = true;
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

    enum TokenType {
        A,
        B
    }

    struct Order {
        address seller;
        TokenType sellToken;
        uint256 amount;
        bool isActive;
        uint256 amountAsk;
        uint256 sellerLandId;
        //address buyer;
        //uint256 timestamp;
    }

    /// @notice Struct containing all the storage variables for LAND buildings
    struct Data {
        /// @notice The current initialization version number
        uint256 initializationNumber;
        //mapping(uint256 => mapping(uint256 => uint256)) landVillageBuildingXPClaimCoolDown;

        bool enabled;
        uint256 nextOrderId;
        mapping(uint256 => Order) orders;
        mapping(address => uint256[]) userOrders;
    }

}
