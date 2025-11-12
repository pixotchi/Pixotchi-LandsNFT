// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {LibLandStorage} from "../libs/LibLandStorage.sol";
import {ERC721AUpgradeable} from "lib_fork/ERC721A-Upgradeable/contracts/ERC721AUpgradeable.sol";
import {IERC721AUpgradeable} from "lib_fork/ERC721A-Upgradeable/contracts/IERC721AUpgradeable.sol";
import {ERC721AQueryableUpgradeable} from "lib_fork/ERC721A-Upgradeable/contracts/extensions/ERC721AQueryableUpgradeable.sol";
import {LibLand} from "../libs/LibLand.sol";

contract NFTFacet is ERC721AUpgradeable, ERC721AQueryableUpgradeable {

    function initNFTFacet() external initializerERC721A {
        __ERC721A_init("Land01", "LAND01");
        _nftMint(msg.sender, 1);
    }


    function mint(uint256 quantity) external {
        _nftMint(msg.sender, quantity);
    }

    /// @notice Internal function to mint NFTs with specific coordinate assignment
    /// @param to The address to mint the NFT to
    /// @param quantity The number of NFTs to mint
    function _nftMint(address to, uint256 quantity) internal {
        uint256 supply = totalSupply();
        require(supply + quantity <= _sN().maxSupply, "Exceeds max supply");

        _mint(to, quantity);

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = supply + i + 1;
            LibLand._AssignLand(tokenId);
        }
    }

    function _sN() internal pure returns (LibLandStorage.Data storage data) {
        data = LibLandStorage.data();
    }

    /// ERC721 non standard functions

    /// @notice Get the maximum supply of NFTs
    /// @return The maximum supply
    function maxSupply() external view returns (uint256) {
        return _sN().maxSupply;
    }

    /// ERC721A Overrides

    function totalSupply() public view virtual override(ERC721AUpgradeable, IERC721AUpgradeable) returns (uint256) {
        return super.totalSupply();
    }

    function balanceOf(address owner) public view virtual override(ERC721AUpgradeable, IERC721AUpgradeable) returns (uint256) {
        return super.balanceOf(owner);
    }

    function ownerOf(uint256 tokenId) public view virtual override(ERC721AUpgradeable, IERC721AUpgradeable) returns (address) {
        return super.ownerOf(tokenId);
    }

    function name() public view virtual override(ERC721AUpgradeable, IERC721AUpgradeable) returns (string memory) {
        return super.name();
    }

    function symbol() public view virtual override(ERC721AUpgradeable, IERC721AUpgradeable) returns (string memory) {
        return super.symbol();
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721AUpgradeable, IERC721AUpgradeable) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function approve(address to, uint256 tokenId) public payable virtual override(ERC721AUpgradeable, IERC721AUpgradeable) {
        super.approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override(ERC721AUpgradeable, IERC721AUpgradeable) returns (address) {
        return super.getApproved(tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public virtual override(ERC721AUpgradeable, IERC721AUpgradeable) {
        super.setApprovalForAll(operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override(ERC721AUpgradeable, IERC721AUpgradeable) returns (bool) {
        return super.isApprovedForAll(owner, operator);
    }

    function transferFrom(address from, address to, uint256 tokenId) public payable virtual override(ERC721AUpgradeable, IERC721AUpgradeable) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public payable virtual override(ERC721AUpgradeable, IERC721AUpgradeable) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function explicitOwnershipOf(uint256 tokenId) public view virtual override returns (TokenOwnership memory) {
        return super.explicitOwnershipOf(tokenId);
    }

    function explicitOwnershipsOf(uint256[] calldata tokenIds) public view virtual override returns (TokenOwnership[] memory) {
        return super.explicitOwnershipsOf(tokenIds);
    }

    function tokensOfOwnerIn(address owner, uint256 start, uint256 stop) public view virtual override returns (uint256[] memory) {
        return super.tokensOfOwnerIn(owner, start, stop);
    }

    function tokensOfOwner(address owner) public view virtual override returns (uint256[] memory) {
        return super.tokensOfOwner(owner);
    }


}