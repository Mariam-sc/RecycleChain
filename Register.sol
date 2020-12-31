pragma solidity ^0.5.0; 

contract Register{
    
    //state variables - stored permanently in contract storage 
    
    // goverment entity - municipality 
    address public govermentEntity; 
    uint x; 
    
    //manufacturer
    struct Manufacturer {
    address  manufacturerAddress; 
    string  manufacturerLocation;
    string manufacturerName;
    uint manufacturerIdenfiter; // used in bottle address production 
    bool isExist;
    }
    
    
    //buyer 
    struct Buyer{
    address buyerAddress; 
    string buyerName; 
    string buyerLocation; 
    string buyerBusinessType; 
    bool isExist;
   
    }
  
    //seller - sorting facility 
    struct Seller {
        address sellerAddress; 
        string sellerLocation;
        string sellerName;
        address [] sortingMachineAddress; // dynamic array 
        bool isExist;
    }
    
    
    //constructor - initilize state variables
    constructor() public{
     govermentEntity = msg.sender; 
     x = 0; 
    }
    
    // Mappings 
    mapping (address => Manufacturer) registeredManufacturers; 
    mapping (address => Buyer) registeredBuyers; 
    mapping (address => Seller) registeredSellers; 
    
    modifier onlyGovermentEntity{
        require(msg.sender == govermentEntity, "Entity not authorized to register stakeholders.");
        _;
    }
    
    // register manufactuerer if it doesn't exist 
    function registerManufactuerer (address addr, string memory manufacturerLocation,  string memory manufacturerName) public onlyGovermentEntity {
        require(registeredManufacturers[addr].isExist == false , "Manufactuerer is registered already."); 
        registeredManufacturers[addr] = Manufacturer(addr, manufacturerLocation, manufacturerName,x, true);
        x++; // increment idenfitier 
    }
    
    // returns manufacturer details when called from outside the contract 
    function getManufactuererDetails(address addr) external view returns (address, string memory, string memory){
        
        return(registeredManufacturers[addr].manufacturerAddress, registeredManufacturers[addr].manufacturerLocation, registeredManufacturers[addr].manufacturerName);
    }
    
    // register buyer if it doesn't exist 
    function registerBuyer (address addr, string memory buyerName, string memory buyerLocation, string memory buyerBusinessType) public onlyGovermentEntity {
        require(registeredBuyers[addr].isExist == false , "Buyer is registered already."); 
        
        registeredBuyers[addr] = Buyer(addr, buyerName, buyerLocation, buyerBusinessType, true);
    }
    
    // returns buyer details when called from outside the contract 
    function getBuyerDetails(address addr) external view returns (address, string memory,string memory, string memory){
        
        return(registeredBuyers[addr].buyerAddress, registeredBuyers[addr].buyerName, registeredBuyers[addr].buyerLocation, registeredBuyers[addr].buyerBusinessType);
    }
    
    // register seller if it doesn't exist 
    function registerSeller (address addr, string memory sellerLocation, string  memory sellerName, address[] memory sortingMachineAddress) public onlyGovermentEntity {
        require(registeredSellers[addr].isExist == false , "Seller is registered already."); 
        
        registeredSellers[addr].sellerAddress = addr; 
        registeredSellers[addr].sellerLocation = sellerLocation; 
       registeredSellers[addr].sellerName = sellerName; 
        registeredSellers[addr].isExist = true;
        for (uint256 i =0; i < sortingMachineAddress.length; i++)
        registeredSellers[addr].sortingMachineAddress.push(sortingMachineAddress[i]); 
       
    }
    
     function getSellerDetails(address addr) external view returns (address, string memory,string memory){
        
        return(registeredSellers[addr].sellerAddress, registeredSellers[addr].sellerLocation,registeredSellers[addr].sellerName);
    }
    
    function getSellerSortingmMachineDetails(address addr) external view returns ( address [] memory){
        return(registeredSellers[addr].sortingMachineAddress); 
    }
    
    function isBuyerExist(address addr) external view returns (bool){
        return(registeredBuyers[addr].isExist);
    }
    
   function getManufactuererIdentifier(address manufacturerAddress) external view returns (uint){
        return registeredManufacturers[manufacturerAddress].manufacturerIdenfiter; 
   }
   
   // to be used in the bottleProductionSC
   function isManufactuererExist(address addr) external view returns (bool){
        return(registeredManufacturers[addr].isExist);
    }
    
} 
