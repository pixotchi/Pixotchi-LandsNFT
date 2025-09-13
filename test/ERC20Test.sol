//// SPDX-License-Identifier: MIT
//pragma solidity >=0.8.21;
//
//import "forge-std/Test.sol";
//import { ERC20 } from "src/facades/ERC20.sol";
//import { Vm } from "forge-std/Vm.sol";
//import { TestBaseContract, console2 } from "./utils/TestBaseContract.sol";
//import "../src/facets/ERC20Facet.sol";
//import "../src/libs/LibERC20.sol";
//
//contract ERC20Test is TestBaseContract {
//  function setUp() public virtual override {
//    super.setUp();
//  }
//
//  function tokenConfig(string memory name, string memory symbol, uint8 decimals) internal pure returns (ERC20TokenConfig memory) {
//    return ERC20TokenConfig({
//      name: name,
//      symbol: symbol,
//      decimals: decimals
//    });
//  }
//
//  function testDeployFacadeFails() public {
//    vm.expectRevert( abi.encodePacked(ERC20InvalidInput.selector) );
//    diamond.erc20DeployToken(tokenConfig("", "TEST", 18));
//
//    vm.expectRevert( abi.encodePacked(ERC20InvalidInput.selector) );
//    diamond.erc20DeployToken(tokenConfig("TestToken", "", 18));
//
//    vm.expectRevert( abi.encodePacked(ERC20InvalidInput.selector) );
//    diamond.erc20DeployToken(tokenConfig("TestToken", "TEST", 0));
//  }
//
//  function testDeployFacadeSucceeds() public returns (ERC20) {
//    vm.recordLogs();
//    diamond.erc20DeployToken(tokenConfig("TestToken", "TEST", 18));
//    Vm.Log[] memory entries = vm.getRecordedLogs();
//    assertEq(entries.length, 2, "Invalid entry count");
//    assertEq(entries[1].topics.length, 1, "Invalid event count");
//    assertEq(
//        entries[1].topics[0],
//        keccak256("ERC20NewToken(address)"),
//        "Invalid event signature"
//    );
//    (address t) = abi.decode(entries[1].data, (address));
//
//    ERC20 token = ERC20(t);
//
//    assertEq(token.name(), "TestToken", "Invalid name");
//    assertEq(token.symbol(), "TEST", "Invalid symbol");
//    assertEq(token.decimals(), 18, "Invalid decimals");
//
//    return token;
//  }
//
//  function testBasicBalance() public {
//    ERC20 token = testDeployFacadeSucceeds();
//
//    assertEq(token.totalSupply(), 100, "Invalid total supply");
//    assertEq(token.balanceOf(account0), 100, "Invalid balance");
//  }
//
//  function testTransferInvalidInputs() public {
//    ERC20 token = testDeployFacadeSucceeds();
//
//    vm.expectRevert( abi.encodeWithSelector(ERC20InvalidReceiver.selector, address(0)) );
//    token.transfer(address(0), 1);
//
//    vm.expectRevert( abi.encodeWithSelector(ERC20NotEnoughBalance.selector, account0) );
//    token.transfer(account1, 101);
//  }
//
//  function testTransferSucceeds() public {
//    ERC20 token = testDeployFacadeSucceeds();
//
//    token.transfer(account1, 1);
//    assertEq(token.balanceOf(account0), 99, "Invalid balance 0");
//    assertEq(token.balanceOf(account1), 1, "Invalid balance 1");
//  }
//
//  function testApproveAllowance() public {
//    ERC20 token = testDeployFacadeSucceeds();
//
//    token.approve(account2, 5);
//    assertEq(token.allowance(account0, account2), 5, "Invalid allowance");
//  }
//
//  function testTransferFromNotEnoughAllowance() public {
//    ERC20 token = testDeployFacadeSucceeds();
//
//    token.approve(account2, 5);
//
//    vm.prank(account2);
//    vm.expectRevert( abi.encodeWithSelector(ERC20NotEnoughAllowance.selector, account0, account2) );
//    token.transferFrom(account0, account1, 6);
//  }
//
//  function testTransferFromSucceeds() public {
//    ERC20 token = testDeployFacadeSucceeds();
//
//    token.approve(account2, 5);
//
//    vm.prank(account2);
//    token.transferFrom(account0, account1, 4);
//
//    assertEq(token.balanceOf(account0), 96, "Invalid balance 0");
//    assertEq(token.balanceOf(account1), 4, "Invalid balance 1");
//    assertEq(token.allowance(account0, account2), 1, "Invalid allowance");
//  }
//}
