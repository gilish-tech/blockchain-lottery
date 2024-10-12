// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol"; 




contract HelperConfig is Script {
    uint256 public constant INITIAL_SUPPLY = 10 ether;
    struct NetworkConfig{
        uint256 entranceFee;
        uint256 interval; 
        address vrfCoordinatorAddress;
        bytes32 gasLane;
        uint64 _subscriptionId;
        uint32 callbackGasLimit;
        address link;
        }

    NetworkConfig public activeNetworkConfig;

    constructor(){

        if (block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        }else{
            activeNetworkConfig = getAnvilConfig();
        }

    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        return NetworkConfig({
            entranceFee: 0.003 ether,
            interval: 60,
            vrfCoordinatorAddress: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            _subscriptionId: 0,
            callbackGasLimit: 500000,
            link:0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
        
    }


    function getAnvilConfig() public returns(NetworkConfig memory){

        if (activeNetworkConfig.vrfCoordinatorAddress != address(0)){
            return activeNetworkConfig;
        }

        uint96 _baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;

        vm.startBroadcast();
          VRFCoordinatorV2Mock vRFCoordinatorV2Mock = new VRFCoordinatorV2Mock(_baseFee, gasPriceLink);

          LinkToken linkToken = new LinkToken(INITIAL_SUPPLY);
        vm.stopBroadcast();

        return NetworkConfig({
            entranceFee: 0.003 ether,
            interval: 60,
            vrfCoordinatorAddress: address(vRFCoordinatorV2Mock),
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            _subscriptionId: 0,
            callbackGasLimit: 500000,
            link:address(linkToken)

        });
  

  
}

}