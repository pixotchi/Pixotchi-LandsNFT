// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

//import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {LibERC721} from "./LibERC721.sol";
import {LibAccessControl2Storage} from "./LibAccessControl2Storage.sol";
import { LibDiamond } from "lib/diamond-2-hardhat/contracts/libraries/LibDiamond.sol";

    error AccessControlPaused();
    error AccessControlWhitelistOnly();
    error AccessControlNotWhitelisted();
    error AccessControlTokenDoesNotExist();
    error AccessControlNotOwnerOrApproved();
    error AccessControlCallerMustBeAdmin();

abstract contract AccessControl2 {

    modifier isAdmin() {

        address _sender = msg.sender; //for now

        if (LibDiamond.contractOwner() != _sender) {
            revert AccessControlCallerMustBeAdmin();
        }
        _;
    }


    modifier isGranted() {

        address _sender = msg.sender; //for now

        LibAccessControl2.isGranted(_sender);
                
        _;
    }

    modifier isApproved(uint256 _tokenId) {

        address _sender = msg.sender; //for now

        LibAccessControl2.isGranted(_sender);
        LibAccessControl2.isApproved(_tokenId, _sender);

        
        _;
    }

    modifier isMinted(uint256 tokenId) {
        //IERC721(address(this)).exists(tokenId)
        //require(IERC721(address(this)).exists(tokenId), "NFT: Token does not exist");
        require(LibERC721._exists(tokenId), "NFT: Token does not exist");
        _;
    }

}

library LibAccessControl2 {

    function isGranted(address _sender) internal view returns (bool) {


        if (LibAccessControl2.getPaused()) {
            revert AccessControlPaused();
        }
        
        if (LibAccessControl2.getWhitelistOnly()) {
            if (!LibAccessControl2.getWhitelistAddress(_sender)) {
                revert AccessControlNotWhitelisted();
            }
        }
        return true;
    }

    function isApproved(uint256 _tokenId, address _sender) internal view returns (bool) {

        if (!LibERC721._exists(_tokenId)) {
            revert AccessControlTokenDoesNotExist();
        }
        
        if (LibERC721._requireOwned(_tokenId) != _sender && LibERC721._getApproved(_tokenId) != _sender) {
            revert AccessControlNotOwnerOrApproved();
        }

        return true;
    }


    function _sAC() internal pure returns (LibAccessControl2Storage.Data storage data) {
        data = LibAccessControl2Storage.data();
    }

    // Getter for paused
    function getPaused() internal view returns (bool) {
        return _sAC().paused;
    }

    // Setter for paused
    function setPaused(bool _paused) internal {
        _sAC().paused = _paused;
    }

    // Getter for whitelistOnly
    function getWhitelistOnly() internal view returns (bool) {
        return _sAC().whitelistOnly;
    }

    // Setter for whitelistOnly
    function setWhitelistOnly(bool _whitelistOnly) internal {
        _sAC().whitelistOnly = _whitelistOnly;
    }

    // Getter for whitelistAddress
    function getWhitelistAddress(address _address) internal view returns (bool) {
        return _sAC().whitelistAddress[_address];
    }

    // Setter for whitelistAddress
    function setWhitelistAddress(address _address, bool _isWhitelisted) internal {
        _sAC().whitelistAddress[_address] = _isWhitelisted;
    }

    // Batch setter for whitelistAddress
    function batchSetWhitelistAddresses(address[] memory _addresses, bool _isWhitelisted) internal {
        LibAccessControl2Storage.Data storage s = _sAC();
        for (uint256 i = 0; i < _addresses.length; i++) {
            s.whitelistAddress[_addresses[i]] = _isWhitelisted;
        }
    }
}
