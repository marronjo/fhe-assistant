# FHE Library Reference 📚

**Comprehensive AI Assistant Guide to Fhenix FHE Types, Operations, and Access Control**

This document provides complete reference material for AI assistants helping developers write FHE smart contracts using the Fhenix protocol.

## 🎯 Quick Reference for AI

**Import Statement:**
```solidity
import "@fhenixprotocol/cofhe-contracts/FHE.sol";
```

Remappings(Foundry/Node)
```txt
@fhenixprotocol/cofhe-contracts/=lib/cofhe-contracts/contracts/
@fhenixprotocol/cofhe-contracts/=node_modules/@fhenixprotocol/cofhe-contracts/
```

**Core Mental Model:** All FHE types are handles (uint256) pointing to encrypted data. Without proper access control (`FHE.allow*`), encrypted values are unusable.

## 🔢 Encrypted Data Types

### **Supported Bit Lengths**

| Type | Bit Length | Range | Use Case |
|------|------------|-------|----------|
| `ebool` | 1 bit | true/false | Encrypted booleans, flags |
| `euint8` | 8 bits | 0 - 255 | Small counters, enums |
| `euint16` | 16 bits | 0 - 65,535 | Medium values, tokens |
| `euint32` | 32 bits | 0 - 4,294,967,295 | Large values, balances |
| `euint64` | 64 bits | 0 - 2^64 - 1  | Very large values |
| `euint128` | 128 bits | 0 - 2^128 - 1 | Extremely large values |
| `euint256` | 256 bits | 0 - 2^256 - 1 | Maximum precision |
| `eaddress` | 160 bits | Ethereum address | Encrypted addresses |

### **Type Definitions**
```solidity
type ebool is uint256;
type euint8 is uint256;
type euint16 is uint256;
type euint32 is uint256;
type euint64 is uint256;
type euint128 is uint256;
type euint256 is uint256;
type eaddress is uint256;  // For encrypted addresses
```

**🚨 AI Important:** All FHE types are internally represented as `uint256` handles, NOT the actual encrypted data.

## 🔧 Type Conversion Functions

### **From Plaintext to Encrypted**

```solidity
// From plaintext values
function asEbool(bool value) internal returns (ebool)
function asEuint8(uint256 value) internal returns (euint8)
function asEuint16(uint256 value) internal returns (euint16)
function asEuint32(uint256 value) internal returns (euint32)
function asEuint64(uint256 value) internal returns (euint64)
function asEuint128(uint256 value) internal returns (euint128)
function asEuint256(uint256 value) internal returns (euint256)
function asEaddress(address value) internal returns (eaddress)
```

**AI Usage Example:**
```solidity
// Convert plaintext to encrypted
euint32 encryptedBalance = FHE.asEuint32(1000);
ebool encryptedFlag = FHE.asEbool(true);
```

### **Between Encrypted Types (Casting)**

```solidity
// From ebool to other types
function asEuint8(ebool value) internal returns (euint8)
function asEuint16(ebool value) internal returns (euint16)
function asEuint32(ebool value) internal returns (euint32)
// ... up to euint256

// From euint8 to other types
function asEbool(euint8 value) internal returns (ebool)
function asEuint16(euint8 value) internal returns (euint16)
function asEuint32(euint8 value) internal returns (euint32)
// ... and so on for all types
```

**AI Casting Example:**
```solidity
// Convert encrypted bool to encrypted uint for arithmetic
ebool condition = FHE.gt(a, b);
euint32 conditionAsInt = FHE.asEuint32(condition); // 0 or 1
```

## ➕ Arithmetic Operations

**Available for:** `euint8`, `euint16`, `euint32`, `euint64`, `euint128`, `euint256`

### **Basic Arithmetic**
```solidity
function add(euint32 lhs, euint32 rhs) internal returns (euint32)
function sub(euint32 lhs, euint32 rhs) internal returns (euint32)  
function mul(euint32 lhs, euint32 rhs) internal returns (euint32)
function div(euint32 lhs, euint32 rhs) internal returns (euint32)
function rem(euint32 lhs, euint32 rhs) internal returns (euint32)  // remainder/modulo
```

**AI Arithmetic Example:**
```solidity
function calculateTotal(euint32 price, euint32 quantity) external returns (euint32) {
    euint32 total = FHE.mul(price, quantity);
    FHE.allowSender(total);  // CRITICAL: Grant access before returning
    return total;
}
```

## 🔍 Comparison Operations  

**Available for:** All encrypted types  
**Returns:** `ebool` (encrypted boolean)

### **Comparison Functions**
```solidity
function eq(euint32 lhs, euint32 rhs) internal returns (ebool)   // equal
function ne(euint32 lhs, euint32 rhs) internal returns (ebool)   // not equal
function lt(euint32 lhs, euint32 rhs) internal returns (ebool)   // less than
function lte(euint32 lhs, euint32 rhs) internal returns (ebool)  // less than or equal
function gt(euint32 lhs, euint32 rhs) internal returns (ebool)   // greater than
function gte(euint32 lhs, euint32 rhs) internal returns (ebool)  // greater than or equal
```

**🚨 AI Critical:** Comparisons return `ebool`, which CANNOT be used in `if` statements!

**AI Comparison Example:**
```solidity
function checkSufficientBalance(euint32 balance, euint32 amount) external returns (ebool) {
    ebool canAfford = FHE.gte(balance, amount);
    FHE.allowSender(canAfford);  // Grant access before returning
    return canAfford;
}
```

## 🔀 Logical Operations

### **Boolean Logic (ebool only)**
```solidity
function and(ebool lhs, ebool rhs) internal returns (ebool)
function or(ebool lhs, ebool rhs) internal returns (ebool)  
function xor(ebool lhs, ebool rhs) internal returns (ebool)
function not(ebool value) internal returns (ebool)
```

### **Bitwise Operations (all euint types)**
```solidity
function and(euint32 lhs, euint32 rhs) internal returns (euint32)  // bitwise AND
function or(euint32 lhs, euint32 rhs) internal returns (euint32)   // bitwise OR
function xor(euint32 lhs, euint32 rhs) internal returns (euint32)  // bitwise XOR
function not(euint32 value) internal returns (euint32)             // bitwise NOT
function shl(euint32 lhs, euint32 rhs) internal returns (euint32)  // shift left
function shr(euint32 lhs, euint32 rhs) internal returns (euint32)  // shift right
```

**AI Logical Example:**
```solidity
function checkMultipleConditions(euint32 age, euint32 balance) external returns (ebool) {
    ebool isAdult = FHE.gte(age, FHE.asEuint32(18));
    ebool hasBalance = FHE.gt(balance, FHE.asEuint32(0));
    ebool eligible = FHE.and(isAdult, hasBalance);  // Both must be true
    
    FHE.allowSender(eligible);
    return eligible;
}
```

## 🔓 Decryption Methods

**🎯 AI Critical:** Decryption is asynchronous and requires multiple transactions.

### **🚨 AI Prerequisites for Decryption**
Before calling decrypt methods, ensure:
- ✅ User has access via `FHE.allowSender()` or `FHE.allow()`
- ✅ Contract has access via `FHE.allowThis()` if storing
- ✅ Value is properly initialized (not zero handle)

### **⏱️ Decryption Timing**
- Decryption completes **very quickly** (usually within the same block)
- **Must be called in separate transactions** due to EVM execution model
- Transaction 1: `FHE.decrypt()` - triggers decryption
- Transaction 2: `FHE.getDecryptResult()` - retrieves completed result
- Use `getDecryptResultSafe()` to check if result is available

### **📋 AI Transaction Flow**
1. **Setup Transaction**: Store data + grant access (`FHE.allowSender()`)
2. **Decrypt Transaction**: Call `FHE.decrypt()` to trigger decryption  
3. **Retrieve Transaction**: Call `FHE.getDecryptResult()` to get plaintext
   - ✅ Usually available immediately in next transaction
   - ❌ Cannot retrieve in same transaction as decrypt call

### **FHE.decrypt() - Request Decryption**

Triggers the threshold decryption process for encrypted values.

```solidity
// Available for all encrypted types
function decrypt(ebool value) internal
function decrypt(euint8 value) internal  
function decrypt(euint16 value) internal
function decrypt(euint32 value) internal
function decrypt(euint64 value) internal
function decrypt(euint128 value) internal
function decrypt(euint256 value) internal
function decrypt(eaddress value) internal
```

**AI Usage Pattern:**
```solidity
function requestDecryption(euint32 encryptedValue) external {
    
    // NOTE: user must have permission to decrypt this value
    // e.g. FHE.allowSender() in storeData() function
    // Trigger decryption processs
    FHE.decrypt(encryptedValue);
    
    // Result available in future transaction via getDecryptResult()
}
```

### **FHE.getDecryptResult() - Retrieve Decrypted Value**

Gets the decrypted plaintext value. **Reverts if decryption not completed.**

```solidity
// Returns plaintext values
function getDecryptResult(ebool input) internal view returns (bool)
function getDecryptResult(euint8 input) internal view returns (uint8)
function getDecryptResult(euint16 input) internal view returns (uint16) 
function getDecryptResult(euint32 input) internal view returns (uint32)
function getDecryptResult(euint64 input) internal view returns (uint64)
function getDecryptResult(euint128 input) internal view returns (uint128)
function getDecryptResult(euint256 input) internal view returns (uint256)
function getDecryptResult(eaddress input) internal view returns (address)
```

**AI Usage Pattern:**
```solidity
function useDecryptedValue(euint32 encryptedValue) external view returns (uint32) {
    // This will REVERT if decryption not ready
    uint32 plainValue = FHE.getDecryptResult(encryptedValue);
    return plainValue;
}
```

### **FHE.getDecryptResultSafe() - Safe Retrieval**

Safely gets decrypted value with status flag. **Never reverts.**

```solidity
// Returns (value, isDecrypted) tuple
function getDecryptResultSafe(ebool input) internal view returns (bool result, bool decrypted)
function getDecryptResultSafe(euint8 input) internal view returns (uint8 result, bool decrypted)
function getDecryptResultSafe(euint16 input) internal view returns (uint16 result, bool decrypted)
function getDecryptResultSafe(euint32 input) internal view returns (uint32 result, bool decrypted)
function getDecryptResultSafe(euint64 input) internal view returns (uint64 result, bool decrypted)
function getDecryptResultSafe(euint128 input) internal view returns (uint128 result, bool decrypted)
function getDecryptResultSafe(euint256 input) internal view returns (uint256 result, bool decrypted)
function getDecryptResultSafe(eaddress input) internal view returns (address result, bool decrypted)
```

**AI Usage Pattern:**
```solidity
function tryGetDecryptedValue(euint32 encryptedValue) external view returns (uint32, bool) {
    (uint32 plainValue, bool isReady) = FHE.getDecryptResultSafe(encryptedValue);
    
    if (isReady) {
        // Decryption completed, use plainValue
        return (plainValue, true);
    } else {
        // Still decrypting, try again later
        return (0, false);
    }
}
```

### **AI Decryption Workflow Examples**

**Complete Decryption Workflow:**
```solidity
contract DecryptionExample {
    mapping(address => euint32) private encryptedData;
    mapping(address => bool) private decryptionRequested;
    
    // Step 1: Store encrypted data
    function storeData(InEuint32 calldata value) external {
        euint32 encrypted = FHE.asEuint32(value);
        encryptedData[msg.sender] = encrypted;
        FHE.allowThis(encrypted);
        FHE.allowSender(encrypted);
    }
    
    // Step 2: Request decryption
    function requestDecryption() external {
        euint32 data = encryptedData[msg.sender];
        FHE.decrypt(data);  // Trigger decryption, allowance already given to user in storeData()
        decryptionRequested[msg.sender] = true;
    }
    
    // Step 3: Use decrypted result (different transaction) will revert if not ready
    function getPlaintextValue() external view returns (uint32) {
        require(decryptionRequested[msg.sender], "Must request decryption first");
        euint32 data = encryptedData[msg.sender];
        return FHE.getDecryptResult(data);  // Get plaintext
    }
    
    // Step 3 Alternative: Safe retrieval, will return false if not ready
    function tryGetPlaintextValue() external view returns (uint32, bool) {
        euint32 data = encryptedData[msg.sender];
        return FHE.getDecryptResultSafe(data);  // Non-reverting
    }
}
```

**Error Handling Pattern:**
```solidity
function tryGetDecryptResultSafe(euint32 encrypted) external view returns (uint32 value, bool isReady) {
    // Check if decrypted
    (value, isReady) = FHE.getDecryptResultSafe(encrypted);
}
```

### **🔄 AI Common Decryption Patterns**

**Pattern 1: Immediate Check**
```solidity
function decryptIfReady(euint32 value) external view returns (uint32, bool) {
    return FHE.getDecryptResultSafe(value);
}
```

**Pattern 2: Queue Management**
```solidity
mapping(uint256 => bool) decryptionQueue;

function queueDecryption(euint32 value) external {
    uint256 handle = euint32.unwrap(value);
    if (!decryptionQueue[handle]) {
        FHE.decrypt(value);
        decryptionQueue[handle] = true;
    }
}

function isDecryptionQueued(euint32 value) external view returns (bool) {
    return decryptionQueue[euint32.unwrap(value)];
}
```

### **🚨 AI Common Decryption Errors**
- **`decrypt()` on uninitialized value** → Silent failure, no decryption occurs
- **`getDecryptResult()` before ready** → Transaction reverts
- **Missing access permissions** → Access denied error
- **Multiple `decrypt()` calls on same value** → Unnecessary gas cost
- **Same transaction decrypt + retrieve** → Cannot access result in same transaction
```

## 🔢 Encrypted Constants

**🎯 AI Pattern:** Create constants in constructor, grant contract access once, reuse everywhere.

### **Pattern: Contract-Level Constants**
```solidity
contract TokenContract {
    euint32 private ENCRYPTED_ZERO;
    
    constructor() {
        ENCRYPTED_ZERO = FHE.asEuint32(0);
        // CRITICAL: Contract needs access to use this constant
        FHE.allowThis(ENCRYPTED_ZERO);
    }
}
```

### **AI Usage Example: Safe Transfer**
```solidity
function transfer(address to, euint32 amount) external {
    euint32 balance = balances[msg.sender];
    ebool canTransfer = FHE.gte(balance, amount);
    
    // Use encrypted zero constant for failed transfers
    euint32 actualTransfer = FHE.select(
        canTransfer,
        amount,           // Transfer requested amount if sufficient balance
        ENCRYPTED_ZERO    // Transfer zero if insufficient balance
    );
    
    // Update balances using the conditional transfer amount
    balances[msg.sender] = FHE.sub(balance, actualTransfer);
    balances[to] = FHE.add(balances[to], actualTransfer);
    
    // CRITICAL: Grant access to updated balances
    FHE.allowThis(balances[msg.sender]);   // Contract needs access
    FHE.allowSender(balances[msg.sender]); // Sender needs access to their new balance
    FHE.allowThis(balances[to]);           // Contract needs access  
    FHE.allow(balances[to], to);           // Recipient needs access to their new balance
}
```

**💡 AI Benefits:**
- **Performance**: Create once, reuse many times vs `FHE.asEuint32(0)` repeatedly
- **Gas Efficiency**: Avoid repeated trivial encryptions
- **Clean Code**: Constants make conditional logic more readable

## 🔀 Conditional Operations (FHE.select)

**🎯 AI Essential:** The ONLY way to use encrypted boolean conditions for control flow.

### **Select Functions**
```solidity
function select(ebool condition, euint32 ifTrue, euint32 ifFalse) internal returns (euint32)
function select(ebool condition, ebool ifTrue, ebool ifFalse) internal returns (ebool)
// Available for all encrypted types
```

**🚨 AI Critical Rules:**
1. **Both branches ALWAYS execute** - there's no early termination
2. Only the result corresponding to the condition is returned
3. Use for ANY conditional logic with encrypted values

**AI Select Examples:**
```solidity
// Basic conditional value selection
function getDiscountedPrice(euint32 price, ebool isPremium) external returns (euint32) {
    euint32 discount10 = FHE.div(price, FHE.asEuint32(10));  // 10% discount
    euint32 discount20 = FHE.div(price, FHE.asEuint32(5));   // 20% discount
    
    euint32 finalPrice = FHE.select(
        isPremium,
        FHE.sub(price, discount20),  // Premium gets 20% off
        FHE.sub(price, discount10)   // Regular gets 10% off
    );
    
    FHE.allowSender(finalPrice);
    return finalPrice;
}

// Conditional transfer validation
function secureTransfer(euint32 balance, euint32 amount) external returns (euint32) {
    ebool canTransfer = FHE.gte(balance, amount);
    
    euint32 newBalance = FHE.select(
        canTransfer,
        FHE.sub(balance, amount),  // Subtract if sufficient balance
        balance                    // Keep original if insufficient
    );
    
    FHE.allowSender(newBalance);
    return newBalance;
}
```

## 🔐 Access Control Functions

**🎯 AI Most Important:** These functions grant permission to decrypt encrypted values.

### **Core Access Functions**

| Function | Purpose | When to Use | AI Template |
|----------|---------|-------------|-------------|
| `FHE.allow(value, address)` | Grant specific address access | Sharing with other contracts/users | `FHE.allow(data, recipient)` |
| `FHE.allowSender(value)` | Grant caller access (efficient) | Creating/returning user data | `FHE.allowSender(result)` |
| `FHE.allowThis(value)` | Grant contract access | Storing for later contract use | `FHE.allowThis(stored)` |
| `FHE.allowTransient(value, address)` | Temporary access (1 transaction) | One-time operations | `FHE.allowTransient(temp, user)` |

### **Access Control Examples**

```solidity
contract AIAccessExamples {
    mapping(address => euint32) private balances;
    
    // 🎯 AI PATTERN: Store with permanent access
    function deposit(InEuint32 calldata amount) external {
        euint32 encrypted = FHE.asEuint32(amount);
        balances[msg.sender] = encrypted;        // Store first
        FHE.allowThis(encrypted);                // Contract needs access
        FHE.allowSender(encrypted);              // User needs access
    }
    
    // 🎯 AI PATTERN: View function (access pre-granted)
    function getBalance() external view returns (euint32) {
        return balances[msg.sender];  // User already has access from deposit()
    }
    
    // 🎯 AI PATTERN: Computed value needs new access
    function calculateInterest(InEuint32 calldata rate) external returns (euint32) {
        euint32 balance = balances[msg.sender];
        euint32 rateEncrypted = FHE.asEuint32(rate);
        euint32 interest = FHE.mul(balance, rateEncrypted);
        
        // contract does not require access e.g. FHE.allowThis(interest)
        // because interest value is not stored or re-used elsewhere
        FHE.allowSender(interest);  // New computed value needs access
        return interest;
    }
    
    // 🎯 AI PATTERN: Cross-contract sharing  
    function shareBalance(address otherContract) external {
        euint32 balance = balances[msg.sender];
        FHE.allow(balance, otherContract);  // Grant specific contract access
        // Note: No return needed - contract gets access, doesn't need to return to caller
        // e.g. otherContract transfers users entire encrypted balance etc.
        otherContract.transferFrom(msg.sender, address(this), balance)
    }
}
```

## 🚨 AI Critical Patterns

### **❌ Common AI Mistakes**

```solidity
// ❌ WRONG: Using ebool in if statement
function badConditional(euint32 a, euint32 b) external {
    ebool condition = FHE.gt(a, b);
    if (condition) {  // ERROR: Won't compile!
        return a;
    }
}

// ❌ WRONG: Returning encrypted value without access
function badReturn() external returns (euint32) {
    euint32 result = FHE.asEuint32(42);
    return result;  // User can't decrypt this!
}

// ❌ WRONG: Storing without contract access
function badStorage(euint32 value) external {
    balances[msg.sender] = value;  // Contract loses access!
}
```

### **✅ Correct AI Patterns**

```solidity
// ✅ CORRECT: Use FHE.select for conditionals
function goodConditional(euint32 a, euint32 b) external returns (euint32) {
    ebool condition = FHE.gt(a, b);
    euint32 result = FHE.select(condition, a, b);
    FHE.allowSender(result);
    return result;
}

// ✅ CORRECT: Grant access for NEW computed values
function computeNewValue() external returns (euint32) {
    euint32 result = FHE.asEuint32(42);  // NEW value created
    FHE.allowSender(result);  // New value needs access
    return result;
}

// ✅ CORRECT: Grant access when storing
function goodStorage(euint32 value) external {
    balances[msg.sender] = value;  // Store first
    FHE.allowThis(value);          // Contract needs access
    FHE.allowSender(value);        // User needs access
}
```

## 🎯 AI Development Checklist

**Before generating FHE code, AI should verify:**

✅ **Imports**: `import "@fhenixprotocol/cofhe-contracts/FHE.sol";`  
✅ **Type Usage**: Use appropriate bit length for data range  
✅ **Access Control**: Every encrypted return has `FHE.allow*` except view functions   
✅ **Storage Pattern**: Every encrypted storage has `FHE.allowThis`  
✅ **Conditionals**: Use `FHE.select()` instead of `if` with `ebool`  
✅ **Operations**: Use FHE functions for all encrypted operations  
✅ **Comments**: Explain FHE patterns for other developers  

## 📋 Quick AI Template

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@fhenixprotocol/cofhe-contracts/FHE.sol";

contract AIFHETemplate {
    mapping(address => euint32) private userData;
    mapping(address => bool) public userHasData;
    
    // Pattern: Store encrypted data with proper access
    function storeData(InEuint32 calldata value) external {
        euint32 encrypted = FHE.asEuint32(value);
        
        userData[msg.sender] = encrypted;      // Store first
        
        FHE.allowThis(encrypted);              // Contract access
        FHE.allowSender(encrypted);            // User access
        
        userHasData[msg.sender] = true;
    }
    
    // Pattern: View function for stored data
    function getData() external view returns (euint32) {
        require(userHasData[msg.sender], "No data stored");
        return userData[msg.sender];  // User already has access
    }
    
    // Pattern: Computed value with new access
    function computeDouble() external returns (euint32) {
        require(userHasData[msg.sender], "No data stored");
        euint32 data = userData[msg.sender];
        euint32 doubled = FHE.add(data, data);
        
        FHE.allowSender(doubled);  // New computed value needs access
        return doubled;
    }
    
    // Pattern: Conditional operation
    function conditionalOperation(InEuint32 calldata threshold) external returns (euint32) {
        require(userHasData[msg.sender], "No data stored");
        euint32 data = userData[msg.sender];
        euint32 encThreshold = FHE.asEuint32(threshold);
        
        ebool isAbove = FHE.gt(data, encThreshold);
        euint32 result = FHE.select(
            isAbove,
            FHE.mul(data, FHE.asEuint32(2)),  // Double if above threshold
            data                              // Keep original if not
        );
        
        FHE.allowSender(result);  // New computed value needs access
        return result;
    }
}
```

## 🔄 Multi-Transaction Decryption Pattern

**Critical**: Decryption always requires multiple transactions due to threshold decryption.

```solidity
contract SecureVoting {
    mapping(bytes32 => euint32) private results;
    mapping(bytes32 => bool) public decryptionRequested;
    
    // Transaction 1: Request decryption
    function requestResultDecryption(bytes32 proposalId) external {
        require(!decryptionRequested[proposalId], "Already requested");
        
        euint32 encryptedResult = results[proposalId];
        FHE.allowSender(encryptedResult); // Grant access to caller, unless they already have access
        decryptionRequested[proposalId] = true;
        
        // Trigger the threshold decryption process
        FHE.decrypt(encryptedResult);
    }
    
    // Transaction 2: Use decrypted result (in future transaction)
    function finalizeResult(bytes32 proposalId) external {
        require(decryptionRequested[proposalId], "Decryption not requested");
        
        euint32 encryptedResult = results[proposalId];
        (uint32 decryptedValue, bool decrypted) = FHE.getDecryptResultSafe(encryptedResult);
        
        if(!decrypted){
            // not decrypted, return false / revert
        }
        // Use decryptedValue for final logic
    }
}
```

## 🔄 Cross-Contract Permissions

### **Pattern 1: Contract-to-Contract Data Sharing**
```solidity
contract DataProvider {
    mapping(address => euint32) private userData;
    
    // ✅ AI TEMPLATE: Share encrypted data with another contract
    function shareUserData(address user, address consumerContract) 
        external 
    {
        require(msg.sender == user, "Only user can share their data");
        
        euint32 data = userData[user];
        FHE.allow(data, consumerContract); // Grant specific contract access
        // Note: No return needed - just granting access to another contract
    }
    
    // Store user data with proper permissions
    function storeUserData(InEuint32 calldata value) external {
        euint32 encrypted = FHE.asEuint32(value);
        userData[msg.sender] = encrypted;  // Store first
        FHE.allowThis(encrypted);          // Contract needs access
        FHE.allowSender(encrypted);        // User needs access
    }
}

contract DataConsumer {
    mapping(address => euint32) private processedData;
    
    // ✅ AI TEMPLATE: Receive and process shared data
    function processSharedData(address provider, address user) external {
        // Get data from provider (provider grants us access)
        euint32 sharedData = DataProvider(provider).shareUserData(
            user, 
            address(this)  // This contract gets access
        );
        
        // Process the data (we have access now)
        euint32 doubled = FHE.add(sharedData, sharedData);
        
        // Store result with proper permissions
        processedData[user] = doubled;  // Store first
        FHE.allowThis(doubled);         // Contract needs access
        FHE.allow(doubled, user);       // Original user gets access to result
    }
    
    function getProcessedData() external view returns (euint32) {
        return processedData[msg.sender]; // User already has access
    }
}
```

### **Pattern 2: Permission Inheritance Chain**
```solidity
contract VaultA {
    euint32 private secret;
    
    function shareWithB(address vaultB) external returns (euint32) {
        FHE.allow(secret, vaultB);  // B gets access
        return secret;
    }
}

contract VaultB {
    function shareWithC(address vaultA, address vaultC) external {
        euint32 data = VaultA(vaultA).shareWithB(address(this));
        
        // Now share with VaultC
        FHE.allow(data, vaultC);  // C gets access through B
        VaultC(vaultC).receiveData(data);
    }
}

contract VaultC {
    euint32 private receivedData;
    
    function receiveData(euint32 data) external {
        receivedData = data;  // Store first
        FHE.allowThis(data);  // Then grant contract access
    }
}
```

### **🚨 AI Cross-Contract Mistakes:**

```solidity
// ❌ WRONG: Assuming other contract has access
contract BadConsumer {
    function processData(euint32 data) external {
        // BREAKS - we don't have access to this data!
        euint32 result = FHE.add(data, FHE.asEuint32(10)); // ACCESS DENIED
    }
}

// ✅ CORRECT: Explicit permission granting
contract GoodProvider {
    function provideData(address consumer) external returns (euint32) {
        euint32 data = myData;
        FHE.allow(data, consumer);  // Explicitly grant access
        return data;
    }
}
```

## 🔍 AI Debugging Guide

### 🚨 Common AI-Generated Code Issues

**Issue #1: "Access denied" errors**
```solidity
// 🔍 SYMPTOM: Users can't decrypt returned values
// 🎯 AI FIX: Add FHE.allowSender() before return
function fixThis() external returns (euint32) {
    euint32 result = someCalculation();
    FHE.allowSender(result);  // ADD THIS LINE
    return result;
}
```

**Issue #2: "Cannot convert ebool to bool"**
```solidity
// 🔍 SYMPTOM: Compilation error with conditionals
// ❌ AI MISTAKE:
if (FHE.gt(a, b)) { ... }  // Won't compile

// 🎯 AI FIX: Use FHE.select()
euint32 result = FHE.select(FHE.gt(a, b), a, b);
```

**Issue #3: Contract operations fail on stored data**
```solidity
// 🔍 SYMPTOM: "Access denied" on contract's own stored data
// 🎯 AI FIX: Always call FHE.allowThis() when storing
function store(euint32 value) external {
    storageMap[msg.sender] = value;
    FHE.allowThis(value);  // ADD THIS LINE
}
```

**Issue #4: Tests timing out**
```solidity
// 🔍 SYMPTOM: Tests fail with timeout/timing issues
// 🎯 AI FIX: Add vm.warp() in tests
function testFix() public {
    euint32 result = contract.operation();
    vm.warp(block.timestamp + 11);  // ADD THIS LINE
    // Now test the result
}
```

### 🎯 AI Debugging Prompts

**For Access Issues:**
```
"This FHE contract has access denied errors. Add proper FHE.allow() calls: [code]"
```

**For Compilation Issues:**
```
"Fix this FHE code that won't compile. Replace if statements with FHE.select(): [code]"
```

**For Test Issues:**
```
"Fix these FHE tests that are failing. Add proper vm.warp() timing: [code]"
```

## 💡 AI Performance Tips

1. **Choose appropriate bit lengths** - Don't use euint256 for small counters
2. **Batch operations** when possible to reduce gas costs
3. **Use `FHE.allowSender()`** instead of `FHE.allow(value, msg.sender)` (more efficient)
4. **Grant access once** when storing, then getters can be `view`
5. **Validate inputs** before expensive FHE operations

---

**🚀 AI Quick Start:** Use this reference to generate secure, efficient FHE smart contracts following Fhenix best practices!