// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import "forge-std/Vm.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IDiamondProxy } from "src/generated/IDiamondProxy.sol";
import { DiamondProxy } from "src/generated/DiamondProxy.sol";

contract MyScript is Script {
     IDiamondProxy public land;
     IERC20 public seed;
     IERC20 public leaf;
     address public landAddress = 0x50815C5Ba96539fC4a4F0d7b70C4A7B66Dc716fB;
     address public seedAddress = 0xc64F740D216B6ec49e435a8a08132529788e8DD0;
     address public leafAddress = 0x33feeD5a3eD803dc03BBF4B6041bB2b86FACD6C4;
     address public testnetAccount = 0xC3f88d5925d9aa2ccc7b6cb65c5F8c7626591Daf;

   function setUp() public {
       //testnetAccount = vm.envAddress("PUBLIC_KEY");
   }

   function run() public {
       vm.startBroadcast();

       land = IDiamondProxy(landAddress);
       seed = IERC20(seedAddress);
       leaf = IERC20(leafAddress);

      
       // Give max allowance to land contract for seed token
       //seed.approve(landAddress, type(uint256).max);
       //console.log("Max allowance given to land contract for seed token");

       // Give max allowance to land contract for leaf token
       //leaf.approve(landAddress, type(uint256).max);
       //console.log("Max allowance given to land contract for leaf token");

       // Example usage of seed and leaf tokens
       //uint256 seedBalance = seed.balanceOf(testnetAccount);
       //uint256 leafBalance = leaf.balanceOf(testnetAccount);
       //console.log("Seed balance:", seedBalance);
       //console.log("Leaf balance:", leafBalance);
       

       //land.mint();

       uint256 landId = 7;

      uint8 questHouseId = 7;

      //land.townUpgradeWithLeaf(landId, questHouseId);

      land.townSpeedUpWithSeed(landId, questHouseId);
      //vm.stopBroadcast();



      //vm.startBroadcast();
      //vm.sleep(10_000);



       vm.stopBroadcast();
   }
}