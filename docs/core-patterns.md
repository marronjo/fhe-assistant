# Core FHE Patterns 🔐

**Mental Model**: "Without FHE.allow() = passing a locked box without the key!"

This document covers the fundamental concepts and patterns for Fully Homomorphic Encryption (FHE) smart contract development on Fhenix.

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

```solidity
// ❌ WRONG: Returns encrypted handle without access
function getBalance() external view returns (euint32) {
    return balances[msg.sender]; // Useless encrypted handle!
}

// ✅ CORRECT: Grant access to the caller
function getBalance() external returns (euint32) {
    euint32 balance = balances[msg.sender];
    FHE.allow(balance, msg.sender); // Now caller can decrypt!
    return balance;
}
```

## 🔑 Access Control Patterns

### FHE.allow() - Grant External Access

```solidity
// Grant access to specific address
FHE.allow(encryptedValue, someAddress);

// Grant access to caller
FHE.allow(encryptedValue, msg.sender);

// Grant access to multiple addresses
address[] memory addresses = new address[](2);
addresses[0] = user1;
addresses[1] = user2;
FHE.allow(encryptedValue, addresses);
```

### FHE.allowThis() - Grant Contract Access

```solidity
contract Calculator {
    mapping(address => euint32) private results;
    
    function calculate(uint32 a, uint32 b) external {
        euint32 encA = FHE.asEuint32(a);
        euint32 encB = FHE.asEuint32(b);
        euint32 sum = FHE.add(encA, encB);
        
        // Grant access to THIS contract for future operations
        FHE.allowThis(sum);
        results[msg.sender] = sum;
        
        // Also grant access to user for decryption
        FHE.allow(sum, msg.sender);
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
        FHE.allow(encryptedResult, msg.sender); // Grant access
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
    
    FHE.allow(result, msg.sender);
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

## 📚 Common Patterns

### Pattern 1: Encrypted Counter

```solidity
contract EncryptedCounter {
    euint32 private counter;
    
    constructor() {
        counter = FHE.asEuint32(0);
        FHE.allowThis(counter);
    }
    
    function increment() external {
        euint32 one = FHE.asEuint32(1);
        counter = FHE.add(counter, one);
        FHE.allowThis(counter); // Grant access to contract
    }
    
    function getCounter() external returns (euint32) {
        FHE.allow(counter, msg.sender); // Grant access to caller
        return counter;
    }
}
```

### Pattern 2: Encrypted Comparison

```solidity
function findMaximum(euint32 a, euint32 b) external returns (euint32) {
    ebool aIsGreater = FHE.gt(a, b);
    euint32 maximum = FHE.select(aIsGreater, a, b);
    
    FHE.allow(maximum, msg.sender);
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
    
    FHE.allow(inRange, msg.sender);
    return inRange;
}
```

### Pattern 4: Encrypted Accumulator

```solidity
contract EncryptedSum {
    euint32 private total;
    
    constructor() {
        total = FHE.asEuint32(0);
        FHE.allowThis(total);
    }
    
    function addValue(euint32 value) external {
        // Contract needs access to both values
        FHE.allowThis(value);
        
        total = FHE.add(total, value);
        FHE.allowThis(total);
    }
    
    function getTotal() external returns (euint32) {
        FHE.allow(total, msg.sender);
        return total;
    }
}
```

## 🔄 Cross-Contract Permissions

```solidity
contract DataProvider {
    euint32 private data;
    
    function shareData(address consumer) external returns (euint32) {
        FHE.allow(data, consumer); // Grant access to consumer contract
        return data;
    }
}

contract DataConsumer {
    function processData(address provider) external {
        euint32 data = DataProvider(provider).shareData(address(this));
        
        // Can now use data because provider granted us access
        euint32 doubled = FHE.add(data, data);
        FHE.allowThis(doubled);
    }
}
```

## ⚠️ Common Anti-Patterns

### Anti-Pattern 1: No Access Control

```solidity
// ❌ WRONG: Caller can't decrypt the result
function badFunction() external returns (euint32) {
    euint32 result = FHE.asEuint32(42);
    return result; // Useless! Caller has no access.
}
```

### Anti-Pattern 2: Using ebool in Conditionals

```solidity
// ❌ WRONG: ebool cannot be used in if statements
function badConditional(euint32 a, euint32 b) external {
    ebool condition = FHE.gt(a, b);
    if (condition) { // This won't compile
        // ...
    }
}
```

### Anti-Pattern 3: Forgetting Contract Access

```solidity
// ❌ WRONG: Contract can't access values in future calls
function badStorage(euint32 value) external {
    // Missing: FHE.allowThis(value);
    someMapping[msg.sender] = value; // Contract loses access!
}
```

## 🔍 Debugging Tips

1. **Access Issues**: If you get "access denied" errors, check `FHE.allow()` calls
2. **Handle Confusion**: Remember that FHE types are handles, not actual values
3. **Cross-Contract**: Both contracts need appropriate permissions
4. **Decryption**: Always expect multi-transaction flow for decryption

## 🎯 Best Practices

1. **Always use `FHE.allow()`** when returning encrypted values
2. **Use `FHE.allowThis()`** when storing encrypted values for later use
3. **Use `FHE.select()`** instead of if statements with ebool
4. **Plan for multi-transaction decryption** in your application flow
5. **Test access control thoroughly** - it's the most common source of bugs

## 🔗 Need More Information?

This document covers the fundamental patterns. For topics not covered here, refer to the official documentation at [docs.fhenix.zone](https://docs.fhenix.zone).

---

**Remember**: Without `FHE.allow()`, you're passing a locked box without the key! 🔐

*Found an issue or have a suggestion? [Open an issue](https://github.com/fhenixprotocol/fhe-assistant/issues) to help improve this guide.*