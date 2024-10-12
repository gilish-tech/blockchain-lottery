pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Lottery} from "../src/Lottery.sol";
import {CreateSubScription} from "./Interactions.s.sol";


contract DeployLotteryContract is Script {
    function run() external  returns(Lottery,HelperConfig){
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 entranceFee,
            uint256 interval, 
            address vrfCoordinatorAddress,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address link


        ) = helperConfig.activeNetworkConfig();

        if(subscriptionId == 0 ){
            CreateSubScription createSubScription = new CreateSubScription();
            subscriptionId = createSubScription.run();

        }

    
        vm.startBroadcast();
        Lottery lottery = new Lottery(
            entranceFee,
            interval, 
            vrfCoordinatorAddress,
            gasLane,
             subscriptionId,
             callbackGasLimit);
        vm.stopBroadcast();

        return (lottery, helperConfig);
        
    }


  
}