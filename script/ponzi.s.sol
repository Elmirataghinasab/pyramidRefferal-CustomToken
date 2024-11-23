// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Script, console} from "forge-std/Script.sol";
import {Token} from "../src/token.sol";
import {Ponzi} from "../src/ponzi.sol";




contract PonziScript is Script{
 
    function runToken(uint256 initialSupply)external returns (Token){
        vm.startBroadcast();
        Token CToken = new Token(initialSupply);
        vm.stopBroadcast();

        return CToken;
    }

    function runPonzi(address tokenAddress)external returns(Ponzi){
        vm.startBroadcast();
        Ponzi MPonzi=new Ponzi(tokenAddress);
        vm.stopBroadcast();

        return MPonzi;

    }

}