// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {PonziScript} from "../../script/ponzi.s.sol";
import {Token} from "../../src/token.sol";
import {Ponzi} from "../../src/ponzi.sol";



contract PonziTest is Test{

    PonziScript deploy;
    Token MyToken;
    Ponzi MyPonzi;


    address user1=address(2);
    address user2=address(3);
    address Owner;
    uint256 initialSupply=1e18;

    function setUp()public{
        deploy = new PonziScript();
        MyToken=deploy.runToken(initialSupply);
        MyPonzi=deploy.runPonzi(address(MyToken));
        Owner=MyPonzi.GetOwner();

    }

    ////token tests//// 

    function testMintIntialSupplyCorrectly()public {
        uint256 inS=MyToken.totalSupply();
        assertEq(inS,initialSupply);
    }

    ////Ponzi tests////

    function testOwnerAddressAddedToUsers()public {
        assertEq(MyPonzi.GetOwner(),MyPonzi.GetUser(0));
    }
    event participated(address indexed user, address refrallId);
    function testParticipateCorrectly()public{

        vm.prank(Owner);
        MyToken.transfer(user1, 100); 
        vm.startPrank(user1);  
        MyToken.approve(address(MyPonzi),100);          
        MyPonzi.participate(Owner,100);
        vm.stopPrank();


        assertEq(MyPonzi.GetUser(1),user1);
        assertEq(MyToken.balanceOf(user1), 0);
    }

    function testFailParticipateWithLowerAmount()public{
        vm.prank(Owner);
        MyToken.transfer(user1, 100); 

        vm.prank(user2);          
        vm.expectRevert("Ponzi_PleaseSendMoreToken");
        MyPonzi.participate(Owner,0);
        
    }
    function testFailwithNullReffralid()public{
        
        vm.prank(Owner);
        MyToken.transfer(user1, 100); 
        vm.startPrank(user1);  
        MyToken.approve(address(MyPonzi),100);

        vm.expectRevert("Ponzi_YouCannnotEnterWithOutReffralId");          
        MyPonzi.participate(address(0),100);
        vm.stopPrank();
    }

    function testenterWithWrongReffralId()public{
        vm.prank(Owner);
        MyToken.transfer(user1, 100); 
        vm.startPrank(user1);  
        MyToken.approve(address(MyPonzi),100);
        vm.expectRevert(Ponzi.Ponzi_YourReffralIdIsWrong.selector);          
        MyPonzi.participate(address(6),100);
        vm.stopPrank();
    }

    function testSecondaryEnterFail()public{
        vm.prank(Owner);
        MyToken.transfer(user1, 200); 
        vm.startPrank(user1);  
        MyToken.approve(address(MyPonzi),200);                  
        MyPonzi.participate(Owner,100);
        vm.expectRevert(Ponzi.Ponzi_YouHaveParticipatedBefore.selector);
        MyPonzi.participate(Owner,100);
        vm.stopPrank();
    }
    function testRevertRewardWithWrongTime()public{

        vm.expectRevert(Ponzi.Ponzi_ThisIsNotTheTimeFotDistribution.selector);
        MyPonzi.Reward();

    }
    function testRewardWithOneUser()public{

        vm.prank(Owner);
        MyToken.transfer(user1, 100); 

        vm.startPrank(user1);  
        MyToken.approve(address(MyPonzi),100);          
        MyPonzi.participate(Owner,100);
        vm.stopPrank();

        vm.warp(block.timestamp +MyPonzi.getRewardDate());

        vm.startPrank(Owner);
        uint256 ownerbeforeBlnc=MyToken.balanceOf(Owner);
        MyToken.approve(address(MyPonzi),100);
        MyPonzi.Reward();
        vm.stopPrank();


        assertEq(MyPonzi.GetWinner(0),Owner);
        assertEq(MyToken.balanceOf(user1),0);
        assertEq(MyToken.balanceOf(Owner),ownerbeforeBlnc+100);

    }

    function testRewardWithMultipleUsers()public{

        vm.startPrank(Owner);
        MyToken.transfer(user1, 100); 
        MyToken.transfer(user2, 100);
        vm.stopPrank();

        vm.startPrank(user1);  
        MyToken.approve(address(MyPonzi),100);          
        MyPonzi.participate(Owner,100);
        vm.stopPrank();

        vm.startPrank(user2);
        MyToken.approve(address(MyPonzi),100);          
        MyPonzi.participate(Owner,100);
        vm.stopPrank();

        vm.warp(block.timestamp + MyPonzi.getRewardDate());
        vm.startPrank(Owner);
        uint256 ownerbeforeBlnc=MyToken.balanceOf(Owner);
        MyToken.approve(address(MyPonzi),200);
        MyPonzi.Reward();
        vm.stopPrank();

        assertEq(MyPonzi.GetWinner(0),Owner);
        assertEq(MyToken.balanceOf(user1),0);
        assertEq(MyToken.balanceOf(user2),0);
        assertEq(MyToken.balanceOf(Owner),ownerbeforeBlnc+200);
        
    }

    

}