// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibLandStorage } from "../libs/LibLandStorage.sol";
import { LibAppStorage, AppStorage } from "../libs/LibAppStorage.sol";
import { LibDiamond } from 'lib/diamond-2-hardhat/contracts/libraries/LibDiamond.sol';
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {INFTFacet} from "../interfaces/INFTFacet.sol";
import { LibVillageStorage } from "../libs/LibVillageStorage.sol"; 
import { LibTownStorage } from "../libs/LibTownStorage.sol";
import { LibQuestStorage } from "../libs/LibQuestStorage.sol";
import { LibAccessControl2Storage } from "../libs/LibAccessControl2Storage.sol";
//import { LibPaymentStorage } from "../libs/LibPaymentStorage.sol";
import { LibMintControlStorage } from "../libs/LibMintControlStorage.sol";
import { LibMarketPlaceStorage } from "../libs/LibMarketPlaceStorage.sol";

contract InitDiamond /*is NFTInit*/ {
  event InitializeDiamond(address sender);

  /// @notice Internal function to access NFT storage
  /// @return data The LibLandStorage.Data struct
  function _sD() internal pure returns (LibDiamond.DiamondStorage storage data) {
    data = LibDiamond.diamondStorage();
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

  function init() external  {
    LibLandStorage.initializeLandStorage();
    LibVillageStorage.initializeVillageStorage();
    //LibPaymentStorage.initializePaymentStorage();
    LibTownStorage.initializeTownStorage();

    LibQuestStorage.initializeQuestStorage();

    LibAccessControl2Storage.initAccessControl2Storage();

    LibMintControlStorage.initMintControlStorage();

    LibMarketPlaceStorage.initializeMarketplace();


    _sD().supportedInterfaces[0x01ffc9a7] = true; // ERC165 interface ID for ERC165.
    _sD().supportedInterfaces[0x80ac58cd] = true;  // ERC165 interface ID for ERC721.
    _sD().supportedInterfaces[0x5b5e139f] = true; // ERC165 interface ID for ERC721Metadata.
    _sD().supportedInterfaces[type(IERC721Enumerable).interfaceId] = true; // ERC165 interface ID for IERC721Enumerable.

    //NFTInit.__ERC721A_init("Land01", "LAND01");
    INFTFacet(address(this)).initNFTFacet(); //not optimal
    emit InitializeDiamond(msg.sender);

  }
}