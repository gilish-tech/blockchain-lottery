
pragma solidity ^0.8.19;

import {Script,console} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";



contract CreateSubScription is Script {

    function createSubScriptionUsingConfig() public returns(uint64){
         HelperConfig helperConfig = new HelperConfig();
        (,,address vrfCoordinatorAddress,,,,) = helperConfig.activeNetworkConfig();
            return createSubscription(vrfCoordinatorAddress);
    }
    
    function createSubscription(address _vrfCoordinatorAddress) public returns(uint64){
        vm.startBroadcast();
        VRFCoordinatorV2Mock vRFCoordinatorV2Mock = VRFCoordinatorV2Mock(_vrfCoordinatorAddress);
        uint64 subId = vRFCoordinatorV2Mock.createSubscription();
        console.log("subid is %s",subId);
        vm.stopBroadcast();

        return subId;



    }

    function run() external returns (uint64) {
        return createSubScriptionUsingConfig();
    }
}




contract FundSubScription is Script{
    HelperConfig helperConfig = new HelperConfig();
    uint96 public constant FUND_AMOUNT  = 3 ether;

    function fundSubScriptionUsingConfig() public{
         (
          ,
        , 
        address vrfCoordinatorAddress,
        ,
        uint64 subscriptionId,
        ,
        address link
            


        ) = helperConfig.activeNetworkConfig();


        fundSubScription(vrfCoordinatorAddress,subscriptionId,link)
    }

    function fundSubScription(address _vrfCoordinatorAddress,uint64 _subscriptionId, address _link)public{

        console.log("funding subscription",_subscriptionId);
        console.log("funding subscription",_vrfCoordinatorAddress);
        console.log("funding chainId",block.chainid);

        if (block.chainid === 31337){ 
            vm.startBroadcast();
              VRFCoordinatorV2Mock(vrfCoordinatorAddress).fundSubscription(_subscriptionId, FUND_AMOUNT);

            vm.stopBroadcast();
        }else{
            vm.startBroadcast();
            LinkToken(link).
            vm.stopBroadcast();
        }

    }

    function run() external{
        fundSubScriptionUsingConfig();
    }

}