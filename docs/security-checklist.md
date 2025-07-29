# FHE Security Checklist 🛡️

**Pre-flight checklist for FHE smart contract security**

Use this checklist when reviewing FHE contracts or asking AI assistants to review your code. Each item represents a critical security consideration unique to FHE development.

## 🔍 Pre-Review Setup

Before starting your security review:

- [ ] **Contract compiles without errors** (`forge build`)
- [ ] **All tests pass** (`forge test`)
- [ ] **FHE library properly imported** (`import "@fhenixprotocol/contracts/FHE.sol";`)
- [ ] **Access control patterns understood** (reviewer familiar with FHE.allow())

## 🔐 Access Control Review

### Critical: FHE.allow() Patterns

- [ ] **All returned encrypted values have FHE.allow()**
  ```solidity
  // ❌ BAD: No access granted
  function getBalance() external returns (euint32) {
      return balances[msg.sender]; // Caller can't decrypt!
  }
  
  // ✅ GOOD: Access granted
  function getBalance() external returns (euint32) {
      euint32 balance = balances[msg.sender];
      FHE.allow(balance, msg.sender); // Now caller can decrypt
      return balance;
  }
  ```

- [ ] **Stored encrypted values use FHE.allowThis()**
  ```solidity
  // ❌ BAD: Contract loses access
  function updateBalance(euint32 newBalance) external {
      balances[msg.sender] = newBalance; // Contract can't use this later!
  }
  
  // ✅ GOOD: Contract retains access
  function updateBalance(euint32 newBalance) external {
      FHE.allowThis(newBalance); // Contract can access later
      balances[msg.sender] = newBalance;
  }
  ```

- [ ] **Cross-contract permissions explicitly granted**
  ```solidity
  // ✅ GOOD: Explicit permission for other contract
  function shareData(address otherContract) external returns (euint32) {
      FHE.allow(data, otherContract);
      return data;
  }
  ```

- [ ] **No over-permissive access grants**
  ```solidity
  // ❌ BAD: Granting unnecessary access
  function processData() external {
      FHE.allow(sensitiveData, msg.sender); // Why does caller need this?
  }
  ```

## 🚫 Control Flow Security

### ebool Usage Verification

- [ ] **No ebool used in if statements**
  ```solidity
  // ❌ BAD: Won't compile
  ebool condition = FHE.gt(a, b);
  if (condition) { // ERROR!
  ```

- [ ] **FHE.select() used for conditional logic**
  ```solidity
  // ✅ GOOD: Proper conditional execution
  ebool condition = FHE.gt(balance, amount);
  euint32 result = FHE.select(condition, success_value, failure_value);
  ```

- [ ] **Both branches of FHE.select() are safe**
  ```solidity
  // ⚠️ VERIFY: Both branches execute regardless of condition
  euint32 result = FHE.select(
      condition,
      expensiveOperation(a), // This ALWAYS executes
      anotherOperation(b)    // This ALSO always executes
  );
  ```

## 💰 Encrypted Token Security (FHERC20)

### Balance Protection

- [ ] **Dual balance system implemented**
  ```solidity
  mapping(address => euint32) private balances;      // Encrypted amounts
  mapping(address => bool) public hasBalance;        // Public indicators
  ```

- [ ] **No encrypted balance overflow protection**
  ```solidity
  // ✅ GOOD: Overflow is handled by FHE operations
  euint32 newBalance = FHE.add(balance, amount); // Won't overflow in traditional sense
  ```

- [ ] **Transfer validation using FHE.select()**
  ```solidity
  // ✅ GOOD: Zero-knowledge transfer validation
  ebool canTransfer = FHE.gte(balance, amount);
  euint32 newBalance = FHE.select(canTransfer, 
      FHE.sub(balance, amount), 
      balance // Keep original if insufficient
  );
  ```

## 🔄 Decryption Security

### Multi-Transaction Patterns

- [ ] **Decryption requests properly managed**
  ```solidity
  mapping(bytes32 => bool) public decryptionRequested;
  
  function requestDecryption(bytes32 id) external {
      require(!decryptionRequested[id], "Already requested");
      FHE.allow(data[id], msg.sender);
      decryptionRequested[id] = true;
  }
  ```

- [ ] **Decryption state tracked correctly**
  ```solidity
  // Track who can decrypt what
  mapping(bytes32 => address) public decryptionOwner;
  ```

- [ ] **No synchronous decryption assumptions**
  ```solidity
  // ❌ BAD: Expecting immediate decryption
  function badPattern() external {
      euint32 encrypted = someOperation();
      uint32 decrypted = FHE.decrypt(encrypted); // This won't work!
  }
  ```

## 🔄 Cross-Contract Security

### Permission Management

- [ ] **Explicit permissions for contract interactions**
  ```solidity
  // Contract A
  function shareWithB(address contractB) external {
      FHE.allow(data, contractB); // Explicit permission
  }
  
  // Contract B
  function useSharedData() external {
      // Can now access data because A granted permission
  }
  ```

- [ ] **Permission scope properly limited**
  ```solidity
  // ❌ BAD: Too broad
  FHE.allow(data, address(0)); // Allows anyone!
  
  // ✅ GOOD: Specific permissions
  FHE.allow(data, trustedContract);
  ```

## 🧪 Testing Security

### Test Coverage Requirements

- [ ] **Access control tests**
  ```solidity
  function testAccessControl() public {
      // Test that only authorized addresses can decrypt
  }
  ```

- [ ] **Cross-contract permission tests**
  ```solidity
  function testCrossContractPermissions() public {
      // Test contract-to-contract data sharing
  }
  ```

- [ ] **Edge case testing**
  ```solidity
  function testZeroValues() public {
      // Test behavior with zero encrypted values
  }
  
  function testMaxValues() public {
      // Test behavior at type limits
  }
  ```

- [ ] **Async decryption flow tests**
  ```solidity
  function testDecryptionFlow() public {
      // Test multi-transaction decryption pattern
  }
  ```

## 🚨 Common Vulnerabilities

### Check for These Anti-Patterns

- [ ] **Missing FHE.allow() calls**
  - Functions returning encrypted values without granting access
  - Functions storing encrypted values without FHE.allowThis()

- [ ] **Incorrect ebool usage**
  - Using ebool in if statements
  - Trying to convert ebool to bool

- [ ] **Access control bypasses**
  - Functions that expose encrypted data without proper permissions
  - Over-permissive access grants

- [ ] **Cross-contract vulnerabilities**
  - Missing permissions for cross-contract calls
  - Assuming other contracts have access they don't have

- [ ] **Decryption race conditions**
  - Not properly tracking decryption state
  - Allowing multiple decryption requests for same data

## 🎯 Specific Pattern Checks

### Encrypted Auction Security

- [ ] **Bid privacy maintained until reveal**
- [ ] **Winner determination doesn't leak losing bids**
- [ ] **Refund mechanism preserves privacy**

### Encrypted Voting Security

- [ ] **Vote privacy maintained throughout**
- [ ] **Vote counting doesn't reveal individual votes**
- [ ] **Result revelation is controlled**

### Encrypted Gaming Security

- [ ] **Game state privacy preserved**
- [ ] **Player actions don't leak information**
- [ ] **Random number generation secure**

## 📋 Review Sign-off

After completing all checks:

- [ ] **All critical items verified**
- [ ] **No anti-patterns identified**
- [ ] **Test coverage adequate**
- [ ] **Documentation updated**

### Reviewer Information

- **Reviewer**: _______________
- **Date**: _______________
- **Tools Used**: 
  - [ ] Manual review
  - [ ] Automated testing
  - [ ] AI assistant review
  - [ ] Community feedback

### Risk Assessment

**Overall Risk Level**:
- [ ] Low (All checks passed, comprehensive testing)
- [ ] Medium (Minor issues identified, needs follow-up)
- [ ] High (Critical issues found, requires immediate attention)

**Identified Issues**:
1. _______________
2. _______________
3. _______________

**Recommendations**:
1. _______________
2. _______________
3. _______________

## 🤝 Community Review

Consider getting additional eyes on your contract:

- [ ] **Post in [Fhenix Discord](https://discord.gg/FuVgxrvJMY) for community review**
- [ ] **Submit to bug bounty programs when available**
- [ ] **Request formal audit for high-value contracts**

## 🔗 Additional Resources

For items not covered in this checklist, refer to:
- [Fhenix Documentation](https://docs.fhenix.zone)
- [FHE Security Best Practices](https://docs.fhenix.zone/docs/devdocs/Security/best_practices)

---

**Remember**: FHE security is different from traditional smart contract security. Access control is mandatory, not optional! 🔐

*Found a security issue or pattern missing from this checklist? [Open an issue](https://github.com/fhenixprotocol/fhe-assistant/issues) to help protect the entire community.*