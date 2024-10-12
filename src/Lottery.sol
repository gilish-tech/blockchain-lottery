// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";


/**
 *@title Lottery Smart Contract
 *@author Gilberto Diamond
 *@notice create a simple lottery where a random inner is selected
 *@dev  utilizes chainlik VRFCORDINATOR and Aggregatorv3

 */

contract Lottery is VRFConsumerBaseV2, ConfirmedOwner, AutomationCompatibleInterface{
// error 
error Lottery__NotEnoughEthSent();
error Lottery__TransferedFailed();
error Lottery__RaffleIsClosed();
error Lottery__TimeHasNotYetReach();
error  Lottery_UpkeepNoteededYet(
                uint256 currentBalance,
                uint256 NumberOfplayers,
                uint256 raffleState
            );


    enum RaffleState{
        Open,
        Closed
    }
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    uint32 private immutable i_callbackGasLimit;
    VRFCoordinatorV2Interface private immutable i_vrfcoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    
    address private s_recentWinner;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    RaffleState private s_raffleState;

    event EnteredRaffle(address indexed player);

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    event WinnerPicked(address indexed winner);

  

    constructor(uint256 _entranceFee,uint256 _interval, address _vrfCoordinatorAddress,bytes32 _gasLane,uint64 _subscriptionId,uint32 _callbackGasLimit )
    
      VRFConsumerBaseV2(_vrfCoordinatorAddress)
       ConfirmedOwner(msg.sender)
    {
        i_entranceFee = _entranceFee;
        i_interval = _interval;
        i_vrfcoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorAddress);
        s_lastTimeStamp = block.timestamp;
        i_gasLane = _gasLane;
        i_callbackGasLimit =  _callbackGasLimit ;
        i_subscriptionId = _subscriptionId;
        s_raffleState = RaffleState.Open;

        

        
    }

    function enterRaffle() public payable{
        if(msg.value < i_entranceFee){
            revert Lottery__NotEnoughEthSent();
        }

        if (s_raffleState != RaffleState.Open){
            revert Lottery__RaffleIsClosed();
        }

        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);

    }

    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        bool checkIfTimeHasPassed = (block.timestamp - s_lastTimeStamp) > i_interval;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayer = s_players.length > 0;
        bool isOpen = s_raffleState == RaffleState.Open;
        upkeepNeeded = checkIfTimeHasPassed && hasBalance && hasPlayer && isOpen;
        return (upkeepNeeded, "0x0");


        
    }

    function performUpkeep(bytes calldata /* performData */) external {

        (bool upkeedeeded,) = checkUpkeep("");
        if(!upkeedeeded){
            revert Lottery_UpkeepNoteededYet(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        if(block.timestamp - s_lastTimeStamp < i_interval){
            revert Lottery__TimeHasNotYetReach();

        }

        s_raffleState = RaffleState.Closed;

          i_vrfcoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATION,
            i_callbackGasLimit,
            NUM_WORDS
        );


    }



    function fulfillRandomWords(uint256 /*_requestId*/,uint256[] memory _randomWords) internal override {

        uint256 indexOfWinner= _randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];

        s_recentWinner = winner;
        s_raffleState = RaffleState.Open;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        s_lastTimeStamp = block.timestamp;
        emit WinnerPicked(winner);
        (bool success,) = winner.call{value:address(this).balance}("");

        if (!success){
            revert Lottery__TransferedFailed();
        }



    }


   /** Getter Functio for the entrancefee */
    function getEntraceFee() external view returns(uint256){
        return i_entranceFee;
    }


    function getRaffleState() external view returns(RaffleState){
        return s_raffleState;
    }


    function getPlayer(uint256 playerIndex) external view returns( address){
        return s_players[playerIndex];
        
    } 

}
