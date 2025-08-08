// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@fhenixprotocol/contracts/FHE.sol";

/**
 * @title EncryptedCalculator
 * @notice Basic FHE operations demonstration contract
 * @dev This contract demonstrates fundamental FHE patterns:
 *      - Basic arithmetic operations on encrypted data
 *      - Access control with FHE.allow() and FHE.allowThis()
 *      - Multi-transaction decryption patterns
 *      - Error handling for division by zero
 *      - Conditional logic with FHE.select()
 *
 * Mental Model: "Without FHE.allow() = passing a locked box without the key!"
 *
 * Key Concepts Demonstrated:
 * - FHE types are handles (uint256) pointing to encrypted data
 * - Operations create computation graphs rather than immediate results
 * - Access control is mandatory for all encrypted values
 * - Multi-transaction flow required for decryption
 */
contract EncryptedCalculator {
    
    // State variables for demonstration
    mapping(address => euint32) private userResults;
    mapping(address => bool) public hasResult;
    
    // Events for tracking operations
    event OperationCompleted(address indexed user, string operation);
    event DecryptionRequested(address indexed user, euint32 result);
    
    /**
     * @notice Encrypted addition operation
     * @param a First operand (encrypted input)
     * @param b Second operand (encrypted input)
     * @return result Encrypted sum accessible to caller
     *
     * Pattern: Basic FHE arithmetic with access control
     */
    function add(InEuint32 calldata a, InEuint32 calldata b) external returns (euint32) {
        // Convert encrypted inputs to internal handles
        euint32 encA = FHE.asEuint32(a);
        euint32 encB = FHE.asEuint32(b);
        
        // Perform encrypted addition (creates computation graph)
        euint32 result = FHE.add(encA, encB);
        
        // CRITICAL: Grant access to caller - without this, caller can't decrypt!
        FHE.allow(result, msg.sender);
        
        emit OperationCompleted(msg.sender, "add");
        return result;
    }
    
    /**
     * @notice Encrypted subtraction operation
     * @param a Minuend (encrypted input)
     * @param b Subtrahend (encrypted input)
     * @return result Encrypted difference accessible to caller
     *
     * Pattern: Subtraction with underflow handling
     */
    function subtract(InEuint32 calldata a, InEuint32 calldata b) external returns (euint32) {
        euint32 encA = FHE.asEuint32(a);
        euint32 encB = FHE.asEuint32(b);
        
        // FHE subtraction handles underflow automatically (wrapping behavior)
        euint32 result = FHE.sub(encA, encB);
        
        FHE.allow(result, msg.sender);
        
        emit OperationCompleted(msg.sender, "subtract");
        return result;
    }
    
    /**
     * @notice Encrypted multiplication operation
     * @param a First factor (encrypted input)
     * @param b Second factor (encrypted input)
     * @return result Encrypted product accessible to caller
     *
     * Pattern: Multiplication with overflow considerations
     */
    function multiply(InEuint32 calldata a, InEuint32 calldata b) external returns (euint32) {
        euint32 encA = FHE.asEuint32(a);
        euint32 encB = FHE.asEuint32(b);
        
        // FHE multiplication (more computationally expensive than add/sub)
        euint32 result = FHE.mul(encA, encB);
        
        FHE.allow(result, msg.sender);
        
        emit OperationCompleted(msg.sender, "multiply");
        return result;
    }
    
    /**
     * @notice Encrypted division operation with zero-check
     * @param a Dividend (encrypted input)
     * @param b Divisor (encrypted input)
     * @return result Encrypted quotient or original dividend if divisor is zero
     *
     * Pattern: Conditional logic with FHE.select() for error handling
     * IMPORTANT: Both branches of FHE.select() always execute!
     */
    function divide(InEuint32 calldata a, InEuint32 calldata b) external returns (euint32) {
        euint32 encA = FHE.asEuint32(a);
        euint32 encB = FHE.asEuint32(b);
        euint32 zero = FHE.asEuint32(0);
        
        // Check if divisor is zero (returns ebool, not bool!)
        ebool isZero = FHE.eq(encB, zero);
        
        // Use FHE.select to handle zero divisor
        euint32 divisionResult = FHE.div(encA, encB);
        euint32 result = FHE.select(isZero, encA, divisionResult);
        
        FHE.allow(result, msg.sender);
        
        emit OperationCompleted(msg.sender, "divide");
        return result;
    }
    
    /**
     * @notice Find maximum of two encrypted values
     * @param a First value (encrypted input)
     * @param b Second value (encrypted input)
     * @return result Encrypted maximum accessible to caller
     *
     * Pattern: Comparison and conditional selection
     */
    function maximum(InEuint32 calldata a, InEuint32 calldata b) external returns (euint32) {
        euint32 encA = FHE.asEuint32(a);
        euint32 encB = FHE.asEuint32(b);
        
        // Compare encrypted values (returns ebool)
        ebool aIsGreater = FHE.gt(encA, encB);
        
        // Select maximum using conditional logic
        euint32 result = FHE.select(aIsGreater, encA, encB);
        
        FHE.allow(result, msg.sender);
        
        emit OperationCompleted(msg.sender, "maximum");
        return result;
    }
    
    /**
     * @notice Complex calculation with state storage
     * @param a First operand (encrypted input)
     * @param b Second operand (encrypted input)
     * @param c Third operand (encrypted input)
     * @return result Encrypted result of (a + b) * c, stored for user
     *
     * Pattern: State storage with FHE.allowThis() for contract access
     */
    function complexCalculation(InEuint32 calldata a, InEuint32 calldata b, InEuint32 calldata c) external returns (euint32) {
        euint32 encA = FHE.asEuint32(a);
        euint32 encB = FHE.asEuint32(b);
        euint32 encC = FHE.asEuint32(c);
        
        // Multi-step calculation: (a + b) * c
        euint32 sum = FHE.add(encA, encB);
        euint32 result = FHE.mul(sum, encC);
        
        // CRITICAL: Grant access to THIS contract for storage
        FHE.allowThis(result);
        
        // Store result for later retrieval
        userResults[msg.sender] = result;
        hasResult[msg.sender] = true;
        
        // Also grant access to user for immediate use
        FHE.allow(result, msg.sender);
        
        emit OperationCompleted(msg.sender, "complexCalculation");
        return result;
    }
    
    /**
     * @notice Retrieve user's stored calculation result
     * @return result User's stored encrypted result
     *
     * Pattern: Retrieving stored encrypted data with access control
     */
    function getStoredResult() external returns (euint32) {
        require(hasResult[msg.sender], "No stored result found");
        
        euint32 result = userResults[msg.sender];
        
        // Grant access to caller for this specific result
        FHE.allow(result, msg.sender);
        
        return result;
    }
    
    /**
     * @notice Multi-transaction decryption pattern demonstration
     * @param a Value to process (encrypted input)
     * @return resultId Identifier for tracking the decryption request
     *
     * Pattern: Async decryption workflow
     */
    function requestDecryption(InEuint32 calldata a) external returns (bytes32) {
        euint32 encA = FHE.asEuint32(a);
        euint32 doubled = FHE.mul(encA, FHE.asEuint32(2));
        
        // Generate unique ID for this decryption request
        bytes32 resultId = keccak256(abi.encodePacked(
            msg.sender,
            block.timestamp,
            doubled
        ));
        
        // Store the encrypted result with contract access
        FHE.allowThis(doubled);
        userResults[msg.sender] = doubled;
        
        // Grant access to user for decryption
        FHE.allow(doubled, msg.sender);
        
        emit DecryptionRequested(msg.sender, doubled);
        
        return resultId;
    }
    
    /**
     * @notice Conditional calculation based on comparison
     * @param x First value (encrypted input)
     * @param y Second value (encrypted input)
     * @param threshold Comparison threshold (encrypted input)
     * @return result Different calculation based on whether x > threshold
     *
     * Pattern: Complex conditional logic with multiple FHE.select() calls
     */
    function conditionalCalculation(
        InEuint32 calldata x,
        InEuint32 calldata y,
        InEuint32 calldata threshold
    ) external returns (euint32) {
        euint32 encX = FHE.asEuint32(x);
        euint32 encY = FHE.asEuint32(y);
        euint32 encThreshold = FHE.asEuint32(threshold);
        
        // Check if x > threshold
        ebool xAboveThreshold = FHE.gt(encX, encThreshold);
        
        // Two different calculations
        euint32 calculation1 = FHE.add(encX, encY);     // x + y
        euint32 calculation2 = FHE.mul(encX, encY);     // x * y
        
        // Select calculation based on condition
        euint32 result = FHE.select(
            xAboveThreshold,
            calculation1,  // Use addition if x > threshold
            calculation2   // Use multiplication if x <= threshold
        );
        
        FHE.allow(result, msg.sender);
        
        emit OperationCompleted(msg.sender, "conditionalCalculation");
        return result;
    }
    
    /**
     * @notice Batch operation on multiple values
     * @param values Array of encrypted values to sum
     * @return result Encrypted sum of all values
     *
     * Pattern: Iterative FHE operations
     */
    function batchSum(InEuint32[] calldata values) external returns (euint32) {
        require(values.length > 0, "Empty array");
        require(values.length <= 10, "Too many values"); // Gas limit protection
        
        // Initialize with first value
        euint32 result = FHE.asEuint32(values[0]);
        
        // Add remaining values
        for (uint256 i = 1; i < values.length; i++) {
            euint32 nextValue = FHE.asEuint32(values[i]);
            result = FHE.add(result, nextValue);
        }
        
        FHE.allow(result, msg.sender);
        
        emit OperationCompleted(msg.sender, "batchSum");
        return result;
    }
    
    /**
     * @notice Clear user's stored result
     * @dev Demonstrates cleanup patterns
     *
     * Pattern: State cleanup (encrypted values can't be "deleted", only replaced)
     */
    function clearResult() external {
        require(hasResult[msg.sender], "No result to clear");
        
        // Replace with zero (can't actually delete encrypted data)
        euint32 zero = FHE.asEuint32(0);
        FHE.allowThis(zero);
        userResults[msg.sender] = zero;
        
        hasResult[msg.sender] = false;
        
        emit OperationCompleted(msg.sender, "clear");
    }
    
    /**
     * @notice Check if user has a stored result
     * @param user Address to check
     * @return hasStoredResult Whether user has a stored result
     *
     * Pattern: Public state queries (non-encrypted data)
     */
    function hasStoredResult(address user) external view returns (bool) {
        return hasResult[user];
    }
}
