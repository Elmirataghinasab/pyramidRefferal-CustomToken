// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Script, console} from "forge-std/Script.sol";
import {Token} from "../src/token.sol";
import {RefferalSystem} from "../src/RefferalSystem.sol";




contract RefferalSystemScript is Script{
 
    function runToken(uint256 initialSupply)external returns (Token){
        vm.startBroadcast();
        Token CToken = new Token(initialSupply);
        vm.stopBroadcast();

        return CToken;
    }

    function runRefferalSystem(address tokenAddress)external returns(RefferalSystem){
        vm.startBroadcast();
        RefferalSystem refferalSystem=new RefferalSystem(tokenAddress);
        vm.stopBroadcast();

        return refferalSystem;

    }

}