
pragma solidity ^0.8.19;
import {Test } from "forge-std/Test.sol";
import {DeployLotteryContract} from "../script/DeployLotteryContract.s.sol";
import {Lottery} from "../src/Lottery.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";




contract RaffleTest is Test{
    event EnteredRaffle (address indexed player);
    Lottery lottery;
    HelperConfig helperConfig;
    address PLAYER = makeAddr("player");
    address S_PLAYER = makeAddr("s_player");

    uint256 public USER_BALANCE = 10 ether;
    uint256 entranceFee;
    uint256 interval; 
    address vrfCoordinatorAddress;
    bytes32 gasLane;
    uint64 _subscriptionId;
    uint32 callbackGasLimit;
    function setUp() external{

        vm.deal(PLAYER, USER_BALANCE);
        vm.deal(S_PLAYER, USER_BALANCE);


        DeployLotteryContract deployLotteryContract = new DeployLotteryContract();
        (lottery,helperConfig)=  deployLotteryContract.run();

         (
            entranceFee,
            interval, 
             vrfCoordinatorAddress,
             gasLane,
             _subscriptionId,
             callbackGasLimit,


        ) = helperConfig.activeNetworkConfig();

    }


    function testIfRaffleIsOpenState() external{

        vm.startBroadcast();
        assert(lottery.getRaffleState() == Lottery.RaffleState.Open);
        vm.stopBroadcast();
    }

    function testRevertIfEnoughEthIsNotPaid() external{
       vm.prank(PLAYER);
       vm.expectRevert(Lottery.Lottery__NotEnoughEthSent.selector );
       lottery.enterRaffle();

    }


    function testIfPlayerIsAddedAfterTesting() external{
      
        vm.prank(PLAYER);
        lottery.enterRaffle{value:entranceFee}();

        vm.prank(S_PLAYER);
        lottery.enterRaffle{value:entranceFee}();

        assertEq(lottery.getPlayer(0),PLAYER);
        assertEq(lottery.getPlayer(1),S_PLAYER);


    }

    function testEmitOnEnterRaffle() external{
        
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false,address(lottery));
        emit EnteredRaffle(PLAYER);
        lottery.enterRaffle{value:entranceFee}();

    }


    function testCannotEnterWhenFunctionIsCalculating() external{
        vm.prank(PLAYER);
        lottery.enterRaffle{value:entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        lottery.performUpkeep("");

        // vm.expectRevert(lottery.Lottery__RaffleIsClosed.selector);
        vm.prank(PLAYER);
        lottery.enterRaffle{value:entranceFee}();



    }


}