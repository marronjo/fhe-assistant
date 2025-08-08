# Core FHE Patterns 🔐

**Mental Model**: "Without FHE.allow() = passing a locked box without the key!"

This document covers the fundamental concepts and patterns for Fully Homomorphic Encryption (FHE) smart contract development on Fhenix. Optimized for AI-assisted development with Claude, Gemini, OpenAI Codex, and other AI tools.

## 🤖 AI Quick Reference

**For AI Assistants: These are the CRITICAL patterns you MUST follow:**

```solidity
// ✅ ALWAYS do this when returning encrypted values
function getBalance() external returns (euint32) {
    euint32 balance = balances[msg.sender];
    FHE.allow(balance, msg.sender);  // MANDATORY!
    return balance;
}

// ✅ ALWAYS do this when storing encrypted values  
function updateBalance(euint32 newBalance) external {
    balances[msg.sender] = newBalance;  // Update value first
    FHE.allowThis(newBalance);          // Contract needs access
    FHE.allowSender(newBalance);        // User needs access
}

// ✅ ALWAYS use FHE.select() for conditionals with ebool
function conditionalLogic(euint32 a, euint32 b) external returns (euint32) {
    ebool condition = FHE.gt(a, b);
    // NEVER: if (condition) { ... }  // Won't compile!
    euint32 result = FHE.select(condition, a, b);  // Correct way
    FHE.allowSender(result);
    return result;
}
```

**🚨 AI Code Generation Rules:**
1. Every `euint*`/`ebool` return → `FHE.allow()` or `FHE.allowSender()`
2. Every encrypted storage → `FHE.allowThis()`
3. Every conditional with `ebool` → `FHE.select()`
4. Import: `@fhenixprotocol/contracts/FHE.sol`
5. Pragma: `^0.8.25`

## 🧠 Mental Models

### 1. FHE Types as Handles

```solidity
euint32 encryptedValue; // This is NOT the encrypted data itself
                        // It's a handle (uint256) pointing to encrypted data
                        // Think: "key to a safe deposit box"
```

**Key Insight**: FHE types (`euint8`, `euint32`, `ebool`) are handles that point to encrypted data stored off-chain. The actual encrypted data is never directly accessible in your contract.

### 2. Symbolic Execution

```solidity
euint32 a = FHE.asEuint32(10);
euint32 b = FHE.asEuint32(20);
euint32 result = FHE.add(a, b); // Builds computation graph, doesn't compute 30
```

**Key Insight**: FHE operations create computation graphs rather than immediate results. The actual computation happens when decryption is requested.

### 3. Access Control is Mandatory

// ❌ WRONG: Grants access every time (gas waste + cannot be view)
function getBalance() external returns (euint32) {
    euint32 balance = balances[msg.sender];
    FHE.allow(balance, msg.sender); // Wasteful repeated permission!
    return balance;
}

// ✅ CORRECT: Grant access when data is created/updated
function updateBalance(euint32 newBalance) external {
    balances[msg.sender] = newBalance;  // Store first
    FHE.allowThis(newBalance);          // Contract needs access
    FHE.allowSender(newBalance);        // Grant access to msg.sender once
}

function getBalance() external view returns (euint32) {
    return balances[msg.sender]; // User already has access from updateBalance
}
```

## 🔑 Access Control Patterns - Mental Model for AI

**🧠 Think of FHE Values as Safety Deposit Boxes:**
```solidity
euint32 encryptedValue; // This is the BOX NUMBER, not the contents

// FHE.allow() gives someone the KEY to open their own copy of the box
FHE.allow(encryptedValue, alice); // Alice gets a key to decrypt

// FHE.allowThis() gives the CONTRACT a master key for internal operations  
FHE.allowThis(encryptedValue); // Contract keeps master key

// Without proper keys, you have a box number but can't open it
```

**💡 AI Best Practice**: Use `FHE.allowSender()` when creating/updating data, then getter functions can be `view`. Avoid repeated `FHE.allow()` calls in getters - it's inefficient and prevents `view` modifier.

### 🎯 AI Pattern Templates

**Template 1: Efficient Access Control Pattern**
```solidity
// ✅ RECOMMENDED: Grant access when creating data
function setData(uint32 value) external {
    euint32 encrypted = FHE.asEuint32(value);
    userData[msg.sender] = encrypted;   // Store first
    FHE.allowThis(encrypted);           // Contract access for storage
    FHE.allowSender(encrypted);         // User access (efficient)
}

// ✅ Now getter can be view (access already granted)
function getData() external view returns (euint32) {
    return userData[msg.sender];  // User already has access
}
```

**Template 2: On-Demand Access Pattern**
```solidity
// ⚠️ LESS EFFICIENT: Grant access on every call
function getDataOnDemand() external returns (euint32) {
    euint32 data = userData[msg.sender];
    FHE.allow(data, msg.sender);  // Repeated gas cost
    return data;
}
```

## 🎯 AI Permission Reference Guide

### **Who Needs Access and When?**

| Function | Who Needs Access | When to Grant | AI Template |
|----------|------------------|---------------|-------------|
| **FHE.allow(value, address)** | Specific external address | When sharing data | `FHE.allow(data, recipient)` |
| **FHE.allowSender(value)** | Function caller | When creating/updating user data | `FHE.allowSender(result)` |  
| **FHE.allowThis(value)** | Contract itself | When storing for later contract use | `FHE.allowThis(stored)` |
| **FHE.allowTransient(value, addr)** | Temporary access | One transaction only | `FHE.allowTransient(temp, user)` |

### **AI Decision Tree: Which Permission to Use?**

```solidity
// 🤖 AI DECISION LOGIC:

// 1. Am I returning a value to the user?
function getUserData() external view returns (euint32) {
    return userData[msg.sender];  // ✅ User already has access from when data was stored
}

// 2. Am I storing a value the contract needs to use later?
function storeForLater(euint32 value) external {
    stored[msg.sender] = value;  // Store first
    FHE.allowThis(value);        // ✅ Contract needs access for future operations
}

// 3. Am I sharing with another contract?
function shareWithContract(address otherContract, euint32 data) external {
    FHE.allow(data, otherContract); // ✅ Other contract needs access
}

// 4. Am I creating user data they should own?
function createUserData(uint32 plainValue) external returns (euint32) {
    euint32 encrypted = FHE.asEuint32(plainValue);
    userData[msg.sender] = encrypted;  // Store first
    FHE.allowThis(encrypted);          // Contract needs access if storing
    FHE.allowSender(encrypted);        // User needs access to their data
    return encrypted;
}
```

### **🚨 AI Common Mistakes to Avoid:**

```solidity
// ❌ WRONG: Forgetting contract access when storing
function badStore(euint32 value) external {
    stored[msg.sender] = value; // Contract loses access forever!
}

function laterOperation() external returns (euint32) {
    euint32 stored = stored[msg.sender];
    // BREAKS HERE - contract has no access to decrypt stored value
    return FHE.add(stored, FHE.asEuint32(10)); // ACCESS DENIED ERROR
}

// ✅ CORRECT: Grant contract access when storing
function goodStore(euint32 value) external {
    stored[msg.sender] = value; // Store first
    FHE.allowThis(value);       // Contract can use later
}

// ❌ WRONG: Returning value without access
function badReturn() external returns (euint32) {
    euint32 result = FHE.asEuint32(42);
    return result; // User gets useless handle - can't decrypt!
}

// ✅ CORRECT: Grant access before returning
function goodReturn() external returns (euint32) {
    euint32 result = FHE.asEuint32(42);
    FHE.allowSender(result); // User can now decrypt return value
    return result;
}
```

### FHE.allow() - Grant External Access

```solidity
contract Calculator {
    mapping(address => euint32) private results;
    
    function calculate(uint32 a, uint32 b) external {
        euint32 encA = FHE.asEuint32(a);
        euint32 encB = FHE.asEuint32(b);
        euint32 sum = FHE.add(encA, encB);
        
        // Store first
        results[msg.sender] = sum;
        // Then grant access to THIS contract for future operations
        FHE.allowThis(sum);
        // Grant access to caller efficiently
        FHE.allowSender(sum);
    }
    
    // Now getResult can be view since access was granted in calculate
    function getResult() external view returns (euint32) {
        return results[msg.sender];
    }
}
```

### FHE.allowTransient() - Temporary Access

```solidity
// Grant temporary access (cleared at end of transaction)
FHE.allowTransient(encryptedValue, someAddress);
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
        FHE.allowSender(encryptedResult); // Grant access efficiently
        decryptionRequested[proposalId] = true;
        
        // User now calls FHE.decrypt() off-chain
        // This triggers the threshold decryption process
    }
    
    // Transaction 2: Use decrypted result (in future transaction)
    function finalizeResult(bytes32 proposalId, uint32 decryptedValue) external {
        require(decryptionRequested[proposalId], "Decryption not requested");
        
        // Verify the decryption is correct (implementation specific)
        // Use decryptedValue for final logic
    }
}
```

## 🚫 Control Flow Limitations

### ebool Cannot Be Used in if Statements

```solidity
// ❌ WRONG: This will not compile
function badExample(euint32 a, euint32 b) external {
    ebool isGreater = FHE.gt(a, b);
    if (isGreater) { // ❌ ERROR: Cannot convert ebool to bool
        // This won't work
    }
}
```

### Use FHE.select() Instead

```solidity
// ✅ CORRECT: Use FHE.select for conditional logic
function conditionalOperation(euint32 a, euint32 b) external returns (euint32) {
    ebool condition = FHE.gt(a, b); // a > b
    
    // Returns a if condition is true, b if false
    euint32 result = FHE.select(condition, a, b);
    
    FHE.allowSender(result);  // New computed value needs access
    return result;
}

// More complex example
function conditionalCalculation(euint32 balance, euint32 amount) external returns (euint32) {
    ebool canAfford = FHE.gte(balance, amount);
    
    // If can afford: balance - amount, else: balance (unchanged)
    euint32 newBalance = FHE.select(
        canAfford,
        FHE.sub(balance, amount), // Execute if true
        balance                   // Execute if false
    );
    
    FHE.allowThis(newBalance);
    return newBalance;
}
```

**Important**: Both branches of `FHE.select()` are always executed. The condition only determines which result is returned.

## 🔄 Trivial Encryption Determinism

```solidity
// Trivial encryption (from plaintext) is deterministic
euint32 ten1 = FHE.asEuint32(10);
euint32 ten2 = FHE.asEuint32(10);
// ten1 and ten2 have the same handle value

// Non-trivial encryption (from user input) is non-deterministic
// Each encryption of the same value produces different ciphertexts
```

## 📚 AI-Ready Common Patterns

### 🤖 Copy-Paste Templates for AI

These templates are designed for AI assistants to use as starting points:

### Template 1: Encrypted Counter (AI-Optimized)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@fhenixprotocol/contracts/FHE.sol";

/**
 * @title EncryptedCounter - AI Template
 * @notice Perfect template for AI to learn FHE state management
 * @dev Key patterns: FHE.allowThis() + FHE.allowSender() combination
 */
contract EncryptedCounter {
    euint32 private counter;
    mapping(address => bool) public hasAccess;
    
    event CounterIncremented(address indexed user);
    
    constructor() {
        counter = FHE.asEuint32(0);
        FHE.allowThis(counter);  // Contract needs access forever
    }
    
    /**
     * @notice AI Pattern: State modification with access control
     * @dev Template for AI: Always FHE.allowThis() + FHE.allowSender()
     */
    function increment() external {
        euint32 one = FHE.asEuint32(1);
        counter = FHE.add(counter, one);
        
        // CRITICAL: Grant access for future operations
        FHE.allowThis(counter);   // Contract needs access
        FHE.allowSender(counter); // User gets access (efficient)
        
        hasAccess[msg.sender] = true;
        emit CounterIncremented(msg.sender);
    }
    
    /**
     * @notice AI Pattern: View function (access pre-granted)
     * @dev No FHE.allow() needed - access granted in increment()
     */
    function getCounter() external view returns (euint32) {
        require(hasAccess[msg.sender], "No access - call increment() first");
        return counter;
    }
    
    /**
     * @notice AI Pattern: Conditional increment
     * @dev Shows FHE.select() usage for AI learning
     */
    function conditionalIncrement(uint32 threshold) external returns (euint32) {
        euint32 encThreshold = FHE.asEuint32(threshold);
        ebool shouldIncrement = FHE.gt(counter, encThreshold);
        
        euint32 one = FHE.asEuint32(1);
        euint32 newCounter = FHE.select(
            shouldIncrement,
            FHE.add(counter, one),  // Increment if > threshold
            counter                 // Keep same if <= threshold
        );
        
        counter = newCounter;
        FHE.allowThis(counter);
        FHE.allowSender(counter);
        
        return counter;
    }
}
```

### Pattern 2: Encrypted Comparison

```solidity
function findMaximum(euint32 a, euint32 b) external returns (euint32) {
    ebool aIsGreater = FHE.gt(a, b);
    euint32 maximum = FHE.select(aIsGreater, a, b);
    
    FHE.allowSender(maximum); // Efficient one-time permission
    return maximum;
}
```

### Pattern 3: Range Checking

```solidity
function validateRange(euint32 value, uint32 min, uint32 max) 
    external 
    returns (ebool) 
{
    euint32 encMin = FHE.asEuint32(min);
    euint32 encMax = FHE.asEuint32(max);
    
    ebool aboveMin = FHE.gte(value, encMin);
    ebool belowMax = FHE.lte(value, encMax);
    
    ebool inRange = FHE.and(aboveMin, belowMax);
    
    FHE.allowSender(inRange); // Efficient one-time permission
    return inRange;
}
```

### Template 2: Encrypted Accumulator (Multi-User AI Template)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@fhenixprotocol/contracts/FHE.sol";

/**
 * @title EncryptedAccumulator - AI Multi-User Template
 * @notice Perfect for AI to learn multi-user encrypted state
 * @dev Shows per-user encrypted storage patterns
 */
contract EncryptedAccumulator {
    euint32 private globalTotal;
    mapping(address => euint32) private userTotals;
    mapping(address => bool) public userHasData;
    
    event ValueAdded(address indexed user, string operation);
    
    constructor() {
        globalTotal = FHE.asEuint32(0);
        FHE.allowThis(globalTotal);
    }
    
    /**
     * @notice AI Pattern: Multi-user encrypted storage
     * @dev Template: Handle both global and per-user state
     */
    function addValue(uint32 value) external {
        euint32 encValue = FHE.asEuint32(value);
        
        // Initialize user total if first time
        if (!userHasData[msg.sender]) {
            userTotals[msg.sender] = FHE.asEuint32(0);
            FHE.allowThis(userTotals[msg.sender]);
        }
        
        // Update user total
        userTotals[msg.sender] = FHE.add(userTotals[msg.sender], encValue);
        FHE.allowThis(userTotals[msg.sender]);     // Contract access
        FHE.allowSender(userTotals[msg.sender]);   // User access
        
        // Update global total
        globalTotal = FHE.add(globalTotal, encValue);
        FHE.allowThis(globalTotal);
        
        userHasData[msg.sender] = true;
        emit ValueAdded(msg.sender, "addValue");
    }
    
    /**
     * @notice AI Pattern: Per-user encrypted retrieval
     */
    function getUserTotal() external view returns (euint32) {
        require(userHasData[msg.sender], "No data for user");
        return userTotals[msg.sender];
    }
    
    /**
     * @notice AI Pattern: Admin-only global access
     * @dev Shows role-based encrypted access
     */
    function getGlobalTotal(address admin) external returns (euint32) {
        require(admin == msg.sender, "Admin only");
        FHE.allow(globalTotal, admin);
        return globalTotal;
    }
    
    /**
     * @notice AI Pattern: Conditional operations with encrypted state
     */
    function addIfGreaterThan(uint32 value, uint32 threshold) external returns (euint32) {
        require(userHasData[msg.sender], "Initialize first with addValue()");
        
        euint32 encValue = FHE.asEuint32(value);
        euint32 encThreshold = FHE.asEuint32(threshold);
        euint32 currentTotal = userTotals[msg.sender];
        
        // Only add if current total > threshold
        ebool shouldAdd = FHE.gt(currentTotal, encThreshold);
        euint32 newTotal = FHE.select(
            shouldAdd,
            FHE.add(currentTotal, encValue),  // Add if condition true
            currentTotal                      // Keep same if false
        );
        
        userTotals[msg.sender] = newTotal;
        FHE.allowThis(newTotal);
        FHE.allowSender(newTotal);
        
        emit ValueAdded(msg.sender, "conditionalAdd");
        return newTotal;
    }
}
```

## 🔄 Cross-Contract Permissions - AI Templates

### **Pattern 1: Contract-to-Contract Data Sharing**
```solidity
contract DataProvider {
    mapping(address => euint32) private userData;
    
    // ✅ AI TEMPLATE: Share encrypted data with another contract
    function shareUserData(address user, address consumerContract) 
        external 
        returns (euint32) 
    {
        require(msg.sender == user, "Only user can share their data");
        
        euint32 data = userData[user];
        FHE.allow(data, consumerContract); // Grant specific contract access
        return data;
    }
    
    // Store user data with proper permissions
    function storeUserData(uint32 value) external {
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
```

## ⚠️ Common AI Mistakes & Anti-Patterns

### 🤖 Top AI Code Generation Errors

### AI Mistake #1: Forgetting Access Control (Most Common)

```solidity
// ❌ AI FREQUENTLY GENERATES THIS (WRONG):
function badFunction() external returns (euint32) {
    euint32 result = FHE.asEuint32(42);
    return result; // Useless! Caller can't decrypt this!
}

// ✅ AI SHOULD GENERATE THIS (CORRECT):
function goodFunction() external returns (euint32) {
    euint32 result = FHE.asEuint32(42);
    FHE.allowSender(result);  // MANDATORY for AI!
    return result;
}

// 🎯 AI PROMPT FIX:
// "Always add FHE.allowSender() before returning encrypted values"
```

### AI Mistake #2: Using ebool in if Statements (Compilation Error)

```solidity
// ❌ AI OFTEN GENERATES THIS (WON'T COMPILE):
function badConditional(euint32 a, euint32 b) external returns (euint32) {
    ebool condition = FHE.gt(a, b);
    if (condition) { // ERROR: Cannot convert ebool to bool!
        return a;
    } else {
        return b;
    }
}

// ✅ AI SHOULD GENERATE THIS (CORRECT):
function goodConditional(euint32 a, euint32 b) external returns (euint32) {
    ebool condition = FHE.gt(a, b);
    euint32 result = FHE.select(condition, a, b);  // Proper FHE conditional
    FHE.allowSender(result);
    return result;
}

// 🎯 AI PROMPT FIX:
// "Never use ebool in if statements. Always use FHE.select(condition, trueValue, falseValue)"
```

### AI Mistake #3: Forgetting Contract Storage Access

```solidity
// ❌ AI OFTEN FORGETS THIS (BREAKS FUTURE OPERATIONS):
function badStorage(euint32 value) external {
    userBalances[msg.sender] = value; // Contract loses access!
}

// Later function won't work because contract can't access stored value
function brokenFunction() external returns (euint32) {
    euint32 stored = userBalances[msg.sender];
    // This will fail - contract has no access to stored value!
    euint32 doubled = FHE.mul(stored, FHE.asEuint32(2));
    return doubled;
}

// ✅ AI SHOULD GENERATE THIS (CORRECT):
function goodStorage(euint32 value) external {
    FHE.allowThis(value);          // CRITICAL: Contract needs access
    FHE.allowSender(value);        // User needs access too
    userBalances[msg.sender] = value;
}

// Now this works because contract has access
function workingFunction() external returns (euint32) {
    euint32 stored = userBalances[msg.sender];
    euint32 doubled = FHE.mul(stored, FHE.asEuint32(2));
    FHE.allowSender(doubled);
    return doubled;
}

// 🎯 AI PROMPT FIX:
// "Always call FHE.allowThis() when storing encrypted values for later use"
```

## 🔍 AI Code Debugging Guide

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
    FHE.allowThis(value);  // ADD THIS LINE
    storage[msg.sender] = value;
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

## 🎯 AI Code Generation Best Practices

### 🤖 Checklist for AI-Generated FHE Code

**Before Providing FHE Code, AI Should Check:**

✅ **Import Statement**: `import "@fhenixprotocol/contracts/FHE.sol";`  
✅ **Pragma Version**: `pragma solidity ^0.8.25;`  
✅ **Access Control**: Every `euint*`/`ebool` return has `FHE.allowSender()`  
✅ **Storage Pattern**: Every encrypted storage has `FHE.allowThis()`  
✅ **Conditional Logic**: All `ebool` conditionals use `FHE.select()`  
✅ **Error Handling**: Proper validation and error messages  
✅ **Events**: Emit events for state changes  
✅ **Documentation**: Clear comments explaining FHE patterns  

### 📋 AI Code Template Checklist

**For Every FHE Function AI Generates:**

```solidity
// ✅ Template for AI to follow
function aiTemplate(uint32 input) external returns (euint32) {
    // 1. Convert to encrypted if needed
    euint32 encrypted = FHE.asEuint32(input);
    
    // 2. Perform FHE operations
    euint32 result = FHE.add(encrypted, FHE.asEuint32(10));
    
    // 3. ALWAYS grant access before return
    FHE.allowSender(result);  // MANDATORY
    
    // 4. Emit event if state change
    emit OperationCompleted(msg.sender);
    
    // 5. Return encrypted value
    return result;
}
```

**For Storage Functions:**

```solidity
// ✅ Storage template for AI
function storeValue(uint32 value) external {
    euint32 encrypted = FHE.asEuint32(value);
    
    // CRITICAL: Both access patterns needed
    FHE.allowThis(encrypted);     // Contract needs access
    FHE.allowSender(encrypted);   // User needs access
    
    // Store the value
    userStorage[msg.sender] = encrypted;
}
```

### 🔧 AI Performance Optimization Tips

1. **Use `FHE.allowSender()`** instead of `FHE.allow(value, msg.sender)` (more efficient)
2. **Batch operations** when possible to reduce gas costs
3. **Validate inputs** before expensive FHE operations
4. **Use appropriate FHE types** (euint8 for small values, euint32 for larger)
5. **Document gas implications** in comments for complex operations

### 🎯 AI Success Metrics

**Good AI-Generated FHE Code Should:**
- Compile without errors ✅
- Pass basic access control tests ✅  
- Follow FHE security patterns ✅
- Include proper error handling ✅
- Have clear documentation ✅
- Use efficient gas patterns ✅

## 🔗 Need More Information?

This document covers the fundamental patterns. For topics not covered here, refer to the official documentation at [docs.fhenix.zone](https://docs.fhenix.zone).

## 🚀 AI Quick Start Templates

### Template: Simple Encrypted Storage
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "@fhenixprotocol/contracts/FHE.sol";

contract SimpleEncryptedStorage {
    mapping(address => euint32) private data;
    mapping(address => bool) public hasData;
    
    function store(uint32 value) external {
        euint32 encrypted = FHE.asEuint32(value);
        FHE.allowThis(encrypted);
        FHE.allowSender(encrypted);
        data[msg.sender] = encrypted;
        hasData[msg.sender] = true;
    }
    
    function retrieve() external view returns (euint32) {
        require(hasData[msg.sender], "No data stored");
        return data[msg.sender];
    }
}
```

### Template: Encrypted Conditional Logic
```solidity
function conditionalOperation(uint32 a, uint32 b, uint32 threshold) external returns (euint32) {
    euint32 encA = FHE.asEuint32(a);
    euint32 encB = FHE.asEuint32(b);
    euint32 encThreshold = FHE.asEuint32(threshold);
    
    ebool condition = FHE.gt(encA, encThreshold);
    euint32 result = FHE.select(
        condition,
        FHE.add(encA, encB),  // If a > threshold
        FHE.sub(encA, encB)   // If a <= threshold
    );
    
    FHE.allowSender(result);
    return result;
}
```

### Template: Multi-User Encrypted System
```solidity
contract MultiUserEncrypted {
    mapping(address => euint32) private balances;
    mapping(address => bool) public initialized;
    
    function initialize(uint32 initialValue) external {
        require(!initialized[msg.sender], "Already initialized");
        
        euint32 encrypted = FHE.asEuint32(initialValue);
        FHE.allowThis(encrypted);
        FHE.allowSender(encrypted);
        
        balances[msg.sender] = encrypted;
        initialized[msg.sender] = true;
    }
    
    function updateBalance(uint32 newValue) external {
        require(initialized[msg.sender], "Not initialized");
        
        euint32 encrypted = FHE.asEuint32(newValue);
        FHE.allowThis(encrypted);
        FHE.allowSender(encrypted);
        
        balances[msg.sender] = encrypted;
    }
    
    function getBalance() external view returns (euint32) {
        require(initialized[msg.sender], "Not initialized");
        return balances[msg.sender];
    }
}
```

---

**🤖 Remember for AI**: Without `FHE.allow()`, you're passing a locked box without the key! 🔐

**🎯 AI Success Formula**: Mental Model + Working Examples + Security Patterns = Perfect FHE Code

*Found an issue or have a suggestion? [Open an issue](https://github.com/fhenixprotocol/fhe-assistant/issues) to help improve this guide.*