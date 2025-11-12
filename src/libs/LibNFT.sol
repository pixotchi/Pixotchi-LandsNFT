// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

//import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {LibERC721} from "./LibERC721.sol";

abstract contract NFTModifiers {
    //using LibNFT for uint256;

    /**
     * @dev Modifier to check if a token exists
     * @param tokenId The ID of the token to check
     */
    modifier exists(uint256 tokenId) {
        //IERC721(address(this)).exists(tokenId)
        //require(IERC721(address(this)).exists(tokenId), "NFT: Token does not exist");
        require(LibERC721._exists(tokenId), "NFT: Token does not exist");
        _;
    }

//    modifier approved(uint256 tokenId) {
//        //IERC721(address(this)).exists(tokenId)
//        //require(IERC721(address(this)).exists(tokenId), "NFT: Token does not exist");
//        //
//        require(((LibERC721._requireOwned(tokenId) == msg.sender) || (LibERC721._getApproved(tokenId) == msg.sender)), "NFT: require owner or approval");
//        _;
//    }
}

/*


import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";


library LibNFT {
    using Strings for uint256;

    /// @custom:storage-location erc7201:openzeppelin.storage.ERC721
    struct ERC721Storage {
        // Token name
        string _name;

        // Token symbol
        string _symbol;

        mapping(uint256 tokenId => address) _owners;

        mapping(address owner => uint256) _balances;

        mapping(uint256 tokenId => address) _tokenApprovals;

        mapping(address owner => mapping(address operator => bool)) _operatorApprovals;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC721")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC721StorageLocation = 0x80bb2b638cc20bc4d0a60d66940f3ab4a00c1d7b313497ca82fb0b4ab0079300;

    function _getERC721Storage() private pure returns (ERC721Storage storage $) {
        assembly {
            $.slot := ERC721StorageLocation
        }
    }

    //_balanceOf
    //_ownerOf
    //_totalSupply

}

*/
