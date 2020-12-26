pragma solidity ^0.5.0; 

 interface RegisterSC{
         function isBuyerExist(address addr) external view returns (bool); 
    }

contract PlasticBale{
    

    address[] public plasticBale; // retrived from plasticBaleCompleted event and passed through web3.js
    address [] public contributors; // retrived from plasticBaleCompleted event and passed through web3.js
  
  struct bid{
      bool open; 
      uint highestBid; 
      address payable highestBidder; 
      uint startTime; 
      uint endTime; 
  }
  
  mapping(address=>bid) auction; 
  
  struct buyer{
      bool isExist; 
      uint placedBids; 
      uint deposit; 
  }
  
  mapping(address=>buyer) bidder; 
  
  //Seller is the auctionOwner 
   address payable auctionOwner;
   
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
    
    modifier onlyBidder(address registerContractAddr, address bidderAddr){
        RegisterSC registerSC = RegisterSC(registerContractAddr); //pass contract address 
        require(registerSC.isBuyerExist(bidderAddr), "Bidder is not registered"); // might need to edit this to msg.sender instead bidderAddr
        _;                                                                        //when developing the Dapp 
    }
    
    event bidderRegistered (address bidderAddress); 
    event auctionStarted (uint startingAmount, uint closingTime); 
    event bidPlaced(address biddeAddress, uint amount);
    event bidderExited(address bidderAddress); 
    event bidderRefunded(address biddeAddress, uint amount); 
    event auctionEnded (address highestBidder, uint highestBid , uint closingTime); 
    
    
    function addBidder(address registerContractAddr, address bidderAddr) onlyBidder(registerContractAddr, bidderAddr) public {
        
    require(bidder[bidderAddr].isExist == false, "Bidder already joined the Auction.");
    totalBidders++; 
    bidder[bidderAddr] = buyer(true, 0, 0); 
    
    emit bidderRegistered(bidderAddr);
        
    }
    
    function startAuction(uint closingTime, uint startPrice) onlyOwner payable public {
        
        require(auction[msg.sender].open == false, "Auction is already open."); 
        
        require(closingTime > now, "Auction time can only be set in future.");
        
        require(totalBidders >= 2, "Not enough bidders are participating."); 
        
        require(msg.value >= startPrice || bidder[msg.sender].deposit >= startPrice, "Insufficient Deposit.."); 
        
        /*MIGHT BE WROOOOONG
        bidder[msg.sender].deposit = msg.value;  */ 
        
        // address(0) is 0X00.. which is the genusis block 
        auction[msg.sender] = bid(true, startPrice, address(0), now, closingTime); 
        
        emit auctionStarted(startPrice, closingTime); 
    }
    
    function placeBid(address registerContractAddr,address bidderAddr, uint amount)  onlyBidder(registerContractAddr, bidderAddr) payable public{
        
        require(bidder[bidderAddr].isExist, "Buyer Address is not registered."); 
        
        //something could be wrong here - wrong address 
        require(auction[msg.sender].open,"Auction is not opened.");
        
        // To place a bid, amount sent has to be bigger than the highest bid 
        require(amount > auction[msg.sender].highestBid, "Place a higher bid."); 
        
        //Validating the amount of wei sent with the transaction 
        require(msg.value == amount, "Insufficient Deposit."); 
        
        bidder[msg.sender].placedBids++; //STOPPED HERE WHEN CHECKING 
        bidder[msg.sender].deposit += msg.value; 
        
        auction[bidderAddr].highestBid = amount; 
        auction[bidderAddr].highestBidder= msg.sender; 
        
        emit bidPlaced(msg.sender, amount); 
        
    }
    
    function exitAuction(address registerContractAddr, address bidderAddr) onlyBidder(registerContractAddr, bidderAddr) public {
        
        require(bidder[msg.sender].placedBids == 0, "Buyer has placed a bid already."); 
        refundBuyerDeposit(registerContractAddr, bidderAddr); 
        bidder[msg.sender] = buyer(false, 0 ,0); 
        totalBidders--; 
        emit bidderExited(msg.sender); 
        
    }
    
    function refundBuyerDeposit(address registerContractAddr, address bidderAddr) onlyBidder(registerContractAddr, bidderAddr) public{
        (msg.sender).transfer(bidder[msg.sender].deposit); 
        emit bidderRefunded(msg.sender, bidder[msg.sender].deposit); 
        
    }
    
    function endAuction() onlyOwner public{
        
        require(auction[msg.sender].open, "Auction is not avalible.");
        require(auction[msg.sender].endTime < now, "Auction duration is not up yet.");
        require(auction[msg.sender].highestBidder != address(0), "No bids have been placed"); 
        
        //close the bid
        auction[msg.sender].open = false; 
        
        //Calculate shares 
        
        uint halfAmount = auction[msg.sender].highestBid/2;
        
        // Pay the seller 
        (auctionOwner).transfer(halfAmount); 
        
        //Calculate each participants' share & reward recyclers 
         
        
    }
    
    // For debugging 
     function getTime()  public view returns (uint){
        return now + 5 minutes; 
    }
    
    
}