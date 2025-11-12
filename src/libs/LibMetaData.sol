// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library LibMetaData {

    //string constant internal CID_IMAGE = "QmcKGKR545NiGQiA8JSCQKYGaa8jxkw4WGy29Sv6LdeYwZ";
    string constant internal CID_TOKEN = "QmRRgDA2VCSSNMM3ST3uuJoXSWHXze2bjfUE2vF9ENxqNw";
    string constant internal CID_CONTRACT = "QmYZFn7ZuCsD8UA3meGxvsUrF9nR7QRe3EXSpncqBXAydK";


    function tokenURI(uint256 _tokenId) internal view returns (string memory) {
        return string(abi.encodePacked("ipfs://", CID_TOKEN));
    }


    function contractURI() internal pure returns (string memory) {
        return string(abi.encodePacked("ipfs://", CID_CONTRACT));
    }



}
