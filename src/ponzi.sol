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



contract Ponzi {

    error Ponzi_PleaseSendMoreToken();
    error Ponzi_YouCannnotEnterWithOutReffralId();
    error Ponzi_YourTransactionHasFaild();
    error Ponzi_YourReffralIdIsWrong();
    error Ponzi_TransferToWinnersHasFailed();
    error Ponzi_ThisIsNotTheTimeFotDistribution();

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


        if(amount < 100 ){
            revert Ponzi_PleaseSendMoreToken();
        }else if(reffralId == address(0)){
            revert Ponzi_YouCannnotEnterWithOutReffralId();
        }else if(exist == false){
            revert Ponzi_YourReffralIdIsWrong();
        }

        bool success = MYUSDT.transferFrom(msg.sender, address(this), amount);

        if (!success){
            revert Ponzi_YourTransactionHasFaild();
        }else{            
            users.push(msg.sender);
            userToReffrals[msg.sender]++;
        }

        emit participated(msg.sender,reffralId);

    }

    function Reward()public{

        if (block.timestamp < initialTime+REWARDADTER){
            revert Ponzi_ThisIsNotTheTimeFotDistribution();
        }

        uint256 Count=0;
        bool transferUser=false;
        bool transferToOwner=false;

        for(uint256 i=0;i<users.length;i++){
            if(userToReffrals[users[i]] >= Count){
                Count= userToReffrals[users[i]];
                winners.push(users[i]);
            }else{
                continue;
            }
        }

        for (uint i=0; i<winners.length;i++){
            transferUser=MYUSDT.transferFrom(address(this), winners[i] , userToReffrals[winners[i]]*20);
        }
        if (!transferUser){
            revert Ponzi_TransferToWinnersHasFailed();
        }else{
            transferToOwner=MYUSDT.transferFrom(address(this), Owner , MYUSDT.balanceOf(address(this)));
        }
        if (transferUser && transferToOwner){
            emit Rewarded();
        }
    }

    
}
