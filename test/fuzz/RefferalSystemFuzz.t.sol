// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {RefferalSystemScript} from "../../script/RefferalSystem.s.sol";
import {Token} from "../../src/token.sol";
import {RefferalSystem} from "../../src/RefferalSystem.sol";



contract RefferalSystemTest is Test{

    RefferalSystemScript deploy;
    Token MyToken;
    RefferalSystem MyRefferalSystem;

    address Owner;
    uint256 initialSupply=1e18;

    function setUp()public{
        deploy = new RefferalSystemScript();
        MyToken=deploy.runToken(initialSupply);
        MyRefferalSystem=deploy.runRefferalSystem(address(MyToken));
        Owner=MyRefferalSystem.GetOwner();
    }

  /* function testFuzz_participatemultipleUsers(address user1,address user2)public{
        vm.assume(user1 != address(0));
        vm.assume(user2 != address(0));
        vm.assume(user1 != Owner);
        vm.assume(user2 != Owner);
        vm.assume(user1 != user2);

        vm.prank(Owner);
        MyToken.transfer(user1, 100); 
        vm.startPrank(user1);  
        MyToken.approve(address(MyRefferalSystem),100);          
        MyRefferalSystem.participate(Owner,100);
        vm.stopPrank();

        vm.prank(Owner);
        MyToken.transfer(user2, 100); 
        vm.startPrank(user2);  
        MyToken.approve(address(MyRefferalSystem),100);          
        MyRefferalSystem.participate(Owner,100);
        vm.stopPrank();

        assertEq(MyRefferalSystem.GetUser(1),user1);
        assertEq(MyToken.balanceOf(user1), 0);
        assertEq(MyRefferalSystem.GetUser(2),user2);
        assertEq(MyToken.balanceOf(user2), 0);
    }*/
    function testFuzz_FailParticipateWithLowerAmount(uint256 amount,address user)public{
        vm.assume(user != address(0));
        vm.assume(amount <100);

        vm.prank(Owner);
        MyToken.transfer(user, amount); 
        vm.startPrank(user);  
        MyToken.approve(address(MyRefferalSystem),amount);          
        vm.stopPrank();

        vm.prank(user);          
        vm.expectRevert(RefferalSystem.RefferalSystem_PleaseSendMoreToken.selector);
        MyRefferalSystem.participate(Owner,amount);
        
    }
    function testFuzz_enterWithWrongReffralId(address reffralId,address user)public{
        vm.assume(reffralId != address(0));
        vm.assume(reffralId != Owner);
        vm.assume(user != address(0));
        vm.assume(user != Owner);
        
        vm.prank(Owner);
        MyToken.transfer(user, 100); 
        vm.startPrank(user);  
        MyToken.approve(address(MyRefferalSystem),100);
        vm.expectRevert(RefferalSystem.RefferalSystem_YourReffralIdIsWrong.selector);          
        MyRefferalSystem.participate(reffralId,100);
        vm.stopPrank();
    }
    function testFuzz_SecondaryEnterFail(address user)public{
        vm.assume(user != address(0));

        vm.prank(Owner);
        MyToken.transfer(user, 200); 
        vm.startPrank(user);  
        MyToken.approve(address(MyRefferalSystem),200);                  
        MyRefferalSystem.participate(Owner,100);
        vm.expectRevert(RefferalSystem.RefferalSystem_YouHaveParticipatedBefore.selector);
        MyRefferalSystem.participate(Owner,100);
        vm.stopPrank();
    }
    function testFuzz_RewardWithMultipleUsers(address user1,address user2)public{
        vm.assume(user1 != address(0));
        vm.assume(user2 != address(0));
        vm.assume(user1 != Owner);
        vm.assume(user2 != Owner);
        vm.assume(user1 != user2);


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
    function testFuzz_RewardWithMultiplewinners(address user1,address user2,address user3,address user4)public{
        vm.assume(user1 != address(0));
        vm.assume(user2 != address(0));
        vm.assume(user3 != address(0));
        vm.assume(user4 != address(0));
        vm.assume(user1 != Owner);
        vm.assume(user2 != Owner);
        vm.assume(user3 != Owner);
        vm.assume(user4 != Owner);
        vm.assume(user1 != user2);
        vm.assume(user1 != user3);
        vm.assume(user1 != user4);
        vm.assume(user2 != user3);
        vm.assume(user2 != user4);
        vm.assume(user3 != user4);

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