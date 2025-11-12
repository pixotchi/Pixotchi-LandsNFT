// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library libPseudoRnd {

    function getBiasedAlternatingOutput(uint256 input) internal pure returns (uint8) {
        // Use modulo 5 to create a repeating pattern
        uint256 pattern = input % 5;

        // Define the pattern:
        // 0 and 2 return 0 (40% of cases)
        // 1 and 3 return 1 (40% of cases)
        // 4 returns 0 (additional 20% for 0, creating the 60/40 split)

        if (pattern == 1 || pattern == 3) {
            return 1;
        } else {
            return 0;
        }
    }
//
//    /**
// * @dev Generates a pseudorandom uint8 number within the range [min, max].
//     * Incorporates an additional inputValue to influence the randomness.
//     *
//     * @param min The minimum value of the desired range (inclusive).
//     * @param max The maximum value of the desired range (inclusive).
//     * @param inputValue An additional uint256 value to influence randomness.
//     * @return A pseudorandom uint8 number between min and max.
//     */
//    function getRandomUint8(
//        uint8 min,
//        uint8 max,
//        uint256 inputValue
//    ) internal view returns (uint8) {
//        require(max >= min, "Max must be greater than or equal to min");
//
//        uint8 range = max - min + 1;
//
//        // Combine various sources of entropy, including the inputValue
//        uint256 combinedEntropy = uint256(
//            keccak256(
//                abi.encodePacked(
//                    block.prevrandao,    // Latest randomness from the block
//                    block.timestamp,     // Current block timestamp
//                    block.difficulty,    // Current block difficulty
//                    msg.sender,          // Address calling the function
//                    block.number,        // Current block number
//                    inputValue           // Additional input value
//                )
//            )
//        );
//
//        // Generate a pseudorandom number within the range [0, range - 1]
//        uint8 randomInRange = uint8(combinedEntropy % range);
//
//        // Shift the number to the desired range [min, max]
//        return randomInRange + min;
//    }

//    /**
//     * @dev Generates a pseudorandom uint8 number within the range [min, max].
//     * Uses block.prevrandao combined with other entropy sources for randomness.
//     *
//     * @param min The minimum value of the desired range (inclusive).
//     * @param max The maximum value of the desired range (inclusive).
//     * @return A pseudorandom uint8 number between min and max.
//     */
//    function getRandomUint8(uint8 min, uint8 max) public view returns (uint8) {
//        require(max >= min, "Max must be greater than or equal to min");
//
//        uint8 range = max - min + 1;
//
//        // Combine various sources of entropy
//        uint256 combinedEntropy = uint256(
//            keccak256(
//                abi.encodePacked(
//                    block.prevrandao,    // Latest randomness from the block
//                    block.timestamp,     // Current block timestamp
//                    block.difficulty,    // Current block difficulty
//                    msg.sender,          // Address calling the function
//                    block.number         // Current block number
//                )
//            )
//        );
//
//        // Generate a pseudorandom number within the range [0, range - 1]
//        uint8 randomInRange = uint8(combinedEntropy % range);
//
//        // Shift the number to the desired range [min, max]
//        return randomInRange + min;
//    }
}
