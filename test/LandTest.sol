// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import { TestBaseContract, console2 } from "./utils/TestBaseContract.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/shared/Structs.sol";  // Import the Structs file

// Mock ERC20 token contract
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
    
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}

contract LandTest is TestBaseContract {

    
    MockERC20 public seedToken;
    MockERC20 public leafToken;
    address public player;

    function setUp() public virtual override {
        super.setUp();

        // Create SEED token
        seedToken = new MockERC20("SEED Token", "SEED", 21_000_000 * 10**18);
        vm.etch(0xc64F740D216B6ec49e435a8a08132529788e8DD0, address(seedToken).code);
        seedToken = MockERC20(0xc64F740D216B6ec49e435a8a08132529788e8DD0);

        // Create LEAF token
        leafToken = new MockERC20("LEAF Token", "LEAF", 79_000_000_000 * 10**18);
        vm.etch(0x33feeD5a3eD803dc03BBF4B6041bB2b86FACD6C4, address(leafToken).code);
        leafToken = MockERC20(0x33feeD5a3eD803dc03BBF4B6041bB2b86FACD6C4);

        // Approve max supply for both tokens to the diamond address
        seedToken.approve(address(diamond), seedToken.totalSupply());
        leafToken.approve(address(diamond), leafToken.totalSupply());

        // Set up a player account
        player = address(0x1234);
        vm.deal(player, 100 ether);
    }

    // function testExample() public {
    //     string memory e = diamond.name();
    //     assertEq(e, "Land02", "Invalid name");
    //     console.log(e);
    // }

    function testMintAndReadLandOverviewByOwner() public {
        setupPlayerWithTokens(player);
        vm.startPrank(player);

        Land[] memory _land1 = diamond.landGetByOwner(player);

        logLands(_land1);




        // Mint a land
        diamond.mint();
        diamond.mint();
        //diamond.mintTokenId(1);
        //diamond.mintTokenId(1);

        //uint256 _tokenId = 1;
        //uint8 _buildingId = 0;

        Land[] memory _land2 = diamond.landGetByOwner(player);

        logLands(_land2);


        // Perform one upgrade and speed-up
        //performUpgradesAndSpeedups(_tokenId, _buildingId, 1);

        //logSpecificVillageBuilding(_tokenId, _buildingId);
        vm.stopPrank();
    }

    function logLands(Land[] memory lands) internal {
        console2.log("Number of lands:", lands.length);
        for (uint i = 0; i < lands.length; i++) {
            Land memory land = lands[i];
            console2.log("Land", i);
            console2.log("  ID:", land.tokenId);
            console2.log("  Owner:", land.owner);
            console2.log("  Name:", land.name);
            console2.log("  Coordinates X:", land.coordinateX);
            console2.log("  Coordinates Y:", land.coordinateY);
        }
    }

        function setupPlayerWithTokens(
        address _player
    ) internal {
        vm.startPrank(_player);

        uint256 _leafAmount = 1_000_000_000_000 * 10**18;
        uint256 _seedAmount = 1_000_000 * 10**18;

        // Mint LEAF tokens to the player
        leafToken.mint(_player, _leafAmount);

        // Mint SEED tokens to the player
        seedToken.mint(_player, _seedAmount);

        // Approve the diamond contract to spend LEAF and SEED tokens
        leafToken.approve(address(diamond), _leafAmount);
        seedToken.approve(address(diamond), _seedAmount);

        vm.stopPrank();
    }

/*    function testVillageDoubleUpgradeAndSpeedup() public {
        setupPlayerWithTokens(player);
        vm.startPrank(player);
        
        // Mint a land
        diamond.mint();
        uint256 _tokenId = 1;
        uint8 _buildingId = 0;

        // Perform two upgrades and speed-ups
        performUpgradesAndSpeedups(_tokenId, _buildingId, 2);

        logSpecificVillageBuilding(_tokenId, _buildingId);
        vm.stopPrank();
    }

    function testVillageTripleUpgradeAndSpeedup() public {
        setupPlayerWithTokens(player);
        vm.startPrank(player);
        
        // Mint a land
        diamond.mint();
        uint256 _tokenId = 1;
        uint8 _buildingId = 0;

        // Perform three upgrades and speed-ups
        performUpgradesAndSpeedups(_tokenId, _buildingId, 3);

        logSpecificVillageBuilding(_tokenId, _buildingId);
        vm.stopPrank();
    }

    function performUpgradesAndSpeedups(uint256 _tokenId, uint8 _buildingId, uint8 levels) internal {
        for (uint8 i = 0; i < levels; i++) {
            // Upgrade village building
            diamond.villageUpgradeWithLeaf(_tokenId, _buildingId);

            // Advance the block number
            vm.roll(block.number + 1);

            // Speed up the upgrade
            diamond.villageSpeedUpWithSeed(_tokenId, _buildingId);


        }
    }



    function logVillageBuildings(uint256 landId) internal {
        VillageBuilding[] memory buildings = diamond.villageGetVillageBuildingsByLandId(landId);

        console2.log("Number of buildings for Land ID", landId, ":", buildings.length);
        for (uint i = 0; i < buildings.length; i++) {
            VillageBuilding memory building = buildings[i];
            console2.log("Building", i);
            console2.log("  ID:", building.id);
            console2.log("  Level:", building.level);
            console2.log("  Max Level:", building.maxLevel);
            console2.log("  Is Upgrading:", building.isUpgrading);
            console2.log("  Upgrade Cost (LEAF):", building.levelUpgradeCostLeaf);
            console2.log("  Instant Upgrade Cost (SEED):", building.levelUpgradeCostSeedInstant);
            console2.log("  Upgrade Block Interval:", building.levelUpgradeBlockInterval);
            console2.log("  Production Rate (Lifetime):", building.productionRatePlantLifetimePerDay);
            console2.log("  Production Rate (Points):", building.productionRatePlantPointsPerDay);
            console2.log("  Claimed Block Height:", building.claimedBlockHeight);
        }
    }

    function logSpecificVillageBuilding(uint256 landId, uint256 buildingId) internal {
                    // Advance time by a day
            vm.roll(block.number + 1 days / 2);
        VillageBuilding[] memory buildings = diamond.villageGetVillageBuildingsByLandId(landId);

        for (uint i = 0; i < buildings.length; i++) {
            VillageBuilding memory building = buildings[i];
            if (building.id == buildingId) {
                console2.log("Building Details for ID:", buildingId);
                console2.log("  Level:", building.level);
                console2.log("  Max Level:", building.maxLevel);
                console2.log("  Is Upgrading:", building.isUpgrading);
                console2.log("  Upgrade Cost (LEAF):", building.levelUpgradeCostLeaf);
                console2.log("  Instant Upgrade Cost (SEED):", building.levelUpgradeCostSeedInstant);
                console2.log("  Upgrade Block Interval:", building.levelUpgradeBlockInterval);
                console2.log("  Production Rate (Lifetime):", building.productionRatePlantLifetimePerDay);
                console2.log("  Production Rate (Points):", building.productionRatePlantPointsPerDay);
                console2.log("  Claimed Block Height:", building.claimedBlockHeight);
                break;
            }
        }
    }*/
}
