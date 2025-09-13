// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {AccessControl2} from "../libs/libAccessControl2.sol";
import {LibMintControlStorage} from "../libs/LibMintControlStorage.sol";

contract MintControlAdminFacet is AccessControl2 {
  event MintPriceUpdated(uint256 oldPrice, uint256 newPrice);
  event MintActiveUpdated(bool oldActive, bool newActive);

  function setMintPrice(uint256 newPrice) external isAdmin {
    require(newPrice > 0, "Mint price must be > 0");
    LibMintControlStorage.Data storage s = LibMintControlStorage.data();
    uint256 old = s.mintPrice;
    s.mintPrice = newPrice;
    emit MintPriceUpdated(old, newPrice);
  }

  function setMintActive(bool active) external isAdmin {
    LibMintControlStorage.Data storage s = LibMintControlStorage.data();
    bool old = s.mintActive;
    s.mintActive = active;
    emit MintActiveUpdated(old, active);
  }
}
