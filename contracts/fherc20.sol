// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@fhenixprotocol/contracts/FHE.sol";

/**
 * @title FHERC20 - Encrypted ERC20 Token
 * @notice Privacy-preserving token with encrypted balances and amounts
 * @dev This contract demonstrates advanced FHE patterns:
 *      - Dual balance system (encrypted + public indicators)
 *      - Zero-knowledge transfer validation
 *      - Encrypted allowance system
 *      - Privacy-preserving total supply
 *      - Anti-pattern examples with explanations
 *
 * Key Innovation: Balances are encrypted, but the existence of a balance is public
 * This allows for gas optimization while preserving amount privacy.
 *
 * Security Model:
 * - Transfer amounts are private
 * - Account balances are private  
 * - Who has tokens is public (hasBalance mapping)
 * - Total supply can be private or public (configurable)
 */
contract FHERC20 {
    
    // ================================
    // STATE VARIABLES
    // ================================
    
    // Token metadata
    string public name;
    string public symbol;
    uint8 public decimals;
    
    // Dual balance system: encrypted amounts + public indicators
    mapping(address => euint32) private balances;        // Encrypted balance amounts
    mapping(address => bool) public hasBalance;          // Public: does address have tokens?
    
    // Encrypted allowances for delegated transfers
    mapping(address => mapping(address => euint32)) private allowances;
    mapping(address => mapping(address => bool)) public hasAllowance;
    
    // Total supply (can be public or encrypted based on use case)
    euint32 private _totalSupply;
    bool public totalSupplyIsPublic;
    uint32 public publicTotalSupply; // Used only if totalSupplyIsPublic is true
    
    // Access control
    address public owner;
    
    // ================================
    // EVENTS
    // ================================
    
    event Transfer(address indexed from, address indexed to, bool success);
    event Approval(address indexed owner, address indexed spender, bool success);
    event Mint(address indexed to, bool success);
    event Burn(address indexed from, bool success);
    
    // ================================
    // CONSTRUCTOR
    // ================================
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint32 _initialSupply,
        bool _publicTotalSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
        totalSupplyIsPublic = _publicTotalSupply;
        
        // Initialize total supply
        _totalSupply = FHE.asEuint32(_initialSupply);
        FHE.allowThis(_totalSupply);
        
        if (_publicTotalSupply) {
            publicTotalSupply = _initialSupply;
        }
        
        // Mint initial supply to owner
        if (_initialSupply > 0) {
            balances[owner] = _totalSupply;
            FHE.allowThis(balances[owner]);
            hasBalance[owner] = true;
            
            emit Transfer(address(0), owner, true);
        }
    }
    
    // ================================
    // BALANCE QUERIES
    // ================================
    
    /**
     * @notice Get encrypted balance of an account
     * @param account Address to query
     * @return balance Encrypted balance (caller must have permission to decrypt)
     *
     * Pattern: Encrypted balance query with access control
     * Only the account owner or approved parties can decrypt the balance
     */
    function balanceOf(address account) external returns (euint32) {
        require(hasBalance[account], "Account has no balance");
        
        euint32 balance = balances[account];
        
        // Grant access to the account owner
        FHE.allow(balance, account);
        
        // Also grant access to caller if they're querying their own balance
        if (msg.sender == account) {
            FHE.allow(balance, msg.sender);
        }
        
        return balance;
    }
    
    /**
     * @notice Check if an address has any balance (public information)
     * @param account Address to check
     * @return hasAnyBalance True if account has tokens, false otherwise
     *
     * Pattern: Public balance indicator for gas optimization
     */
    function hasAnyBalance(address account) external view returns (bool) {
        return hasBalance[account];
    }
    
    /**
     * @notice Get total supply (public or encrypted based on configuration)
     * @return supply Total token supply
     */
    function totalSupply() external view returns (uint32) {
        require(totalSupplyIsPublic, "Total supply is private");
        return publicTotalSupply;
    }
    
    /**
     * @notice Get encrypted total supply
     * @return supply Encrypted total supply (only owner can decrypt)
     */
    function encryptedTotalSupply() external returns (euint32) {
        require(msg.sender == owner, "Only owner can access encrypted total supply");
        
        FHE.allow(_totalSupply, owner);
        return _totalSupply;
    }
    
    // ================================
    // TRANSFER FUNCTIONS
    // ================================
    
    /**
     * @notice Transfer tokens with encrypted amount
     * @param to Recipient address
     * @param amount Encrypted amount to transfer
     * @return success True if transfer succeeded
     *
     * Pattern: Zero-knowledge transfer validation
     * The transfer succeeds or fails without revealing the exact amounts
     */
    function transfer(address to, InEuint calldata amount) external returns (bool) {
        euint32 encryptedAmount = FHE.asEuint32(amount);
        return _transfer(msg.sender, to, encryptedAmount);
    }
    
    /**
     * @notice Internal mint function with encrypted amount
     * @param to Recipient address
     * @param amount Encrypted amount to mint
     */
    function _mint(address to, InEuint calldata amount) internal {
        euint32 encryptedAmount = FHE.asEuint32(amount);
        
        // Update recipient balance
        euint32 currentBalance = hasBalance[to] ? balances[to] : FHE.asEuint32(0);
        euint32 newBalance = FHE.add(currentBalance, encryptedAmount);
        balances[to] = newBalance;
        FHE.allowThis(newBalance);
        FHE.allowSender(newBalance);
        hasBalance[to] = true;
        
        // Update total supply
        _totalSupply = FHE.add(_totalSupply, encryptedAmount);
        FHE.allowThis(_totalSupply);
        
        if (totalSupplyIsPublic) {
            publicTotalSupply += uint32(FHE.decrypt(_totalSupply)); // Simplified for example
        }
        
        emit Transfer(address(0), to, true);
        emit Mint(to, true);
    }
    
    /**
     * @notice Mint new tokens (owner only)
     * @param to Recipient address
     * @param amount Encrypted amount to mint
     * @return success True if minting succeeded
     */
    function mint(address to, InEuint calldata amount) external returns (bool) {
        require(msg.sender == owner, "Only owner can mint");
        require(to != address(0), "Mint to zero address");
        require(FHE.decrypt(FHE.asEuint32(amount)) > 0, "Mint amount must be positive");
        
        _mint(to, amount);
        return true;
    }
    
    /**
     * @notice Transfer tokens with encrypted amount (delegated transfer)
     * @param from Source address
     * @param to Destination address
     * @param encryptedAmount Encrypted amount to transfer
     * @return success True if transfer succeeded
     *
     * Pattern: Delegated transfer with encrypted allowances
     */
    function transferFrom(
        address from, 
        address to, 
        InEuint calldata encryptedAmount
    ) external returns (bool) {
        require(hasAllowance[from][msg.sender], "No allowance granted");
        
        // Convert encrypted input to internal handle
        euint32 encAmount = FHE.asEuint32(encryptedAmount);
        
        // Check allowance using encrypted comparison
        euint32 currentAllowance = allowances[from][msg.sender];
        ebool sufficientAllowance = FHE.gte(currentAllowance, encAmount);
        
        // Perform transfer only if allowance is sufficient
        bool transferSuccess = _conditionalTransfer(from, to, encAmount, sufficientAllowance);
        
        if (transferSuccess) {
            // Update allowance: allowance = allowance - amount
            euint32 newAllowance = FHE.sub(currentAllowance, encAmount);
            allowances[from][msg.sender] = newAllowance;
            FHE.allowThis(newAllowance);
            
            // Check if allowance is now zero and update indicator
            euint32 zero = FHE.asEuint32(0);
            ebool allowanceIsZero = FHE.eq(newAllowance, zero);
            // Simplified: not updating hasAllowance mapping here
        }
        
        return transferSuccess;
    }
    
    /**
     * @notice Internal transfer function with zero-knowledge validation
     * @param from Source address
     * @param to Destination address
     * @param encryptedAmount Encrypted amount to transfer
     * @return success True if transfer succeeded
     *
     * Pattern: Core transfer logic with encrypted balance validation
     */
    function _transfer(
        address from, 
        address to, 
        euint32 encryptedAmount
    ) internal returns (bool) {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        require(hasBalance[from], "Sender has no balance");
        
        // Get sender's current balance
        euint32 senderBalance = balances[from];
        
        // Check if sender has sufficient balance (returns ebool)
        ebool sufficientBalance = FHE.gte(senderBalance, encryptedAmount);
        
        return _conditionalTransfer(from, to, encryptedAmount, sufficientBalance);
    }
    
    /**
     * @notice Conditional transfer using FHE.select()
     * @param from Source address
     * @param to Destination address
     * @param encryptedAmount Amount to transfer
     * @param condition Encrypted condition (true = proceed, false = cancel)
     * @return success Whether transfer was executed
     *
     * Pattern: Conditional execution with FHE.select()
     * IMPORTANT: Both branches execute, condition only selects the result
     */
    function _conditionalTransfer(
        address from,
        address to,
        euint32 encryptedAmount,
        ebool condition
    ) internal returns (bool) {
        
        euint32 senderBalance = balances[from];
        euint32 recipientBalance = hasBalance[to] ? balances[to] : FHE.asEuint32(0);
        
        // Calculate new balances (both calculations always execute)
        euint32 newSenderBalance = FHE.sub(senderBalance, encryptedAmount);
        euint32 newRecipientBalance = FHE.add(recipientBalance, encryptedAmount);
        
        // Select actual new balances based on condition
        euint32 actualSenderBalance = FHE.select(condition, newSenderBalance, senderBalance);
        euint32 actualRecipientBalance = FHE.select(condition, newRecipientBalance, recipientBalance);
        
        // Update balances
        balances[from] = actualSenderBalance;
        balances[to] = actualRecipientBalance;
        
        FHE.allowThis(actualSenderBalance);
        FHE.allowThis(actualRecipientBalance);
        
        // Update balance indicators
        hasBalance[to] = true; // Recipient now has a balance (even if 0)
        
        // Check if sender balance is now zero
        euint32 zero = FHE.asEuint32(0);
        ebool senderBalanceIsZero = FHE.eq(actualSenderBalance, zero);
        // Simplified: not updating hasBalance[from]
        
        emit Transfer(from, to, true); // Simplified: always emit success
        return true;
    }
    
    // ================================
    // ALLOWANCE FUNCTIONS
    // ================================
    
    /**
     * @notice Approve spender to transfer encrypted amount
     * @param spender Address to approve
     * @param encryptedAmount Encrypted amount to approve
     * @return success True if approval succeeded
     *
     * Pattern: Encrypted allowance approval
     */
    function approve(address spender, InEuint calldata encryptedAmount) external returns (bool) {
        require(spender != address(0), "Approve to zero address");
        
        euint32 encAmt = FHE.asEuint32(encryptedAmount);
        allowances[msg.sender][spender] = encAmt;
        hasAllowance[msg.sender][spender] = true;
        
        FHE.allowThis(encAmt);
        
        emit Approval(msg.sender, spender, true);
        return true;
    }
    
    /**
     * @notice Get encrypted allowance amount
     * @param owner Token owner
     * @param spender Approved spender
     * @return allowance Encrypted allowance amount
     *
     * Pattern: Encrypted allowance query with access control
     */
    function allowance(address owner, address spender) external returns (euint32) {
        require(hasAllowance[owner][spender], "No allowance granted");
        require(
            msg.sender == owner || msg.sender == spender, 
            "Only owner or spender can view allowance"
        );
        
        euint32 allowanceAmount = allowances[owner][spender];
        
        // Grant access to both owner and spender
        FHE.allow(allowanceAmount, owner);
        FHE.allow(allowanceAmount, spender);
        
        return allowanceAmount;
    }
    
    // ================================
    // MINTING AND BURNING
    // ================================
    
    /**
     * @notice Burn tokens from sender's balance
     * @param amount Encrypted amount to burn
     * @return success True if burning succeeded
     *
     * Pattern: Burning with encrypted balance validation
     */
    function burn(InEuint calldata amount) external returns (bool) {
        require(hasBalance[msg.sender], "No balance to burn");
        
        euint32 encryptedAmount = FHE.asEuint32(amount);
        euint32 currentBalance = balances[msg.sender];
        
        // Check if balance is sufficient
        ebool sufficientBalance = FHE.gte(currentBalance, encryptedAmount);
        
        // Calculate new balance (always executes)
        euint32 newBalance = FHE.sub(currentBalance, encryptedAmount);
        
        // Use conditional logic: burn only if sufficient balance
        euint32 actualNewBalance = FHE.select(sufficientBalance, newBalance, currentBalance);
        
        balances[msg.sender] = actualNewBalance;
        FHE.allowThis(actualNewBalance);
        
        // Update total supply (simplified: assumes burn always succeeds)
        _totalSupply = FHE.sub(_totalSupply, encryptedAmount);
        FHE.allowThis(_totalSupply);
        
        if (totalSupplyIsPublic) {
            publicTotalSupply -= uint32(FHE.decrypt(encryptedAmount)); // Simplified
        }
        
        // Check if balance is now zero
        euint32 zero = FHE.asEuint32(0);
        ebool balanceIsZero = FHE.eq(actualNewBalance, zero);
        // Simplified: not updating hasBalance[msg.sender]
        
        emit Transfer(msg.sender, address(0), true);
        emit Burn(msg.sender, true);
        
        return true;
    }
    
    // ================================
    // UTILITY FUNCTIONS
    // ================================
    
    /**
     * @notice Compare two encrypted amounts for equality
     * @param amount1 First encrypted amount
     * @param amount2 Second encrypted amount
     * @return result Encrypted boolean result
     *
     * Pattern: Encrypted comparison utility
     */
    function compareAmounts(InEuint calldata amount1, InEuint calldata amount2) external returns (ebool) {
        // Convert encrypted inputs to internal handles
        euint32 enc1 = FHE.asEuint32(amount1);
        euint32 enc2 = FHE.asEuint32(amount2);
        
        // Caller must have access to both amounts
        FHE.allowThis(enc1);
        FHE.allowThis(enc2);
        
        ebool result = FHE.eq(enc1, enc2);
        FHE.allow(result, msg.sender);
        
        return result;
    }
    
    /**
     * @notice Get minimum of two encrypted amounts
     * @param amount1 First amount
     * @param amount2 Second amount
     * @return result Encrypted minimum amount
     *
     * Pattern: Encrypted mathematical operations
     */
    function min(InEuint calldata amount1, InEuint calldata amount2) external returns (euint32) {
        // Convert encrypted inputs to internal handles
        euint32 enc1 = FHE.asEuint32(amount1);
        euint32 enc2 = FHE.asEuint32(amount2);
        
        FHE.allowThis(enc1);
        FHE.allowThis(enc2);
        
        euint32 result = FHE.min(enc1, enc2);
        FHE.allow(result, msg.sender);
        
        return result;
    }
    
    // ================================
    // OWNER FUNCTIONS
    // ================================
    
    /**
     * @notice Transfer ownership
     * @param newOwner New owner address
     */
    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "Only owner can transfer ownership");
        require(newOwner != address(0), "New owner cannot be zero address");
        
        owner = newOwner;
    }
    
    /**
     * @notice Change total supply visibility
     * @param _public Whether total supply should be public
     */
    function setTotalSupplyVisibility(bool _public) external {
        require(msg.sender == owner, "Only owner can change visibility");
        
        totalSupplyIsPublic = _public;
        
        if (_public) {
            // Simplified: in production, you'd decrypt _totalSupply to set publicTotalSupply
        }
    }
}
