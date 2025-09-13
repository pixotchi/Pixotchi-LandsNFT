// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {ERC721AStorage} from "lib_fork/ERC721A-Upgradeable/contracts/ERC721AStorage.sol";
import {IERC721AUpgradeable} from "lib_fork/ERC721A-Upgradeable/contracts/IERC721AUpgradeable.sol";
import {ERC721A__Initializable} from "lib_fork/ERC721A-Upgradeable/contracts/ERC721A__Initializable.sol";

library LibNFT {
    // Constants from ERC721AUpgradeable
    uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;
    uint256 private constant _BITMASK_BURNED = 1 << 224;
    uint256 private constant _BITPOS_START_TIMESTAMP = 160;
    uint256 private constant _BITPOS_NEXT_INITIALIZED = 225;
    uint256 private constant _BITMASK_NEXT_INITIALIZED = 1 << 225;
    uint256 private constant _BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted. See {_mint}.
     */
    function _exists(uint256 tokenId) internal view returns (bool result) {
        if (_startTokenId() <= tokenId) {
            if (tokenId > _sequentialUpTo())
                return _packedOwnershipExists(ERC721AStorage.layout()._packedOwnerships[tokenId]);

            if (tokenId < ERC721AStorage.layout()._currentIndex) {
                uint256 packed;
                while ((packed = ERC721AStorage.layout()._packedOwnerships[tokenId]) == 0) --tokenId;
                result = packed & _BITMASK_BURNED == 0;
            }
        }
    }

        /**
     * @dev Returns whether `packed` represents a token that exists.
     */
    function _packedOwnershipExists(uint256 packed) private pure returns (bool result) {
        assembly {
            // The following is equivalent to `owner != address(0) && burned == false`.
            // Symbolically tested.
            result := gt(and(packed, _BITMASK_ADDRESS), and(packed, _BITMASK_BURNED))
        }
    }

        /**
     * @dev Returns the starting token ID for sequential mints.
     *
     * Override this function to change the starting token ID for sequential mints.
     *
     * Note: The value returned must never change after any tokens have been minted.
     */
    function _startTokenId() internal pure returns (uint256) {
        return 0;
    }

        /**
     * @dev Returns the maximum token ID (inclusive) for sequential mints.
     *
     * Override this function to return a value less than 2**256 - 1,
     * but greater than `_startTokenId()`, to enable spot (non-sequential) mints.
     *
     * Note: The value returned must never change after any tokens have been minted.
     */
    function _sequentialUpTo() internal pure returns (uint256) {
        return type(uint256).max;
    }

        /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _ownerOf(uint256 tokenId) internal view returns (address) {
        return address(uint160(_packedOwnershipOf(tokenId)));
    }

        /**
     * @dev Returns the packed ownership data of `tokenId`.
     */
    function _packedOwnershipOf(uint256 tokenId) private view returns (uint256 packed) {
        if (_startTokenId() <= tokenId) {
            packed = ERC721AStorage.layout()._packedOwnerships[tokenId];

            if (tokenId > _sequentialUpTo()) {
                if (_packedOwnershipExists(packed)) return packed;
                _revert(IERC721AUpgradeable.OwnerQueryForNonexistentToken.selector);
            }

            // If the data at the starting slot does not exist, start the scan.
            if (packed == 0) {
                if (tokenId >= ERC721AStorage.layout()._currentIndex) _revert(IERC721AUpgradeable.OwnerQueryForNonexistentToken.selector);
                // Invariant:
                // There will always be an initialized ownership slot
                // (i.e. `ownership.addr != address(0) && ownership.burned == false`)
                // before an unintialized ownership slot
                // (i.e. `ownership.addr == address(0) && ownership.burned == false`)
                // Hence, `tokenId` will not underflow.
                //
                // We can directly compare the packed value.
                // If the address is zero, packed will be zero.
                for (;;) {
                    unchecked {
                        packed = ERC721AStorage.layout()._packedOwnerships[--tokenId];
                    }
                    if (packed == 0) continue;
                    if (packed & _BITMASK_BURNED == 0) return packed;
                    // Otherwise, the token is burned, and we must revert.
                    // This handles the case of batch burned tokens, where only the burned bit
                    // of the starting slot is set, and remaining slots are left uninitialized.
                    _revert(IERC721AUpgradeable.OwnerQueryForNonexistentToken.selector);
                }
            }
            // Otherwise, the data exists and we can skip the scan.
            // This is possible because we have already achieved the target condition.
            // This saves 2143 gas on transfers of initialized tokens.
            // If the token is not burned, return `packed`. Otherwise, revert.
            if (packed & _BITMASK_BURNED == 0) return packed;
        }
        _revert(IERC721AUpgradeable.OwnerQueryForNonexistentToken.selector);
    }


    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }


    /**
     * @dev Returns the number of tokens in `owner`'s account.
     */
    function _balanceOf(address owner) internal view returns (uint256) {
        if (owner == address(0)) _revert(IERC721AUpgradeable.BalanceQueryForZeroAddress.selector);
        return ERC721AStorage.layout()._packedAddressData[owner] & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
 * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     * To get the total number of tokens minted, please see {_totalMinted}.
     */
    function _totalSupply() public view returns (uint256 result) {
        // Counter underflow is impossible as `_burnCounter` cannot be incremented
        // more than `_currentIndex + _spotMinted - _startTokenId()` times.
        unchecked {
        // With spot minting, the intermediate `result` can be temporarily negative,
        // and the computation must be unchecked.
            result = ERC721AStorage.layout()._currentIndex - ERC721AStorage.layout()._burnCounter - _startTokenId();
            if (_sequentialUpTo() != type(uint256).max) result += ERC721AStorage.layout()._spotMinted;
        }
    }


}

//abstract contract NFTInit is  ERC721A__Initializable  {
//
//    // =============================================================
//    //                          CONSTRUCTOR
//    // =============================================================
//
//    function __ERC721A_init(string memory name_, string memory symbol_) internal onlyInitializingERC721A {
//        __ERC721A_init_unchained(name_, symbol_);
//    }
//
//    function __ERC721A_init_unchained(string memory name_, string memory symbol_) internal onlyInitializingERC721A {
//        ERC721AStorage.layout()._name = name_;
//        ERC721AStorage.layout()._symbol = symbol_;
//        ERC721AStorage.layout()._currentIndex = LibNFT._startTokenId();
//
//        if (LibNFT._sequentialUpTo() < LibNFT._startTokenId()) LibNFT._revert(IERC721AUpgradeable.SequentialUpToTooSmall.selector);
//    }
//
//}

/**
 * @dev Abstract contract to implement the exists modifier using LibNFT
 */
abstract contract NFTModifiers {
    using LibNFT for uint256;

    /**
     * @dev Modifier to check if a token exists
     * @param tokenId The ID of the token to check
     */
    modifier exists(uint256 tokenId) {
        require(LibNFT._exists(tokenId), "NFT: Token does not exist");
        _;
    }
}