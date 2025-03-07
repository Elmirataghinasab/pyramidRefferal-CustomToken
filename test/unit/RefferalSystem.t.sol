// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {RefferalSystemScript} from "../../script/RefferalSystem.s.sol";
import {Token} from "../../src/token.sol";
import {RefferalSystem} from "../../src/RefferalSystem.sol";



contract RefferalTest is Test{

    RefferalSystemScript deploy;
    Token MyToken;
    RefferalSystem MyRefferalSystem;


    address user1=address(2);
    address user2=address(3);
    address user3=address(4);
    address user4=address(5);
    address Owner;
    uint256 initialSupply=1e18;

    function setUp()public{
        deploy = new RefferalSystemScript();
        MyToken=deploy.runToken(initialSupply);
        MyRefferalSystem=deploy.runRefferalSystem(address(MyToken));
        Owner=MyRefferalSystem.GetOwner();

    }

    ////token tests//// 

    function testMintIntialSupplyCorrectly()public {
        uint256 inS=MyToken.totalSupply();
        assertEq(inS,initialSupply);
    }

    ////RefferalSystem tests////

    function testOwnerAddressAddedToUsers()public {
        assertEq(MyRefferalSystem.GetOwner(),MyRefferalSystem.GetUser(0));
    }

    function testParticipateCorrectly()public{

        vm.prank(Owner);
        MyToken.transfer(user1, 100); 
        vm.startPrank(user1);  
        MyToken.approve(address(MyRefferalSystem),100);          
        MyRefferalSystem.participate(Owner,100);
        vm.stopPrank();


        assertEq(MyRefferalSystem.GetUser(1),user1);
        assertEq(MyToken.balanceOf(user1), 0);
    }

    function testFailParticipateWithLowerAmount()public{
        vm.prank(Owner);
        MyToken.transfer(user1, 100); 

        vm.prank(user2);          
        vm.expectRevert("RefferalSystem_PleaseSendMoreToken");
        MyRefferalSystem.participate(Owner,0);
        
    }
    function testFailwithNullReffralid()public{
        
        vm.prank(Owner);
        MyToken.transfer(user1, 100); 
        vm.startPrank(user1);  
        MyToken.approve(address(MyRefferalSystem),100);

        vm.expectRevert("RefferalSystem_YouCannnotEnterWithOutReffralId");          
        MyRefferalSystem.participate(address(0),100);
        vm.stopPrank();
    }

    function testenterWithWrongReffralId()public{
        vm.prank(Owner);
        MyToken.transfer(user1, 100); 
        vm.startPrank(user1);  
        MyToken.approve(address(MyRefferalSystem),100);
        vm.expectRevert(RefferalSystem.RefferalSystem_YourReffralIdIsWrong.selector);          
        MyRefferalSystem.participate(address(6),100);
        vm.stopPrank();
    }

    function testSecondaryEnterFail()public{
        vm.prank(Owner);
        MyToken.transfer(user1, 200); 
        vm.startPrank(user1);  
        MyToken.approve(address(MyRefferalSystem),200);                  
        MyRefferalSystem.participate(Owner,100);
        vm.expectRevert(RefferalSystem.RefferalSystem_YouHaveParticipatedBefore.selector);
        MyRefferalSystem.participate(Owner,100);
        vm.stopPrank();
    }
    function testRevertRewardWithWrongTime()public{

        vm.expectRevert(RefferalSystem.RefferalSystem_ThisIsNotTheTimeFotDistribution.selector);
        MyRefferalSystem.Reward();

    }
    function testRewardWithOneUser()public{

        vm.prank(Owner);
        MyToken.transfer(user1, 100); 

        vm.startPrank(user1);  
        MyToken.approve(address(MyRefferalSystem),100);          
        MyRefferalSystem.participate(Owner,100);
        vm.stopPrank();

        vm.warp(block.timestamp +MyRefferalSystem.getRewardDate());

        vm.startPrank(Owner);
        uint256 ownerbeforeBlnc=MyToken.balanceOf(Owner);
        MyToken.approve(address(MyRefferalSystem),100);
        MyRefferalSystem.Reward();
        vm.stopPrank();


        assertEq(MyRefferalSystem.GetWinner(0),Owner);
        assertEq(MyToken.balanceOf(user1),0);
        assertEq(MyToken.balanceOf(Owner),ownerbeforeBlnc+100);

    }

    function testRewardWithMultipleUsers()public{

        vm.startPrank(Owner);
        MyToken.transfer(user1, 100); 
        MyToken.transfer(user2, 100);
        vm.stopPrank();

        vm.startPrank(user1);  
        MyToken.approve(address(MyRefferalSystem),100);          
        MyRefferalSystem.participate(Owner,100);
        vm.stopPrank();

        vm.startPrank(user2);
        MyToken.approve(address(MyRefferalSystem),100);          
        MyRefferalSystem.participate(Owner,100);
        vm.stopPrank();

        vm.warp(block.timestamp + MyRefferalSystem.getRewardDate());
        vm.startPrank(Owner);
        uint256 ownerbeforeBlnc=MyToken.balanceOf(Owner);
        MyToken.approve(address(MyRefferalSystem),200);
        MyRefferalSystem.Reward();
        vm.stopPrank();

        assertEq(MyRefferalSystem.GetWinner(0),Owner);
        assertEq(MyToken.balanceOf(user1),0);
        assertEq(MyToken.balanceOf(user2),0);
        assertEq(MyToken.balanceOf(Owner),ownerbeforeBlnc+200);
        
    }
    function testRewardWithMultiplewinners()public{

        vm.startPrank(Owner);
        MyToken.transfer(user1, 100); 
        MyToken.transfer(user2, 100);
        MyToken.transfer(user3, 100);
        MyToken.transfer(user4, 100);
        vm.stopPrank();

        vm.startPrank(user1);  
        MyToken.approve(address(MyRefferalSystem),100);          
        MyRefferalSystem.participate(Owner,100);
        vm.stopPrank();

        vm.startPrank(user2);
        MyToken.approve(address(MyRefferalSystem),100);          
        MyRefferalSystem.participate(Owner,100);
        vm.stopPrank();

        vm.startPrank(user3);
        MyToken.approve(address(MyRefferalSystem),100);          
        MyRefferalSystem.participate(user1,100);
        vm.stopPrank();

        vm.startPrank(user4);
        MyToken.approve(address(MyRefferalSystem),100);          
        MyRefferalSystem.participate(user1,100);
        vm.stopPrank();

        vm.warp(block.timestamp + MyRefferalSystem.getRewardDate());
        vm.startPrank(Owner);
        uint256 ownerbeforeBlnc=MyToken.balanceOf(Owner);
        MyToken.approve(address(MyRefferalSystem),400);
        MyRefferalSystem.Reward();
        vm.stopPrank();

        assertEq(MyRefferalSystem.GetWinner(0),Owner);
        assertEq(MyRefferalSystem.GetWinner(1),user1);
        assertEq(MyToken.balanceOf(user1),40);
        assertEq(MyToken.balanceOf(user2),0);
        assertEq(MyToken.balanceOf(user3),0);
        assertEq(MyToken.balanceOf(user4),0);
        assertEq(MyToken.balanceOf(Owner),ownerbeforeBlnc+320+40);
        
    }

    

}