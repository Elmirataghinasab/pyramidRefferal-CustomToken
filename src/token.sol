// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;


import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";



contract Token is ERC20{

    constructor(uint256 initialSupply)ERC20("MYUSDT", "MUSDT") {

        _mint(msg.sender, initialSupply);

    }
    
}