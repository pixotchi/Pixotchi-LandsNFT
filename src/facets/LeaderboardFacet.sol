// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {  LibLeaderboard } from "../libs/LibLeaderboard.sol";
import {  Leaderboard } from  "../shared/Structs.sol";


contract LeaderboardFacet {

    function getLeaderboard(uint256 startId, uint256 endId) external view returns (Leaderboard[] memory leaderboard) {
        leaderboard = LibLeaderboard.getLeaderboard(startId, endId);
    }


}