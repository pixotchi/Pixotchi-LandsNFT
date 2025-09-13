// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;



import {LibERC721} from "./LibERC721.sol";
import {LibAccessControl2Storage} from "./LibAccessControl2Storage.sol";
import { LibDiamond } from "lib/diamond-2-hardhat/contracts/libraries/LibDiamond.sol";
import {LibMintControlStorage} from "./LibMintControlStorage.sol";


error MintControlMintNotActive();

abstract contract MintControl {


        modifier isMintActive() {
            if (!LibMintControl.isMintActive()) {
                revert MintControlMintNotActive();
            }
        _;
    }



}

library LibMintControl {

    function isMintActive() internal view returns (bool) {
        return _sMC().mintActive;
    }

    function getMintPrice() internal view returns (uint256) {
        return _sMC().mintPrice;
    }


    function _sMC() internal pure returns (LibMintControlStorage.Data storage data) {
        data = LibMintControlStorage.data();
    }

}
