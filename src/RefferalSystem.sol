// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;


import {Token} from "./token.sol";




interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}



contract RefferalSystem {

    error RefferalSystem_PleaseSendMoreToken();
    error RefferalSystem_YouCannnotEnterWithOutReffralId();
    error RefferalSystem_YourTransactionHasFailed();
    error RefferalSystem_YourReffralIdIsWrong();
    error RefferalSystem_YouHaveParticipatedBefore();
    error RefferalSystem_TransferToWinnersHasFailed();
    error RefferalSystem_ThisIsNotTheTimeFotDistribution();


    event participated(address indexed user, address refrallId);
    event Rewarded();

    IERC20 MYUSDT;

    address immutable private Owner;
    address[] public users;
    mapping (address => uint256) userToReffrals;
    address[] winners;
    uint256 public immutable initialTime;
    uint256 public constant REWARDADTER= 86400;
    

    constructor(address myusdt){
        Owner=msg.sender;
        MYUSDT= IERC20(myusdt);
        users.push(msg.sender);
        initialTime=block.timestamp;
        
    }


    function participate (address reffralId,uint256 amount) public {

        bool exist=false;

        for (uint i=0; i<users.length;i++){
            if (users[i] == reffralId ) {
                exist=true;
            }}
        for (uint i=1; i<users.length;i++){
            if (users[i] == msg.sender ) {
               revert RefferalSystem_YouHaveParticipatedBefore(); 
            }
        }


        if(amount < 100 ){
            revert RefferalSystem_PleaseSendMoreToken();
        }else if(reffralId == address(0)){
            revert RefferalSystem_YouCannnotEnterWithOutReffralId();
        }else if(exist == false){
            revert RefferalSystem_YourReffralIdIsWrong();
        }

        bool success = MYUSDT.transferFrom(msg.sender,address(this), amount);

        if (!success){
            revert RefferalSystem_YourTransactionHasFailed();
        }else{            
            users.push(msg.sender);
            userToReffrals[reffralId]++;
        }

        emit participated(msg.sender,reffralId);

    }

    function Reward()public{

        if (block.timestamp < initialTime+REWARDADTER){
            revert RefferalSystem_ThisIsNotTheTimeFotDistribution();
        }

        uint256 Count=0;
        bool transferUser=false;
        bool transferToOwner=false;

        for(uint256 i=0;i<users.length;i++){
            if(userToReffrals[users[i]] == Count){
                Count= userToReffrals[users[i]];
                winners.push(users[i]);
            }else if(userToReffrals[users[i]] > Count){
                delete winners;
                winners.push(users[i]);
                Count= userToReffrals[users[i]];
            }else{
                continue;
            }
        }

        for (uint i=0; i<winners.length;i++){
            transferUser=MYUSDT.transfer(winners[i],(userToReffrals[winners[i]])*20);
        }
        if (!transferUser){
            revert RefferalSystem_TransferToWinnersHasFailed();
        }else{
            transferToOwner=MYUSDT.transfer(Owner,MYUSDT.balanceOf(address(this)));
        }
        if (transferUser && transferToOwner){
            emit Rewarded();
        }
    }


    ////getter functions////

    function GetUser(uint256 index)public view returns(address){
        return users[index];
    }
    function GetWinner(uint256 index)public view returns(address){
        return winners[index];
    }
    function GetReffralCount (address user)public view returns(uint256){
        return userToReffrals[user];
    }
    function GetOwner()public view returns(address){
        return Owner;
    }
    function getRewardDate()public pure returns(uint256){
        return REWARDADTER;
    }
    
}
