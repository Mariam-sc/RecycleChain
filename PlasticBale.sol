pragma solidity ^0.5.0; 

 interface RegisterSC{
         function isBuyerExist(address addr) external view returns (bool); 
    }

contract PlasticBale{
    

    address[] public plasticBale; // retrived from plasticBaleCompleted event and passed through web3.js
    address [] public contributors; // retrived from plasticBaleCompleted event and passed through web3.js
  
 // Bid variables 
      bool public isOpen; 
      uint public highestBid; 
      address payable public highestBidder; 
      uint public startTime; 
      uint public endTime; 

  
  struct buyer{
      bool isExist; 
      uint placedBids; 
      uint deposit; 
  }
  
  //Bidder[BuyerAddress]
  mapping(address=>buyer) bidder; 
  
  //Seller is the auctionOwner 
   address payable public auctionOwner;
   
   // Bidders are the Buyers 
   uint totalBidders; 
    
    constructor(address[] memory _plasticBale, address[] memory _contributors ) public {
      plasticBale = _plasticBale; 
      contributors = _contributors; 
      auctionOwner = msg.sender; 
      totalBidders = 0; 
  }  
    
    
    modifier onlyOwner{
        require(msg.sender == auctionOwner, "Auction owner is not authorized"); 
        _; 
    }
    
    modifier onlyBidder(address registerContractAddr){
        RegisterSC registerSC = RegisterSC(registerContractAddr); //pass contract address 
        require(registerSC.isBuyerExist(msg.sender), "Bidder is not registered"); // might need to edit this to msg.sender instead bidderAddr
        _;                                                                        //when developing the Dapp 
    }
    
    event bidderRegistered (address bidderAddress); 
    event auctionStarted (uint startingAmount, uint closingTime); 
    event bidPlaced(address biddeAddress, uint amount);
    event bidderExited(address bidderAddress); 
    event bidderRefunded(address biddeAddress, uint amount); 
    event auctionEnded (address highestBidder, uint highestBid , uint closingTime); 
    
    
    function addBidder(address registerContractAddr, address bidderAddr) onlyBidder (registerContractAddr) public {
        
    require(bidder[bidderAddr].isExist == false, "Bidder already joined the Auction.");
    totalBidders++; 
    bidder[bidderAddr] = buyer(true, 0, 0); 
    
    emit bidderRegistered(bidderAddr);
        
    }
    
    function startAuction(uint closingTime, uint startPrice) onlyOwner payable public {
        
        require(isOpen == false, "Auction is already open."); 
        
        require( closingTime > now, "Auction time can only be set in future.");
        
        require(totalBidders >= 2, "Not enough bidders are participating."); 
    
        // address(0) is 0X00.. which is the genusis block 
        isOpen = true; 
        highestBid = startPrice; 
        highestBidder = address(0); 
        startTime = now; 
        endTime = closingTime; 
       
        emit auctionStarted(startPrice, closingTime); 
    }
    
    function placeBid(address registerContractAddr, uint amount)  onlyBidder(registerContractAddr) payable public{
        
        require(bidder[msg.sender].isExist, "Buyer Address is not registered."); 
        
        //something could be wrong here - wrong address (fixed but check)
        require(isOpen,"Auction is not opened.");
        
        // To place a bid, amount sent has to be bigger than the highest bid 
        require(amount > highestBid, "Place a higher bid."); 
        
        //Validating the amount of wei sent with the transaction 
        require(msg.value == amount, "Insufficient Deposit."); 
        
        bidder[msg.sender].placedBids++; //STOPPED HERE WHEN CHECKING 
        bidder[msg.sender].deposit += msg.value; 
        
        highestBid = amount; 
        highestBidder= msg.sender; 
        
        emit bidPlaced(msg.sender, amount); 
        
    }
    
    function exitAuction(address registerContractAddr) onlyBidder(registerContractAddr) public {
        
        // Buyers can exit auction if no bids are placed yet 
        require(bidder[msg.sender].placedBids == 0, "Buyer has placed a bid already."); 
        bidder[msg.sender] = buyer(false, 0 ,0); 
        totalBidders--; 
        emit bidderExited(msg.sender); 
    }
    
    
    function endAuction() onlyOwner public{
        
        require( isOpen, "Auction is not avalible.");
        require(endTime < now, "Auction duration is not up yet.");
        require(highestBidder != address(0), "No bids have been placed"); 
        
        //close the bid
        isOpen = false; 
        
        
        //Calculate shares 
        
        uint halfAmount = highestBid/2;
        
        // Pay the seller 
        (auctionOwner).transfer(halfAmount); 
        
        //Calculate each participants' share & reward recyclers 
        
        
        emit auctionEnded(highestBidder, highestBid , now); 
    
    }
    
    // For debugging 
     function getTime()  public view returns (uint){
        return now + 5 minutes; 
    }
    
    
}