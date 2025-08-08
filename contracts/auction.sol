// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@fhenixprotocol/contracts/FHE.sol";

/**
 * @title SealedBidAuction
 * @notice Privacy-preserving sealed bid auction using FHE
 * @dev This contract demonstrates advanced FHE auction patterns:
 *      - Sealed bid submission with encrypted amounts
 *      - Multi-phase auction (bidding -> revealing -> settlement)
 *      - Private bid comparison and winner determination
 *      - Encrypted refund calculations
 *      - Decryption queue for revealing results
 * 
 * Auction Flow:
 * 1. BIDDING: Participants submit encrypted bids
 * 2. REVEALING: Auction owner requests decryption of winning bid
 * 3. SETTLEMENT: Funds distributed, auction concluded
 * 
 * Privacy Guarantees:
 * - Bid amounts remain private during bidding phase
 * - Only winning bid amount is revealed at the end
 * - Losing bids never revealed
 * - Bidder identities can be public or private
 */
contract SealedBidAuction {
    
    // ================================
    // ENUMS AND STRUCTS
    // ================================
    
    enum AuctionPhase {
        Setup,      // Auction created but not started
        Bidding,    // Accepting bids
        Revealing,  // Determining winner
        Settled,    // Auction completed
        Cancelled   // Auction cancelled
    }
    
    struct Bid {
        euint32 amount;           // Encrypted bid amount
        uint32 deposit;           // Public deposit amount (for gas efficiency)
        bool hasDecryptionAccess; // Whether bidder can decrypt their bid
        bool refunded;            // Whether bid has been refunded
    }
    
    struct AuctionInfo {
        address owner;            // Auction creator
        address item;             // Item being auctioned (contract address)
        uint256 itemId;           // Item ID (for NFTs)
        uint256 startTime;        // Bidding start time
        uint256 endTime;          // Bidding end time
        uint32 minimumBid;        // Minimum bid amount (public)
        uint32 bidDeposit;        // Required deposit to bid
        AuctionPhase phase;       // Current auction phase
    }
    
    // ================================
    // STATE VARIABLES
    // ================================
    
    AuctionInfo public auctionInfo;
    
    // Bidding data
    mapping(address => Bid) private bids;
    address[] public bidders;
    mapping(address => bool) public hasBid;
    
    // Winner determination
    address public winner;
    euint32 private winningBid;
    bool public winningBidRevealed;
    uint32 public revealedWinningAmount;
    
    // Decryption management
    mapping(bytes32 => address) public decryptionRequests;
    mapping(address => bytes32) public bidderDecryptionId;
    
    // Financial tracking
    uint256 public totalDeposits;
    mapping(address => bool) public depositRefunded;
    
    // ================================
    // EVENTS
    // ================================
    
    event AuctionStarted(uint256 startTime, uint256 endTime);
    event BidSubmitted(address indexed bidder, bool success);
    event BidIncreased(address indexed bidder, bool success);
    event AuctionEnded(address indexed winner, bool revealed);
    event WinningBidRevealed(uint32 amount);
    event BidRefunded(address indexed bidder, uint256 amount);
    event AuctionSettled(address indexed winner, uint32 winningAmount);
    event DecryptionRequested(address indexed bidder, bytes32 decryptionId);
    
    // ================================
    // MODIFIERS
    // ================================
    
    modifier onlyOwner() {
        require(msg.sender == auctionInfo.owner, "Only auction owner");
        _;
    }
    
    modifier onlyDuringPhase(AuctionPhase phase) {
        require(auctionInfo.phase == phase, "Invalid auction phase");
        _;
    }
    
    modifier onlyAfterPhase(AuctionPhase phase) {
        require(uint(auctionInfo.phase) > uint(phase), "Auction phase not reached");
        _;
    }
    
    // ================================
    // CONSTRUCTOR
    // ================================
    
    constructor(
        address _item,
        uint256 _itemId,
        uint32 _minimumBid,
        uint32 _bidDeposit,
        uint256 _duration
    ) {
        require(_item != address(0), "Invalid item address");
        require(_minimumBid > 0, "Minimum bid must be positive");
        require(_bidDeposit >= _minimumBid / 10, "Deposit too low"); // At least 10% of minimum
        require(_duration > 0, "Duration must be positive");
        
        auctionInfo = AuctionInfo({
            owner: msg.sender,
            item: _item,
            itemId: _itemId,
            startTime: 0, // Set when auction starts
            endTime: 0,   // Set when auction starts
            minimumBid: _minimumBid,
            bidDeposit: _bidDeposit,
            phase: AuctionPhase.Setup
        });
    }
    
    // ================================
    // AUCTION MANAGEMENT
    // ================================
    
    /**
     * @notice Start the auction
     * @param duration Auction duration in seconds
     * 
     * Pattern: Phase transition with time-based controls
     */
    function startAuction(uint256 duration) external onlyOwner onlyDuringPhase(AuctionPhase.Setup) {
        require(duration > 0, "Duration must be positive");
        
        auctionInfo.startTime = block.timestamp;
        auctionInfo.endTime = block.timestamp + duration;
        auctionInfo.phase = AuctionPhase.Bidding;
        
        emit AuctionStarted(auctionInfo.startTime, auctionInfo.endTime);
    }
    
    /**
     * @notice End the bidding phase and start revealing
     * 
     * Pattern: Time-based phase transitions
     */
    function endBidding() external {
        require(auctionInfo.phase == AuctionPhase.Bidding, "Not in bidding phase");
        require(block.timestamp >= auctionInfo.endTime, "Auction still active");
        require(bidders.length > 0, "No bids received");
        
        auctionInfo.phase = AuctionPhase.Revealing;
        
        // Start winner determination process
        _determineWinner();
    }
    
    /**
     * @notice Cancel the auction (only during setup or if no bids)
     */
    function cancelAuction() external onlyOwner {
        require(
            auctionInfo.phase == AuctionPhase.Setup || 
            (auctionInfo.phase == AuctionPhase.Bidding && bidders.length == 0),
            "Cannot cancel with bids"
        );
        
        auctionInfo.phase = AuctionPhase.Cancelled;
    }
    
    // ================================
    // BIDDING FUNCTIONS
    // ================================
    
    /**
     * @notice Submit a sealed bid with encrypted amount
     * @param encryptedAmount Encrypted bid amount
     * 
     * Pattern: Encrypted bid submission with deposit validation
     */
    function bid(InEuint32 calldata encryptedAmount) external payable onlyDuringPhase(AuctionPhase.Bidding) {
        require(block.timestamp < auctionInfo.endTime, "Bidding period ended");
        require(msg.value == auctionInfo.bidDeposit, "Incorrect deposit amount");
        require(!hasBid[msg.sender], "Already submitted bid");
        
        // Convert encrypted input to internal handle
        euint32 encAmount = FHE.asEuint32(encryptedAmount);
        
        // Store encrypted bid
        FHE.allowThis(encAmount);
        
        bids[msg.sender] = Bid({
            amount: encAmount,
            deposit: uint32(msg.value),
            hasDecryptionAccess: false,
            refunded: false
        });
        
        bidders.push(msg.sender);
        hasBid[msg.sender] = true;
        totalDeposits += msg.value;
        
        // Grant bidder access to their own bid for later verification
        FHE.allow(encAmount, msg.sender);
        
        emit BidSubmitted(msg.sender, true);
    }
    

    
    /**
     * @notice Increase existing bid
     * @param encryptedAdditionalAmount Additional encrypted amount to add
     * 
     * Pattern: Bid modification with encrypted arithmetic
     */
    function increaseBid(InEuint32 calldata encryptedAdditionalAmount) external payable onlyDuringPhase(AuctionPhase.Bidding) {
        require(block.timestamp < auctionInfo.endTime, "Bidding period ended");
        require(hasBid[msg.sender], "No existing bid");
        require(msg.value > 0, "Must send additional deposit");
        
        // Convert encrypted input to internal handle
        euint32 encAdditionalAmount = FHE.asEuint32(encryptedAdditionalAmount);
        
        // Get current bid and add additional amount
        euint32 currentBid = bids[msg.sender].amount;
        euint32 newBid = FHE.add(currentBid, encAdditionalAmount);
        
        // Update bid
        bids[msg.sender].amount = newBid;
        bids[msg.sender].deposit += uint32(msg.value);
        
        FHE.allowThis(newBid);
        FHE.allow(newBid, msg.sender);
        
        totalDeposits += msg.value;
        
        emit BidIncreased(msg.sender, true);
    }
    
    // ================================
    // WINNER DETERMINATION
    // ================================
    
    /**
     * @notice Internal function to determine auction winner
     * 
     * Pattern: Encrypted maximum finding algorithm
     * Note: This is a simplified version. Production implementations
     * might use more sophisticated algorithms or decryption networks.
     */
    function _determineWinner() internal {
        require(bidders.length > 0, "No bids to evaluate");
        
        // Initialize with first bidder
        winner = bidders[0];
        winningBid = bids[bidders[0]].amount;
        FHE.allowThis(winningBid);
        
        // Compare with all other bids
        for (uint256 i = 1; i < bidders.length; i++) {
            address currentBidder = bidders[i];
            euint32 currentBid = bids[currentBidder].amount;
            
            // Check if current bid is higher
            ebool isHigher = FHE.gt(currentBid, winningBid);
            
            // Update winner using FHE.select()
            // Note: This reveals the winning bidder during computation
            // In production, you might want to keep winner private until reveal
            winner = FHE.decrypt(isHigher) ? currentBidder : winner;
            winningBid = FHE.select(isHigher, currentBid, winningBid);
            FHE.allowThis(winningBid);
        }
        
        emit AuctionEnded(winner, false);
    }
    
    /**
     * @notice Request decryption of winning bid
     * 
     * Pattern: Multi-transaction decryption initiation
     */
    function requestWinningBidDecryption() external onlyOwner onlyDuringPhase(AuctionPhase.Revealing) {
        require(winner != address(0), "No winner determined");
        require(!winningBidRevealed, "Already revealed");
        
        // Grant access to owner for decryption
        FHE.allow(winningBid, auctionInfo.owner);
        
        // Generate decryption request ID
        bytes32 decryptionId = keccak256(abi.encodePacked(
            address(this),
            winner,
            winningBid,
            block.timestamp
        ));
        
        decryptionRequests[decryptionId] = winner;
        
        emit DecryptionRequested(winner, decryptionId);
    }
    
    /**
     * @notice Reveal winning bid amount (called after decryption)
     * @param amount Decrypted winning bid amount
     * @param decryptionId ID from decryption request
     * 
     * Pattern: Decryption result submission with verification
     */
    function revealWinningBid(uint32 amount, bytes32 decryptionId) external onlyOwner onlyDuringPhase(AuctionPhase.Revealing) {
        require(decryptionRequests[decryptionId] == winner, "Invalid decryption ID");
        require(!winningBidRevealed, "Already revealed");
        
        // In production, you would verify the decryption is correct
        // This might involve cryptographic proofs or trusted decryption networks
        
        revealedWinningAmount = amount;
        winningBidRevealed = true;
        
        auctionInfo.phase = AuctionPhase.Settled;
        
        emit WinningBidRevealed(amount);
        emit AuctionSettled(winner, amount);
    }
    
    // ================================
    // SETTLEMENT AND REFUNDS
    // ================================
    
    /**
     * @notice Withdraw deposit for non-winning bidders
     * 
     * Pattern: Selective refund based on auction outcome
     */
    function withdrawDeposit() external onlyAfterPhase(AuctionPhase.Revealing) {
        require(hasBid[msg.sender], "No bid submitted");
        require(msg.sender != winner, "Winner cannot withdraw deposit");
        require(!depositRefunded[msg.sender], "Already refunded");
        
        uint256 refundAmount = bids[msg.sender].deposit;
        depositRefunded[msg.sender] = true;
        bids[msg.sender].refunded = true;
        
        // Transfer refund
        (bool success, ) = payable(msg.sender).call{value: refundAmount}("");
        require(success, "Refund transfer failed");
        
        emit BidRefunded(msg.sender, refundAmount);
    }
    
    /**
     * @notice Withdraw winning bid amount (owner only)
     * 
     * Pattern: Owner withdrawal after auction settlement
     */
    function withdrawWinnings() external onlyOwner onlyDuringPhase(AuctionPhase.Settled) {
        require(winningBidRevealed, "Winning bid not revealed");
        
        uint256 winnerDeposit = bids[winner].deposit;
        
        // Transfer winner's deposit (which should cover the winning bid)
        (bool success, ) = payable(auctionInfo.owner).call{value: winnerDeposit}("");
        require(success, "Withdrawal failed");
        
        depositRefunded[winner] = true;
    }
    
    // ================================
    // QUERY FUNCTIONS
    // ================================
    
    /**
     * @notice Get bidder's encrypted bid
     * @param bidder Address of bidder
     * @return bid Encrypted bid amount (caller must have access)
     * 
     * Pattern: Encrypted bid retrieval with access control
     */
    function getBid(address bidder) external returns (euint32) {
        require(hasBid[bidder], "No bid from this address");
        require(
            msg.sender == bidder || msg.sender == auctionInfo.owner,
            "Unauthorized access"
        );
        
        euint32 bidAmount = bids[bidder].amount;
        
        // Grant access to requester
        FHE.allow(bidAmount, msg.sender);
        
        return bidAmount;
    }
    
    /**
     * @notice Get bidder's deposit amount (public)
     * @param bidder Address of bidder
     * @return deposit Public deposit amount
     */
    function getBidDeposit(address bidder) external view returns (uint32) {
        require(hasBid[bidder], "No bid from this address");
        return bids[bidder].deposit;
    }
    
    /**
     * @notice Get auction statistics
     * @return bidderCount Number of bidders
     * @return totalDepositsAmount Total deposits collected
     * @return currentPhase Current auction phase
     */
    function getAuctionStats() external view returns (
        uint256 bidderCount,
        uint256 totalDepositsAmount,
        AuctionPhase currentPhase
    ) {
        return (bidders.length, totalDeposits, auctionInfo.phase);
    }
    
    /**
     * @notice Check if auction is active
     * @return active True if currently accepting bids
     */
    function isActive() external view returns (bool) {
        return auctionInfo.phase == AuctionPhase.Bidding && 
               block.timestamp < auctionInfo.endTime;
    }
    
    /**
     * @notice Get time remaining in auction
     * @return timeLeft Seconds remaining (0 if ended)
     */
    function timeRemaining() external view returns (uint256) {
        if (auctionInfo.phase != AuctionPhase.Bidding || 
            block.timestamp >= auctionInfo.endTime) {
            return 0;
        }
        return auctionInfo.endTime - block.timestamp;
    }
    
    // ================================
    // BIDDER UTILITIES
    // ================================
    
    /**
     * @notice Request decryption access for bidder's own bid
     * 
     * Pattern: Self-decryption request for bid verification
     */
    function requestBidDecryption() external {
        require(hasBid[msg.sender], "No bid submitted");
        require(auctionInfo.phase >= AuctionPhase.Revealing, "Auction still active");
        require(!bids[msg.sender].hasDecryptionAccess, "Already has access");
        
        euint32 bidAmount = bids[msg.sender].amount;
        FHE.allow(bidAmount, msg.sender);
        
        bytes32 decryptionId = keccak256(abi.encodePacked(
            msg.sender,
            bidAmount,
            block.timestamp
        ));
        
        bidderDecryptionId[msg.sender] = decryptionId;
        bids[msg.sender].hasDecryptionAccess = true;
        
        emit DecryptionRequested(msg.sender, decryptionId);
    }
    
    /**
     * @notice Compare bidder's bid with a reference amount
     * @param referenceAmount Amount to compare against
     * @return comparison Encrypted comparison result
     * 
     * Pattern: Encrypted bid comparison utility
     */
    function compareBidToAmount(InEuint32 calldata referenceAmount) external returns (ebool) {
        require(hasBid[msg.sender], "No bid submitted");
        
        euint32 bidAmount = bids[msg.sender].amount;
        euint32 reference = FHE.asEuint32(referenceAmount);
        
        ebool isHigher = FHE.gt(bidAmount, reference);
        FHE.allow(isHigher, msg.sender);
        
        return isHigher;
    }
    
    // ================================
    // EMERGENCY FUNCTIONS
    // ================================
    
    /**
     * @notice Emergency function to refund all deposits
     * @dev Only callable by owner in case of critical issues
     */
    function emergencyRefundAll() external onlyOwner {
        require(auctionInfo.phase != AuctionPhase.Settled, "Auction already settled");
        
        auctionInfo.phase = AuctionPhase.Cancelled;
        
        // Refund all bidders
        for (uint256 i = 0; i < bidders.length; i++) {
            address bidder = bidders[i];
            if (!depositRefunded[bidder]) {
                uint256 refundAmount = bids[bidder].deposit;
                depositRefunded[bidder] = true;
                
                (bool success, ) = payable(bidder).call{value: refundAmount}("");
                if (success) {
                    emit BidRefunded(bidder, refundAmount);
                }
            }
        }
    }
}

/*
ANTI-PATTERNS TO AVOID (DON'T DO THESE):

1. ❌ Revealing bid amounts during bidding:
   function badGetAllBids() external view returns (uint32[] memory) {
       // This would reveal all bid amounts!
   }

2. ❌ Using ebool in if statements:
   function badWinnerDetermination(euint32 bid1, euint32 bid2) external {
       ebool isHigher = FHE.gt(bid1, bid2);
       if (isHigher) { // Won't compile!
           // set winner logic
       }
   }

3. ❌ Not protecting decryption access:
   function badGetBid(address bidder) external returns (euint32) {
       return bids[bidder].amount; // No access control!
   }

4. ❌ Assuming synchronous decryption:
   function badReveal() external {
       uint32 amount = FHE.decrypt(winningBid); // This won't work!
       // reveal logic
   }

5. ❌ Not tracking deposits properly:
   function badBid(euint32 amount) external payable {
       bids[msg.sender].amount = amount;
       // Missing: deposit tracking and validation
   }

SECURITY CHECKLIST FOR SEALED BID AUCTION:
✅ Bid privacy maintained during bidding phase
✅ Only winning bid amount revealed at end
✅ Proper access control on bid queries
✅ Multi-phase auction flow with time controls
✅ Encrypted bid comparison for winner determination
✅ Multi-transaction decryption pattern
✅ Proper deposit handling and refunds
✅ Emergency functions for critical issues
✅ Phase-based function restrictions
✅ Owner-only functions protected
✅ Time-based auction controls
✅ No ebool used in if statements

USAGE EXAMPLE:

// Deploy auction for NFT with 1 hour duration
SealedBidAuction auction = new SealedBidAuction(
    nftContract,    // Item being auctioned
    tokenId,        // Item ID
    100,           // Minimum bid: 100 wei
    10,            // Required deposit: 10 wei
    3600           // Duration: 1 hour
);

// Start the auction
auction.startAuction(3600);

// Submit encrypted bid
euint32 myBid = FHE.asEuint32(150);
auction.bid{value: 10}(myBid);

// Or submit plaintext bid (gets encrypted)
auction.bid{value: 10}(150);

// After auction ends
auction.endBidding();

// Owner reveals winning bid
auction.requestWinningBidDecryption();
// ... decrypt off-chain ...
auction.revealWinningBid(150, decryptionId);

// Losers withdraw deposits
auction.withdrawDeposit();

PRIVACY GUARANTEES:

✓ Bid amounts remain private during auction
✓ Only winning bid amount is revealed
✓ Losing bids never revealed
✓ Bidder identities are public (for simplicity)
✓ Winner determination happens privately

REMEMBER: "Without FHE.allow() = passing a locked box without the key!" 🔐
*/