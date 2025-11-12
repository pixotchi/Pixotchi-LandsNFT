// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibLandStorage } from "../libs/LibLandStorage.sol";
import { LibLand } from "../libs/LibLand.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { ERC721EnumerableUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import { INFTFacet } from "../interfaces/INFTFacet.sol";
import { AccessControl2 } from "../libs/libAccessControl2.sol";
import { MintControl, LibMintControl } from "../libs/libMintControl.sol";
import {LibPayment} from "../libs/LibPayment.sol";
import {LibMetaData} from "../libs/LibMetaData.sol";

contract NFTFacet is
  ERC721EnumerableUpgradeable,
  INFTFacet,
  AccessControl2, MintControl /*is ERC721Upgradeable, ERC721QueryableUpgradeable*/
{

  event LandMinted(address indexed to, uint256 tokenId, uint256 mintPrice);

  function initNFTFacet() external /*isAdmin*/ initializer {
    __ERC721_init("Land", "LAND");
    _mint(msg.sender, _sN().nextTokenId++);
  }

  function mint() external isGranted isMintActive {
    _nftMintPayed(msg.sender);
    
  }

  /// @notice Internal function to mint NFTs with specific coordinate assignment
  /// @param to The address to mint the NFT to
  function _nftMintPayed(address to) internal {
    uint256 supply = totalSupply();
    require(supply + 1 <= _sN().maxSupply, "Exceeds max supply");

    uint256 _tokenId = _sN().nextTokenId++;

    LibLand._AssignLand(_tokenId);

    uint256 _mintPrice = LibMintControl.getMintPrice();
    LibPayment.paymentPayWithSeed(msg.sender, _mintPrice);

    _safeMint(to, _tokenId);

    emit LandMinted(to, _tokenId, _mintPrice);
  }

    /// @notice Internal function to mint NFTs with specific coordinate assignment
  /// @param to The address to mint the NFT to
  function _nftMintFree(address to) internal {
    uint256 supply = totalSupply();
    require(supply + 1 <= _sN().maxSupply, "Exceeds max supply");

    uint256 _tokenId = _sN().nextTokenId++;

    LibLand._AssignLand(_tokenId);

    //uint256 _mintPrice = LibMintControl.getMintPrice();
    //LibPayment.paymentPayWithSeed(msg.sender, _mintPrice);

    _safeMint(to, _tokenId);

    emit LandMinted(to, _tokenId, 0);
  }

  function _sN() internal pure returns (LibLandStorage.Data storage data) {
    data = LibLandStorage.data();
  }

  /// ERC721EnumerableUpgradeable Overrides

  function tokenOfOwnerByIndex(
    address owner,
    uint256 index
  ) public view virtual override returns (uint256) {
    return super.tokenOfOwnerByIndex(owner, index);
  }

  function totalSupply() public view virtual override returns (uint256) {
    return super.totalSupply();
  }

  function maxSupply() public view virtual returns (uint256) {
    return _sN().maxSupply;
  }

  function nftNextTokenId() public view virtual returns (uint256) {
      return _sN().nextTokenId;
  }

  /// ERC721 Overrides

  function balanceOf(
    address owner
  ) public view virtual override(IERC721, ERC721Upgradeable) returns (uint256) {
    return super.balanceOf(owner);
  }

  function ownerOf(
    uint256 tokenId
  ) public view virtual override(IERC721, ERC721Upgradeable) returns (address) {
    return super.ownerOf(tokenId);
  }

  function name() public view virtual override(ERC721Upgradeable) returns (string memory) {
    return super.name();
  }

  function symbol() public view virtual override(ERC721Upgradeable) returns (string memory) {
    return super.symbol();
  }

  function tokenURI(
    uint256 tokenId
  ) public view virtual override(ERC721Upgradeable) returns (string memory) {
    return LibMetaData.tokenURI(tokenId);
  }

  function contractURI() public pure returns (string memory) {
    return LibMetaData.contractURI();
  }

  function approve(
    address to,
    uint256 tokenId
  ) public virtual override(IERC721, ERC721Upgradeable) {
    super.approve(to, tokenId);
  }

  function getApproved(
    uint256 tokenId
  ) public view virtual override(IERC721, ERC721Upgradeable) returns (address) {
    return super.getApproved(tokenId);
  }

  function setApprovalForAll(
    address operator,
    bool approved
  ) public virtual override(IERC721, ERC721Upgradeable) {
    super.setApprovalForAll(operator, approved);
  }

  function isApprovedForAll(
    address owner,
    address operator
  ) public view virtual override(IERC721, ERC721Upgradeable) returns (bool) {
    return super.isApprovedForAll(owner, operator);
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override(IERC721, ERC721Upgradeable) {
    super.transferFrom(from, to, tokenId);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override(IERC721, ERC721Upgradeable) {
    super.safeTransferFrom(from, to, tokenId);
  }

  //TODO: audit this & unit & fuzz test
  /// @notice Transfers a token from the caller to another address
  /// @param to The address to transfer the token to
  /// @param tokenId The ID of the token to transfer
  /// @return success True if the transfer was successful
  function transfer(address to, uint256 tokenId) public virtual returns (bool success) {
    address owner = ownerOf(tokenId);
    require(owner == _msgSender(), "NFTFacet: transfer caller is not owner");
    require(to != address(0), "NFTFacet: transfer to the zero address");

    _transfer(owner, to, tokenId);
    return true;
  }

  /// @notice Returns an array of token IDs owned by a given address
  /// @param owner The address to query the tokens of
  /// @return An array of token IDs owned by the requested address
  function tokensOfOwner(address owner) public view returns (uint256[] memory) {
    return _tokensOfOwner(owner);
  }


  function exists(uint256 tokenId)  public view override returns (bool) {
    return super.exists(tokenId);
  }

  /*
      function exists(uint256 tokenId) public view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
  */

  //    function explicitOwnershipOf(uint256 tokenId) public view virtual override returns (TokenOwnership memory) {
  //        return super.explicitOwnershipOf(tokenId);
  //    }
  //
  //    function explicitOwnershipsOf(uint256[] calldata tokenIds) public view virtual override returns (TokenOwnership[] memory) {
  //        return super.explicitOwnershipsOf(tokenIds);
  //    }
  //
  //    function tokensOfOwnerIn(address owner, uint256 start, uint256 stop) public view virtual override returns (uint256[] memory) {
  //        return super.tokensOfOwnerIn(owner, start, stop);
  //    }
  //
  //    function tokensOfOwner(address owner) public view virtual override returns (uint256[] memory) {
  //        return super.tokensOfOwner(owner);
  //    }

  /// @notice Airdrops NFTs to multiple wallets
  /// @param recipients An array of wallet addresses to receive the airdropped NFTs
  /// @dev Only callable by admin
  function airdrop(address[] calldata recipients) external isAdmin {
    for (uint256 i = 0; i < recipients.length; i++) {
      _nftMintFree(recipients[i]);
    }
  }

}
