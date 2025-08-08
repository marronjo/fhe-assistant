# FHE Security Checklist 🛡️

**Pre-flight checklist for FHE smart contract security - Optimized for AI code review**

Use this checklist when reviewing FHE contracts or asking AI assistants to review your code. Each item represents a critical security consideration unique to FHE development.

## 🤖 AI Code Review Quick Commands

**Copy-paste these prompts for instant AI security review:**

```
🎯 "Review this FHE contract against the security checklist. Flag all issues and provide fixes: [paste code]"

🎯 "Check if this FHE code follows proper access control patterns: [paste code]"

🎯 "Validate this FHE contract uses FHE.select() correctly and never uses ebool in if statements: [paste code]"

🎯 "Audit this FHE contract for missing FHE.allow() and FHE.allowThis() calls: [paste code]"
```

## 🔍 Pre-Review Setup

**For AI-Assisted Security Review:**

- [ ] **Contract compiles without errors** (`forge build`)
- [ ] **All tests pass** (`forge test`)
- [ ] **FHE library properly imported** (`import "@fhenixprotocol/contracts/FHE.sol";`)
- [ ] **AI understands FHE patterns** (loaded core-patterns.md into AI context)
- [ ] **Security checklist loaded** (this file provided to AI for reference)

### 🤖 AI Review Preparation Commands

```bash
# Load security context into AI
claude --file docs/security-checklist.md \
      --file docs/core-patterns.md \
      --file src/YourContract.sol \
      "Perform comprehensive security review of this FHE contract"

# Quick security scan
claude --file docs/security-checklist.md \
      "Review this code snippet for FHE security issues: [paste code]"
```

## 🔐 Access Control Review

### 🤖 AI Security Validation Prompts

**For AI to check access control automatically:**

```
🎯 "Scan this contract for missing FHE.allow() calls on all return statements"
🎯 "Verify every encrypted storage operation uses FHE.allowThis()"
🎯 "Check if any functions return encrypted values without granting access"
```

### Critical: FHE.allow() Patterns

**🤖 AI Checklist: For every encrypted return, AI should verify:**

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

### 🤖 AI Token Security Validation

**AI prompts for token security:**
```
🎯 "Review this FHERC20 implementation for balance privacy leaks"
🎯 "Check if this encrypted token properly validates transfers using FHE.select()"
🎯 "Verify this token contract doesn't reveal balances through events or reverts"
```

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

### 🤖 AI Decryption Pattern Validation

**AI prompts for decryption security:**
```
🎯 "Check if this contract properly manages multi-transaction decryption state"
🎯 "Verify no functions assume synchronous decryption of encrypted values"
🎯 "Review decryption request tracking for potential race conditions"
```

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

### 🤖 AI Cross-Contract Validation

**AI prompts for cross-contract security:**
```
🎯 "Check if contracts properly grant cross-contract permissions for encrypted data sharing"
🎯 "Verify all contract-to-contract encrypted data transfers have explicit FHE.allow() calls"
🎯 "Review permission scope - ensure no overly broad access grants"
```

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

### 🤖 AI Test Generation for Security

**AI prompts for security test generation:**
```
🎯 "Generate comprehensive access control tests for this FHE contract"
🎯 "Create tests that verify users can only decrypt their own encrypted data"
🎯 "Write edge case tests for FHE.select() conditional logic"
🎯 "Generate tests for cross-contract permission scenarios"
```

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

### 🤖 AI Vulnerability Scanner Prompts

**Use these prompts to have AI scan for specific vulnerabilities:**

```
🎯 "Scan this FHE contract for these vulnerabilities:
- Missing FHE.allow() calls
- ebool used in if statements  
- Missing FHE.allowThis() for storage
- Over-permissive access grants
- Unhandled decryption race conditions
[paste code]"

🎯 "Check this contract against the common FHE anti-patterns list"

🎯 "Identify any functions that could leak encrypted data through side channels"
```

### 🤖 AI Anti-Pattern Detection

**AI should automatically flag these patterns:**

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

### 🤖 AI Pattern Validation Prompts

**For specific FHE application types:**

### Encrypted Auction Security

```
🎯 AI Prompt: "Review this encrypted auction for:
- Bid privacy maintained until reveal phase
- Winner determination doesn't leak losing bids  
- Refund mechanism preserves privacy
- No bid amount leakage through gas usage patterns
[paste auction contract]"
```

- [ ] **Bid privacy maintained until reveal**
- [ ] **Winner determination doesn't leak losing bids**
- [ ] **Refund mechanism preserves privacy**
- [ ] **Gas usage doesn't leak bid information**

### Encrypted Voting Security

```
🎯 AI Prompt: "Audit this encrypted voting system for:
- Vote privacy maintained throughout entire process
- Vote counting doesn't reveal individual votes
- Result revelation is properly controlled
- No voter information leakage through timing or gas
[paste voting contract]"
```

- [ ] **Vote privacy maintained throughout**
- [ ] **Vote counting doesn't reveal individual votes**
- [ ] **Result revelation is controlled**
- [ ] **No timing-based vote leakage**

### Encrypted Gaming Security

```
🎯 AI Prompt: "Security review this encrypted gaming contract for:
- Game state privacy preserved across all operations
- Player actions don't leak strategic information
- Random number generation is secure and unpredictable
- No advantage gained through transaction analysis
[paste gaming contract]"
```

- [ ] **Game state privacy preserved**
- [ ] **Player actions don't leak information**
- [ ] **Random number generation secure**
- [ ] **No transaction analysis advantages**

## 📋 Review Sign-off

### 🤖 AI-Assisted Review Completion

**AI Final Review Prompts:**
```
🎯 "Provide final security assessment summary for this FHE contract with risk rating"

🎯 "Generate security review report with all identified issues and fixes"

🎯 "Create deployment readiness checklist for this FHE contract"
```

After completing all checks:

- [ ] **All critical items verified**
- [ ] **No anti-patterns identified**
- [ ] **Test coverage adequate**
- [ ] **Documentation updated**
- [ ] **AI security scan completed**
- [ ] **All AI-identified issues resolved**

### Reviewer Information

- **Reviewer**: _______________
- **Date**: _______________
- **Tools Used**: 
  - [ ] Manual review
  - [ ] Automated testing
  - [ ] AI assistant review
  - [ ] Community feedback

### Risk Assessment

**Overall Risk Level** (AI-Assisted Assessment):
- [ ] Low (All checks passed, comprehensive testing, AI validation clean)
- [ ] Medium (Minor issues identified, needs follow-up, AI suggestions implemented)
- [ ] High (Critical issues found, requires immediate attention, AI blocked deployment)

**AI Security Score**: ___/10
- Access Control: ___/3
- Pattern Compliance: ___/3  
- Vulnerability Scan: ___/2
- Best Practices: ___/2

**Identified Issues**:
1. _______________
2. _______________
3. _______________

**Recommendations**:
1. _______________
2. _______________
3. _______________

## 🤝 Community Review

### 🤖 AI + Human Review Strategy

**Recommended review layers:**
1. **AI Security Scan** (this checklist) - Automated pattern detection
2. **Human Expert Review** - Business logic and edge cases
3. **Community Review** - Broader security perspective
4. **Formal Audit** - Professional security assessment

Consider getting additional eyes on your contract:

- [ ] **AI security review completed** (using this checklist)
- [ ] **Post in [Fhenix Discord](https://discord.gg/FuVgxrvJMY) for community review**
- [ ] **Submit to bug bounty programs when available**
- [ ] **Request formal audit for high-value contracts**

### 🎯 AI Security Review Templates

**For community review posts:**
```
💬 "I've completed AI security review using the FHE checklist. 
Looking for human review of business logic and edge cases.
Contract: [link/code]
AI Security Score: X/10
Known issues: [list]"
```

**For audit preparation:**
```
💬 "Preparing for formal audit. AI security review completed.
All automated checks passed. Focus areas for auditor:
- [Complex business logic]
- [Cross-contract interactions]
- [Economic security model]"
```

## 🔗 Additional Resources

For items not covered in this checklist, refer to:
- [Fhenix Documentation](https://docs.fhenix.zone)
- [FHE Security Best Practices](https://docs.fhenix.zone/docs/devdocs/Security/best_practices)

## 🚀 AI Security Automation

### 🤖 Automated Security Scripts

**Create AI-powered security check scripts:**

```bash
# AI security review script
#!/bin/bash
echo "Running AI FHE Security Review..."
claude --file docs/security-checklist.md \
      --file docs/core-patterns.md \
      --file src/*.sol \
      "Comprehensive security review against FHE checklist. Provide detailed report."
```

### 📊 Security Metrics for AI

**Track these metrics in AI reviews:**
- **Access Control Coverage**: % of encrypted returns with FHE.allow()
- **Pattern Compliance**: % following FHE.select() vs if patterns
- **Storage Security**: % of encrypted storage with FHE.allowThis()
- **Test Coverage**: % of security scenarios tested
- **Documentation Score**: Quality of FHE pattern documentation

### 🎯 Continuous Security with AI

**Integrate AI security checks into development:**

```bash
# Pre-commit hook
git add . && claude --file docs/security-checklist.md --file src/modified_files "Quick security scan of changes"

# CI/CD integration  
forge test && claude --file docs/security-checklist.md --file src/ "Security review for deployment"

# Pre-deployment final check
claude --file docs/security-checklist.md --file src/ "Final deployment security clearance"
```

---

**🤖 Remember for AI**: FHE security is different from traditional smart contract security. Access control is mandatory, not optional! 🔐

**🎯 AI Security Formula**: Automated Pattern Detection + Human Business Logic Review = Secure FHE Contracts

*Found a security issue or pattern missing from this checklist? [Open an issue](https://github.com/fhenixprotocol/fhe-assistant/issues) to help protect the entire community.*