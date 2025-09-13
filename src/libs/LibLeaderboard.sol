// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

 import { LibLandStorage } from "../libs/LibLandStorage.sol";
// import  "../libs/LibAppStorage.sol";
import   "../shared/Structs.sol";
 import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
 import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
 import {LibLandStorage} from "./LibLandStorage.sol";


library LibLeaderboard {

    function getLeaderboard(uint256 startId, uint256 endId) internal view returns (Leaderboard[] memory leaderboard) {
        uint256 totalSupply = IERC721Enumerable(address(this)).totalSupply();
        LibLandStorage.Data storage s = _sN();
        if(endId == 0) {
            endId = totalSupply;
        } else {
            require(endId <= totalSupply, "endId exceeds total supply");
        }
        uint256 total = endId - startId;
        leaderboard = new Leaderboard[](total);

        for (uint256 i = 0; i < total; i++) {
            uint256 tokenId = startId + i;
            leaderboard[i] = Leaderboard({
                landId: tokenId,
                experiencePoints: s.experiencePoints[tokenId],
                //owner: IERC721(address(this)).ownerOf(tokenId),
                name: s.name[tokenId]
            });
        }

        return leaderboard;
    }

    /// @notice Internal function to access NFT storage
    /// @return data The LibLandStorage.Data struct
    function _sN() internal pure returns (LibLandStorage.Data storage data) {
        data = LibLandStorage.data();
    }


}

