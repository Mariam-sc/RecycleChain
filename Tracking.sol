pragma solidity ^0.5.0; 

contract Tracking{
    
    //state variables - stored permanently in contract storage 
    string public status;
    address public plasticBottleAddress; // attained by scanning the QR code
    address public caller; 
    
    //event 
    event updateStatus(address plasticBottleAddress, string status, uint time); 
    
    
    //constructor - initilize state variables
    constructor() public{
        status = 'NoStatus'; 
        caller = msg.sender; // address of the current caller
    }
    
    function setBottleAddress (address _plasticBotttleAddress) public {  // Paramenter is the scanned address on the bottle
        plasticBottleAddress = _plasticBotttleAddress; 
        
    }
    
    function updateStatusDisposed () public{
        status = 'disposed'; 
    }
    
    function updateStatusSorted () public{
        status = 'sorted'; 
    }
    
    function announcEvent () public payable { //do you want this payable??
        
        emit updateStatus(plasticBottleAddress, status, now); 
    }
    
    
  /* modifier sortingMachineOnly{
       require()
        
   }
    
    modifier recyclerOnly{
       require( )
        
   } */
    
}