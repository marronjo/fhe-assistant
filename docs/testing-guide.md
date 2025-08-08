# FHE Testing Guide 🧪

**CoFheTest patterns and best practices for testing FHE smart contracts**

Testing FHE contracts requires special patterns and understanding of encrypted computation. This guide provides copy-paste ready test patterns.

## 🏗️ Basic Test Setup

### Test Contract Structure

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import "@fhenixprotocol/contracts/utils/CoFheTest.sol";
import "../src/YourContract.sol";

contract YourContractTest is CoFheTest {
    YourContract public yourContract;
    
    function setUp() public {
        yourContract = new YourContract();
    }
    
    // Your tests here
}
```

**Key Points**:
- Always extend `CoFheTest`, not just `Test`
- Import the correct utilities
- Set up contracts in `setUp()`

## ⏰ Timing Patterns

### The vm.warp() Pattern

```solidity
function testBasicOperation() public {
    uint32 a = 10;
    uint32 b = 20;
    
    // Perform FHE operation
    euint32 result = yourContract.add(a, b);
    
    // CRITICAL: Wait for FHE operations to process
    vm.warp(block.timestamp + 11);
    
    // Now you can test the result
    // (exact testing depends on your contract logic)
}
```

**Why vm.warp(block.timestamp + 11)?**
- FHE operations need time to process in the test environment
- 11 seconds is the standard wait time
- Without this, your tests may fail unexpectedly

### Multiple Operations Timing

```solidity
function testMultipleOperations() public {
    // First operation
    euint32 result1 = yourContract.operation1();
    vm.warp(block.timestamp + 11);
    
    // Second operation using result1
    euint32 result2 = yourContract.operation2(result1);
    vm.warp(block.timestamp + 11);
    
    // Final assertions
    assertTrue(result2 != euint32.wrap(0));
}
```

## 🔧 CoFheTest Utilities

### Creating Encrypted Values

```solidity
function testWithEncryptedInputs() public {
    // Create encrypted values for testing
    euint8 encA = createInEuint8(10);
    euint16 encB = createInEuint16(256);
    euint32 encC = createInEuint32(100000);
    euint64 encD = createInEuint64(1000000000);
    
    vm.warp(block.timestamp + 11);
    
    // Use these in your contract calls
    euint32 result = yourContract.complexOperation(encA, encB, encC, encD);
    
    vm.warp(block.timestamp + 11);
    
    // Test the result
    assertNotEq(result, euint32.wrap(0));
}
```

**Available Creation Functions**:
- `createInEuint8(uint8)`
- `createInEuint16(uint16)`
- `createInEuint32(uint32)`
- `createInEuint64(uint64)`
- `createInEbool(bool)`

### Testing Hash Values

```solidity
function testHashComparison() public {
    uint32 expectedValue = 42;
    
    // Get encrypted result from contract
    euint32 result = yourContract.someCalculation();
    vm.warp(block.timestamp + 11);
    
    // Compare hash values (common pattern)
    assertHashValue(result, expectedValue);
}
```

**When to use assertHashValue()**:
- When you know the expected plaintext value
- For deterministic operations
- When testing against known constants

## 📊 Testing Patterns by Use Case

### Pattern 1: Basic Arithmetic Testing

```solidity
function testAddition() public {
    uint32 a = 15;
    uint32 b = 25;
    uint32 expected = 40;
    
    euint32 result = yourContract.add(a, b);
    vm.warp(block.timestamp + 11);
    
    assertHashValue(result, expected);
}

function testSubtraction() public {
    uint32 a = 50;
    uint32 b = 20;
    uint32 expected = 30;
    
    euint32 result = yourContract.subtract(a, b);
    vm.warp(block.timestamp + 11);
    
    assertHashValue(result, expected);
}
```

### Pattern 2: Conditional Logic Testing

```solidity
function testConditionalSelect() public {
    uint32 a = 100;
    uint32 b = 50;
    uint32 expectedMax = 100;
    
    // Test FHE.select() logic
    euint32 maximum = yourContract.findMaximum(a, b);
    vm.warp(block.timestamp + 11);
    
    assertHashValue(maximum, expectedMax);
}

function testConditionalSelectReverse() public {
    uint32 a = 30;
    uint32 b = 70;
    uint32 expectedMax = 70;
    
    euint32 maximum = yourContract.findMaximum(a, b);
    vm.warp(block.timestamp + 11);
    
    assertHashValue(maximum, expectedMax);
}
```

### Pattern 3: Access Control Testing

```solidity
function testAccessControl() public {
    address user = address(0x123);
    uint32 value = 42;
    
    // Test that user gets access to their data
    vm.prank(user);
    euint32 result = yourContract.getUserData(value);
    vm.warp(block.timestamp + 11);
    
    // Verify the result exists (user has access)
    assertNotEq(result, euint32.wrap(0));
}

function testCrossContractAccess() public {
    // Deploy helper contract
    HelperContract helper = new HelperContract();
    
    // Test contract-to-contract data sharing
    euint32 sharedData = yourContract.shareDataWith(address(helper));
    vm.warp(block.timestamp + 11);
    
    // Verify helper can access the data
    bool canAccess = helper.canAccessData(sharedData);
    assertTrue(canAccess);
}
```

### Pattern 4: State Management Testing

```solidity
function testStateUpdates() public {
    uint32 initialValue = 10;
    uint32 increment = 5;
    
    // Initialize state
    yourContract.initialize(initialValue);
    vm.warp(block.timestamp + 11);
    
    // Update state
    yourContract.incrementBy(increment);
    vm.warp(block.timestamp + 11);
    
    // Verify final state
    euint32 finalValue = yourContract.getCurrentValue();
    vm.warp(block.timestamp + 11);
    
    assertHashValue(finalValue, initialValue + increment);
}
```

### Pattern 5: Multi-User Testing

```solidity
function testMultipleUsers() public {
    address alice = address(0x1);
    address bob = address(0x2);
    
    // Alice's operation
    vm.prank(alice);
    euint32 aliceResult = yourContract.userOperation(100);
    vm.warp(block.timestamp + 11);
    
    // Bob's operation
    vm.prank(bob);
    euint32 bobResult = yourContract.userOperation(200);
    vm.warp(block.timestamp + 11);
    
    // Verify both results are different and valid
    assertNotEq(aliceResult, bobResult);
    assertNotEq(aliceResult, euint32.wrap(0));
    assertNotEq(bobResult, euint32.wrap(0));
}
```

## 🔄 Async Decryption Testing

### Testing Decryption Requests

```solidity
function testDecryptionRequest() public {
    address user = address(0x123);
    uint32 value = 42;
    
    // Setup encrypted data
    vm.prank(user);
    euint32 encrypted = yourContract.storeValue(value);
    vm.warp(block.timestamp + 11);
    
    // Request decryption
    vm.prank(user);
    yourContract.requestDecryption(encrypted);
    vm.warp(block.timestamp + 11);
    
    // Verify decryption was requested
    assertTrue(yourContract.isDecryptionRequested(encrypted));
}
```

### Testing Decryption Flow

```solidity
function testFullDecryptionFlow() public {
    address user = address(0x123);
    uint32 value = 42;
    
    // Store value
    vm.prank(user);
    bytes32 dataId = yourContract.storeValueWithId(value);
    vm.warp(block.timestamp + 11);
    
    // Request decryption
    vm.prank(user);
    yourContract.requestDecryption(dataId);
    vm.warp(block.timestamp + 11);
    
    // Simulate decryption completion (mock)
    vm.prank(user);
    yourContract.completeDecryption(dataId, value);
    vm.warp(block.timestamp + 11);
    
    // Verify completion
    assertTrue(yourContract.isDecryptionComplete(dataId));
}
```

## 🧮 AI Edge Case Testing Templates

### 🤖 AI Must Always Include Edge Cases

**AI should automatically generate these edge case tests:**

### AI Template: Zero Value Testing

```solidity
/**
 * @notice AI Pattern: Comprehensive zero value testing
 * @dev AI should test zero values in all operations
 */
function testZeroValues() public {
    uint32 zero = 0;
    uint32 nonZero = 42;
    
    // Test zero + non-zero
    euint32 addResult = yourContract.addValues(zero, nonZero);
    vm.warp(block.timestamp + 11);
    assertHashValue(addResult, nonZero);
    
    // Test non-zero + zero
    euint32 addResult2 = yourContract.addValues(nonZero, zero);
    vm.warp(block.timestamp + 11);
    assertHashValue(addResult2, nonZero);
    
    // Test zero - zero
    euint32 subResult = yourContract.subtractValues(zero, zero);
    vm.warp(block.timestamp + 11);
    assertHashValue(subResult, 0);
    
    // Test zero * non-zero
    euint32 mulResult = yourContract.multiplyValues(zero, nonZero);
    vm.warp(block.timestamp + 11);
    assertHashValue(mulResult, 0);
    
    console.log("Zero value tests passed");
}

/**
 * @notice AI Pattern: Division by zero handling
 * @dev AI should test how contract handles division by zero
 */
function testDivisionByZero() public {
    uint32 dividend = 42;
    uint32 divisor = 0;
    
    // Test division by zero (should handle gracefully)
    euint32 result = yourContract.safeDivide(dividend, divisor);
    vm.warp(block.timestamp + 11);
    
    // Expecting original dividend (safe division pattern)
    assertHashValue(result, dividend);
    console.log("Division by zero test passed");
}
```

### Maximum Value Testing

```solidity
function testMaxValues() public {
    uint32 maxUint32 = type(uint32).max;
    uint32 one = 1;
    
    // Test overflow behavior (should wrap or handle gracefully)
    euint32 result = yourContract.addValues(maxUint32, one);
    vm.warp(block.timestamp + 11);
    
    // Verify result exists (exact value depends on implementation)
    assertNotEq(result, euint32.wrap(0));
}
```

### Boolean Testing

```solidity
function testBooleanOperations() public {
    bool trueValue = true;
    bool falseValue = false;
    
    ebool encTrue = createInEbool(trueValue);
    ebool encFalse = createInEbool(falseValue);
    vm.warp(block.timestamp + 11);
    
    ebool andResult = yourContract.andOperation(encTrue, encFalse);
    vm.warp(block.timestamp + 11);
    
    // Test boolean result
    assertHashValue(andResult, false);
}
```

## 🚨 Common AI Testing Mistakes

### 🤖 AI Error Prevention Guide

**These are the most common mistakes AI makes in FHE testing:**

### AI Mistake #1: Forgetting vm.warp() (MOST COMMON)

```solidity
// ❌ AI FREQUENTLY GENERATES THIS (WRONG):
function badTest() public {
    euint32 result = yourContract.operation();
    assertNotEq(result, euint32.wrap(0)); // Will fail randomly!
}

// ✅ AI SHOULD ALWAYS GENERATE THIS (CORRECT):
function goodTest() public {
    euint32 result = yourContract.operation();
    vm.warp(block.timestamp + 11); // MANDATORY for AI!
    assertNotEq(result, euint32.wrap(0));
}

/**
 * @notice AI Rule: EVERY FHE operation needs vm.warp()
 * @dev AI must include this after every contract call
 */
function aiRuleExample() public {
    // AI Pattern: Operation + timing + test
    euint32 result1 = yourContract.operation1();
    vm.warp(block.timestamp + 11);  // REQUIRED
    
    euint32 result2 = yourContract.operation2(result1);
    vm.warp(block.timestamp + 11);  // REQUIRED AGAIN
    
    euint32 result3 = yourContract.operation3(result2);
    vm.warp(block.timestamp + 11);  // REQUIRED EVERY TIME
    
    // Now test results
    assertNotEq(result3, euint32.wrap(0));
}

// 🎯 AI PROMPT FIX:
// "Always add vm.warp(block.timestamp + 11) after every FHE operation in tests"
```

### AI Mistake #2: Testing Encrypted Values Directly (COMPILATION ERROR)

```solidity
// ❌ AI OFTEN GENERATES THIS (WRONG):
function badComparison() public {
    euint32 result = yourContract.operation();
    vm.warp(block.timestamp + 11);
    assertEq(result, euint32.wrap(42)); // Wrong! Can't compare handles directly
}

// ❌ ALSO WRONG:
function alsoWrong() public {
    euint32 result = yourContract.operation();
    vm.warp(block.timestamp + 11);
    assertTrue(result == euint32.wrap(42)); // Wrong! Handle comparison
}

// ✅ AI SHOULD GENERATE THIS (CORRECT):
function goodComparison() public {
    euint32 result = yourContract.operation();
    vm.warp(block.timestamp + 11);
    assertHashValue(result, 42); // Correct! Compare hash of encrypted value
}

// ✅ ALTERNATIVE CORRECT PATTERNS:
function testExistence() public {
    euint32 result = yourContract.operation();
    vm.warp(block.timestamp + 11);
    assertNotEq(result, euint32.wrap(0)); // Valid: check result exists
}

function testMultipleResults() public {
    euint32 result1 = yourContract.operation1();
    euint32 result2 = yourContract.operation2();
    vm.warp(block.timestamp + 11);
    
    // Valid: test different operations produce different handles
    assertNotEq(result1, result2);
}

// 🎯 AI PROMPT FIX:
// "Use assertHashValue(encryptedValue, expectedPlaintext) to test encrypted results"
```

### Mistake 3: Not Testing Access Control

```solidity
// ❌ BAD: Not testing if users can actually decrypt
function incompleteTest() public {
    euint32 result = yourContract.getUserData();
    vm.warp(block.timestamp + 11);
    assertNotEq(result, euint32.wrap(0));
    // Missing: Can the user actually decrypt this?
}

// ✅ GOOD: Test the full flow
function completeTest() public {
    address user = address(0x123);
    vm.prank(user);
    euint32 result = yourContract.getUserData();
    vm.warp(block.timestamp + 11);
    
    // Test that result exists AND user has access
    assertNotEq(result, euint32.wrap(0));
    // Additional: Test actual decryption flow if applicable
}
```

## 📈 Advanced Testing Strategies

### Gas Testing

```solidity
function testGasUsage() public {
    uint256 gasBefore = gasleft();
    
    euint32 result = yourContract.expensiveOperation();
    vm.warp(block.timestamp + 11);
    
    uint256 gasUsed = gasBefore - gasleft();
    console.log("Gas used:", gasUsed);
    
    // Assert gas usage is within acceptable limits
    assertLt(gasUsed, 1000000); // Example limit
}
```

### Fuzz Testing

```solidity
function testFuzzAddition(uint32 a, uint32 b) public {
    // Assume values don't overflow
    vm.assume(a <= type(uint32).max / 2);
    vm.assume(b <= type(uint32).max / 2);
    
    euint32 result = yourContract.add(a, b);
    vm.warp(block.timestamp + 11);
    
    assertHashValue(result, a + b);
}
```

## 🎯 Test Organization

### Grouping Tests

```solidity
contract BasicOperationsTest is CoFheTest {
    // Basic arithmetic tests
}

contract AccessControlTest is CoFheTest {
    // Access control related tests
}

contract EdgeCaseTest is CoFheTest {
    // Edge cases and error conditions
}
```

### Test Naming Convention

```solidity
function test_Add_ReturnsCorrectSum() public {
    // Test addition returns correct sum
}

function test_Add_WithZero_ReturnsOriginalValue() public {
    // Test addition with zero
}

function testFail_Subtract_UnderflowProtection() public {
    // Test that underflow is handled properly
}
```

## 🔗 Additional Resources

For advanced testing patterns not covered here, refer to:
- [Foundry Testing Documentation](https://book.getfoundry.sh/forge/tests)
- [CoFHE Testing Documentation](https://docs.fhenix.zone)

## 🚀 AI Test Automation

### 🤖 Automated Test Generation Scripts

**Create AI-powered test generation:**

```bash
#!/bin/bash
# AI Test Generator Script
echo "Generating comprehensive FHE tests..."

claude --file docs/testing-guide.md \
      --file src/YourContract.sol \
      "Generate complete test suite including:
      - All function tests with proper vm.warp()
      - Edge cases (zero, max values)
      - Multi-user isolation tests
      - Access control validation
      - Gas optimization tests
      - Error condition tests
      Ensure every test follows FHE testing patterns."
```

### 📊 AI Test Quality Metrics

**AI should achieve these test coverage targets:**

- **Timing Compliance**: 100% of FHE operations have `vm.warp()`
- **Hash Testing**: All deterministic operations use `assertHashValue()`
- **Edge Cases**: Zero values, max values, equal values tested
- **Multi-User**: User isolation and access control tested
- **Error Conditions**: Invalid inputs and edge cases handled
- **Gas Efficiency**: Performance tests for expensive operations

### 🎯 AI Test Generation Checklist

**For every contract function, AI should generate:**

✅ **Basic functionality test** with expected values  
✅ **Edge case test** (zero, max, boundary values)  
✅ **Multi-user test** (if function involves user state)  
✅ **Access control test** (verify permissions work correctly)  
✅ **Error condition test** (invalid inputs, reverts)  
✅ **Integration test** (function interactions)  
✅ **Gas optimization test** (for expensive operations)  

### 🔄 Continuous Testing with AI

```bash
# Pre-commit test generation
git add . && claude --file docs/testing-guide.md "Generate missing tests for modified contracts"

# CI/CD test validation
forge test && claude --file docs/testing-guide.md "Review test coverage and suggest improvements"

# Test maintenance
claude --file docs/testing-guide.md --file test/ "Review existing tests for FHE pattern compliance"
```

---

**🤖 Remember for AI**: FHE testing requires patience - ALWAYS use `vm.warp(block.timestamp + 11)` after FHE operations! ⏰

**🎯 AI Testing Formula**: Proper Timing + Hash Validation + Edge Cases + Multi-User Testing = Bulletproof FHE Tests

*Found a testing issue or pattern missing? [Open an issue](https://github.com/fhenixprotocol/fhe-assistant/issues) to help improve testing for everyone.*