pragma solidity ^0.5.0; 

 interface RegisterSC{
       function getSellerSortingmMachineDetails(address addr) external view returns ( address [] memory); 
    }
    

contract Tracking{
    
    //state variables - stored permanently in contract storage 
    string public status;
    address public plasticBottleAddress; // attained by scanning the QR code
    address public caller; 
    
    
    // ADD SOLD STATUS!!!!!!! ==> could be added in plastic bale SC
    
    //event 
    event updateStatus(address plasticBottleAddress, string status, uint time); 
    event debug(address [] tempArray);  
    
    modifier sortingMachineOnly (address registerContractAddr, address sellerAddr){
        
        address[] memory tempArray; 

       RegisterSC registerSC = RegisterSC(registerContractAddr); //pass contract address 
       tempArray = registerSC.getSellerSortingmMachineDetails(sellerAddr); // pass address of sorting facility-seller
       
       emit debug(tempArray);
       
       for(uint256 i=0; i< tempArray.length; i++){ //only registered sorting machines can update the status of the bottle 
           require(caller == tempArray[i],"Sorting machine is not registered.");
           _;
       }
        
   }
    

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
        emit updateStatus(plasticBottleAddress, status, now); 
    }
    
    function updateStatusSorted (address registerContractAddr, address sellerAddr) public sortingMachineOnly (registerContractAddr, sellerAddr){
        status = 'sorted';
        emit updateStatus(plasticBottleAddress, status, now); 
       
    }  
    
}