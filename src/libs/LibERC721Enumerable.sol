// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {LibERC721} from "./LibERC721.sol";



library LibERC721Enumerable {

    struct ERC721EnumerableStorage {
        mapping(address owner => mapping(uint256 index => uint256)) _ownedTokens;
        mapping(uint256 tokenId => uint256) _ownedTokensIndex;

        uint256[] _allTokens;
        mapping(uint256 tokenId => uint256) _allTokensIndex;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC721Enumerable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC721EnumerableStorageLocation = 0x645e039705490088daad89bae25049a34f4a9072d398537b1ab2425f24cbed00;


    function _getERC721EnumerableStorage() private pure returns (ERC721EnumerableStorage storage $) {
        assembly {
            $.slot := ERC721EnumerableStorageLocation
        }
    }


        /**
     * @dev See {IERC721Upgradeable-exists}. Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function exists(uint256 tokenId) internal view returns (bool) {
        return LibERC721._ownerOf(tokenId) != address(0);
    }



}
