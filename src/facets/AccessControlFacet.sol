// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {LibLandStorage} from "../libs/LibLandStorage.sol";
import {LibAppStorage, AppStorage} from "../libs/LibAppStorage.sol";
import {NFTModifiers} from "../libs/LibNFT.sol";
import {LibLand} from "../libs/LibLand.sol";
import "../shared/Structs.sol";
import {AccessControl2, LibAccessControl2} from "../libs/libAccessControl2.sol";
import {LibMintControlStorage} from "../libs/LibMintControlStorage.sol";

contract AccessControlFacet is AccessControl2 {

    function accessControlStatus(address _address) external view returns (bool _paused, bool _whitelistOnly, bool _isWhitelisted) {
        return (LibAccessControl2.getPaused(), LibAccessControl2.getWhitelistOnly(), LibAccessControl2.getWhitelistAddress(_address));
    }

    function accessControlSetPaused(bool _paused) external isAdmin {
        LibAccessControl2.setPaused(_paused);
    }

    function accessControlGetPaused() external view returns (bool) {
        return LibAccessControl2.getPaused();
    }

    function accessControlSetWhitelistOnly(bool _whitelistOnly) external isAdmin {
        LibAccessControl2.setWhitelistOnly(_whitelistOnly);
    }

    function accessControlGetWhitelistOnly() external view returns (bool) {
        return LibAccessControl2.getWhitelistOnly();
    }

    function accessControlSetWhitelistAddress(address _address, bool _isWhitelisted) external isAdmin {
        LibAccessControl2.setWhitelistAddress(_address, _isWhitelisted);
    }

    function accessControlGetWhitelistAddress(address _address) external view returns (bool) {
        return LibAccessControl2.getWhitelistAddress(_address);
    }

    function accessControlBatchSetWhitelistAddresses(address[] memory _addresses, bool _isWhitelisted) external isAdmin {
        LibAccessControl2.batchSetWhitelistAddresses(_addresses, _isWhitelisted);
    }



    function _sMC() internal pure returns (LibMintControlStorage.Data storage data) {
        data = LibMintControlStorage.data();
    }


    function mintControl(bool enabled) external isAdmin {
        _sMC().mintActive = enabled;
    }

    event MintPriceUpdated(uint256 oldPrice, uint256 newPrice);

    function mintControlSetPrice(uint256 newPrice) external isAdmin {
        require(newPrice > 0, "mint price must be > 0");
        LibMintControlStorage.Data storage s = _sMC();
        uint256 oldPrice = s.mintPrice;
        s.mintPrice = newPrice;
        emit MintPriceUpdated(oldPrice, newPrice);
    }
}