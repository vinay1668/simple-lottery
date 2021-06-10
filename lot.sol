pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Mylottery is VRFConsumerBase {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    uint public randomResult;
    
    address owner;
    mapping(address => uint) ticket;
    
    struct dat {
        address[] winners;
        uint256[] winnerInvest;
        uint ticketBalance;
    }
    mapping(uint => dat) getTicketOwners;
    
    uint totalPlayers = 0;
    uint balance = 0;
    
    
        constructor() VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
        ) public
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
    }
    
   
    
    function buyTicket(uint32 _pickedNumber) public payable{
        require(msg.value >= 1 ether);
        require(ticket[msg.sender] == 0);
        ticket[msg.sender] = _pickedNumber;
        balance = balance + msg.value;
        getTicketOwners[_pickedNumber].winners.push(msg.sender);
        getTicketOwners[_pickedNumber].winnerInvest.push(msg.value);
        getTicketOwners[_pickedNumber].ticketBalance = getTicketOwners[_pickedNumber].ticketBalance + msg.value;
        
        
        totalPlayers++;
        
        if(totalPlayers == 1) {

            getRandomNumber(uint(msg.sender));
            
        
            for(uint i = 0; i < getTicketOwners[randomResult].winners.length; i++)
            {
                
                 address send = getTicketOwners[randomResult].winners[i];
                 uint amount = (balance/getTicketOwners[randomResult].ticketBalance) * getTicketOwners[randomResult].winnerInvest[i];
                 payable(send).transfer(amount);
            }
            
            
            
            
            
            
        }
        

        
    }
    
    function getRandomNumber(uint256 userProvidedSeed) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }

  
    
    
}